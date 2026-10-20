#!/usr/bin/env python3
"""Render the RC sticks from a rosbag as a transparent overlay video (two gimbals + ARM / MODE / KILL), drawn with OpenCV.
Usage:
  python3 rc_overlay.py run.bag sticks.webm                      # transparent WebM (VP9 + alpha), small
  python3 rc_overlay.py run.bag sticks.mov                       # transparent ProRes 4444 (any editor)
  python3 rc_overlay.py run.bag out.mp4 --composite obs.mp4 --arm-obs-at 4.0   # burned in, synced on arming (recommended)
  python3 rc_overlay.py run.bag out.mp4 --composite obs.mp4 --offset 2.5   # burned in, manual offset
  python3 rc_overlay.py run.bag --list-arms                                # print the arming times found in the bag
Options: --ns /vincent --fps 30 --start S --end S --size 480 (gimbal height px) --corner br|bl|tr|tl
--arm-obs-at S: second in the VIDEO where the drone arms (props start spinning); the arming is found in the bag
            (<ns>/mavros/state, else the arm switch) and the offset is computed. --arm-n N picks the N-th arming (default 1).
--offset: seconds to shift the sticks relative to the video (positive = sticks appear later); ignored with --arm-obs-at.
Needs: pip install rosbags numpy opencv-python-headless imageio-ffmpeg (static ffmpeg, used if the system one is missing/broken).
Channel map (RC_MAP_*): yaw 1, throttle 2, roll 3, pitch 4, arm 5, mode 6, kill 8. Throttle reversed (high PWM = low)."""
import argparse, subprocess, tempfile, os
import numpy as np, cv2
from pathlib import Path
from rosbags.highlevel import AnyReader
from rosbags.typesys import Stores, get_typestore, get_types_from_msg

ap = argparse.ArgumentParser()
ap.add_argument("bag"); ap.add_argument("out", nargs="?"); ap.add_argument("--ns", default="/vincent")
ap.add_argument("--fps", type=int, default=30); ap.add_argument("--start", type=float, default=0.0); ap.add_argument("--end", type=float, default=None)
ap.add_argument("--size", type=int, default=480, help="overlay height in px (width = 2x)")
ap.add_argument("--pwm-min", type=float, default=982); ap.add_argument("--pwm-max", type=float, default=2005)
ap.add_argument("--map", default="yaw=1,thr=2,roll=3,pitch=4,arm=5,mode=6,kill=8")
ap.add_argument("--rev", default="thr", help="comma list of reversed axes")
ap.add_argument("--composite", default=None, help="video to burn the sticks into (e.g. the OBS recording)")
ap.add_argument("--offset", type=float, default=0.0); ap.add_argument("--corner", default="br")
ap.add_argument("--arm-obs-at", "--arm-at", dest="arm_at", type=float, default=None); ap.add_argument("--arm-n", type=int, default=1)
ap.add_argument("--list-arms", action="store_true")
a = ap.parse_args()

def find_ffmpeg():
    """System ffmpeg if it runs, else the static one from pip (imageio-ffmpeg), else $FFMPEG."""
    for cand in [os.environ.get("FFMPEG"), "ffmpeg"]:
        if cand and subprocess.run([cand, "-version"], capture_output=True).returncode == 0:
            return cand
    try:
        import imageio_ffmpeg
        return imageio_ffmpeg.get_ffmpeg_exe()
    except ImportError:
        raise SystemExit("no working ffmpeg: pip install imageio-ffmpeg")
FF = find_ffmpeg()
M = {k: int(v) - 1 for k, v in (s.split("=") for s in a.map.split(","))}
REV = set(x for x in a.rev.split(",") if x)

TS = get_typestore(Stores.ROS1_NOETIC)
TS.register(get_types_from_msg("std_msgs/Header header\nuint8 rssi\nuint16[] channels\n", "mavros_msgs/msg/RCIn"))
TS.register(get_types_from_msg("std_msgs/Header header\nbool connected\nbool armed\nbool guided\nbool manual_input\nstring mode\nuint8 system_status\n", "mavros_msgs/msg/State"))
t, ch, ts_st, armed_st = [], [], [], []
with AnyReader([Path(a.bag)], default_typestore=TS) as r:
    conns = [c for c in r.connections if c.topic == a.ns + "/mavros/rc/in"]
    if not conns: raise SystemExit("no %s/mavros/rc/in in the bag" % a.ns)
    sconns = [c for c in r.connections if c.topic == a.ns + "/mavros/state"]
    for c, ts, raw in r.messages(connections=conns + sconns):
        m = r.deserialize(raw, c.msgtype)
        if c.topic.endswith("rc/in"): t.append(ts * 1e-9); ch.append(list(m.channels))
        else: ts_st.append(ts * 1e-9); armed_st.append(bool(m.armed))
T0 = t[0]
t = np.array(t) - T0; ch = np.array(ch, float); ts_st = np.array(ts_st) - T0; armed_st = np.array(armed_st)
rng = a.pwm_max - a.pwm_min
def axis(k):
    x = (ch[:, M[k]] - a.pwm_min) / rng * 2 - 1
    return np.clip(-x if k in REV else x, -1, 1)
def switch(k): return np.clip((ch[:, M[k]] - a.pwm_min) / rng, 0, 1)
yaw, thr, roll, pitch = axis("yaw"), axis("thr"), axis("roll"), axis("pitch")
arm, mode, kill = switch("arm"), switch("mode"), switch("kill")
if len(ts_st):   # ARMED indicator = PX4 armed state (same moment the props start spinning)
    idx = np.clip(np.searchsorted(ts_st, t, side="right") - 1, 0, len(ts_st) - 1)
    arm = np.where(ts_st[idx] <= t, armed_st[idx], False).astype(float)
    ev = [ts_st[k] for k in range(1, len(armed_st)) if armed_st[k] and not armed_st[k - 1]]
    src = "PX4 armed state"
else:
    sw = arm > 0.5
    ev = [t[k] for k in range(1, len(sw)) if sw[k] and not sw[k - 1]]
    src = "arm switch (no state topic in the bag)"
if a.list_arms or a.out is None:
    print("arming events (%s), seconds from the start of the stick data:" % src)
    for k, e in enumerate(ev, 1): print("  %d: %.2f s" % (k, e))
    raise SystemExit(0)
if a.arm_at is not None:
    if len(ev) < a.arm_n: raise SystemExit("only %d arming event(s) found in the bag" % len(ev))
    a.offset = a.arm_at - ev[a.arm_n - 1]
    print("arming #%d at %.2f s in the bag (%s) -> video %.2f s -> offset %.2f s" % (a.arm_n, ev[a.arm_n - 1], src, a.arm_at, a.offset))

H = a.size; W = 2 * H; box = int(H * 0.68); pad = int(H * 0.08); dot = max(6, H // 30)
cx = [W // 4, 3 * W // 4]; cy = pad + box // 2
WHITE = (255, 255, 255, 255); RED = (48, 59, 255, 255)   # BGRA
font = cv2.FONT_HERSHEY_SIMPLEX; fs = H / 600
def frame(i):
    f = np.zeros((H, W, 4), np.uint8)
    for j, (x, y, lab) in enumerate([(yaw[i], thr[i], "YAW / THR"), (roll[i], pitch[i], "ROLL / PITCH")]):
        x0, y0 = cx[j] - box // 2, cy - box // 2
        f[y0:y0 + box, x0:x0 + box] = (0, 0, 0, 90)
        cv2.rectangle(f, (x0, y0), (x0 + box, y0 + box), WHITE, 2, cv2.LINE_AA)
        cv2.line(f, (cx[j], y0), (cx[j], y0 + box), (255, 255, 255, 120), 1, cv2.LINE_AA)
        cv2.line(f, (x0, cy), (x0 + box, cy), (255, 255, 255, 120), 1, cv2.LINE_AA)
        px, py = int(cx[j] + x * box / 2), int(cy - y * box / 2)
        cv2.circle(f, (px, py), dot, RED, -1, cv2.LINE_AA); cv2.circle(f, (px, py), dot, WHITE, 2, cv2.LINE_AA)
        (tw, th), _ = cv2.getTextSize(lab, font, fs, 2)
        cv2.putText(f, lab, (cx[j] - tw // 2, y0 + box + pad // 2 + th), font, fs, WHITE, 2, cv2.LINE_AA)
    armed = arm[i] > 0.5
    txt = ("ARMED" if armed else "DISARMED") + "   MODE %d" % (1 + int(round(mode[i] * 2))) + ("   KILL" if kill[i] > 0.5 else "")
    (tw, th), _ = cv2.getTextSize(txt, font, fs * 1.1, 2)
    cv2.putText(f, txt, ((W - tw) // 2, H - pad // 2), font, fs * 1.1, RED if armed else WHITE, 2, cv2.LINE_AA)
    return f

end = a.end if a.end is not None else t[-1]
times = np.arange(a.start, end, 1.0 / a.fps)
out = a.out
tmp_overlay = None
if a.composite:
    tmp_overlay = tempfile.mktemp(suffix=".mov"); out = tmp_overlay
ext = os.path.splitext(out)[1].lower()
codec = (["-c:v", "libvpx-vp9", "-pix_fmt", "yuva420p", "-b:v", "1M", "-auto-alt-ref", "0", "-deadline", "realtime", "-cpu-used", "8", "-row-mt", "1"] if ext == ".webm"
         else ["-c:v", "prores_ks", "-profile:v", "4444", "-pix_fmt", "yuva444p10le"])
p = subprocess.Popen([FF, "-y", "-loglevel", "error", "-f", "rawvideo", "-pix_fmt", "bgra", "-s", f"{W}x{H}",
                      "-r", str(a.fps), "-i", "-"] + codec + [out], stdin=subprocess.PIPE)
for tf in times:
    p.stdin.write(frame(min(np.searchsorted(t, tf), len(t) - 1)).tobytes())
p.stdin.close(); p.wait()
print("overlay: %d frames, %.1f s" % (len(times), len(times) / a.fps))

if a.composite:
    pos = {"br": "W-w-20:H-h-20", "bl": "20:H-h-20", "tr": "W-w-20:20", "tl": "20:20"}[a.corner]
    subprocess.run([FF, "-y", "-loglevel", "error", "-i", a.composite, "-itsoffset", str(a.offset), "-i", tmp_overlay,
                    "-filter_complex", f"[1:v]scale=-1:ih*0.5[o];[0:v][o]overlay={pos}:eof_action=pass",
                    "-c:v", "libx264", "-crf", "20", "-preset", "veryfast", "-c:a", "copy", a.out], check=True)
    os.remove(tmp_overlay)
print("written", a.out)
