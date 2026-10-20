#!/usr/bin/env python3
"""Render the RC sticks from a rosbag as a transparent overlay video (two gimbals + ARM / MODE / KILL).
Usage: python3 rc_overlay.py run.bag out.mov [--ns /vincent] [--fps 30] [--start S] [--end S]
Needs: pip install rosbags numpy matplotlib ; ffmpeg.  Output: ProRes 4444 with alpha (.mov), ready for any editor.
Channel map (RC_MAP_*): yaw 1, throttle 2, roll 3, pitch 4, arm 5, mode 6, kill 8. Throttle reversed (high PWM = low)."""
import argparse, os, subprocess, tempfile
import numpy as np, matplotlib
matplotlib.use("Agg"); import matplotlib.pyplot as plt
from pathlib import Path
from rosbags.highlevel import AnyReader
from rosbags.typesys import Stores, get_typestore, get_types_from_msg

ap = argparse.ArgumentParser()
ap.add_argument("bag"); ap.add_argument("out"); ap.add_argument("--ns", default="/vincent")
ap.add_argument("--fps", type=int, default=30); ap.add_argument("--start", type=float, default=0.0); ap.add_argument("--end", type=float, default=None)
ap.add_argument("--pwm-min", type=float, default=982); ap.add_argument("--pwm-max", type=float, default=2005)
ap.add_argument("--map", default="yaw=1,thr=2,roll=3,pitch=4,arm=5,mode=6,kill=8")
ap.add_argument("--rev", default="thr", help="comma list of reversed axes")
a = ap.parse_args()
M = {k: int(v) - 1 for k, v in (s.split("=") for s in a.map.split(","))}
REV = set(x for x in a.rev.split(",") if x)

t, ch = [], []
TS = get_typestore(Stores.ROS1_NOETIC)
TS.register(get_types_from_msg("std_msgs/Header header\nuint8 rssi\nuint16[] channels\n", "mavros_msgs/msg/RCIn"))
with AnyReader([Path(a.bag)], default_typestore=TS) as r:
    conns = [c for c in r.connections if c.topic == a.ns + "/mavros/rc/in"]
    if not conns: raise SystemExit("no %s/mavros/rc/in in the bag" % a.ns)
    for c, ts, raw in r.messages(connections=conns):
        m = r.deserialize(raw, c.msgtype); t.append(ts * 1e-9); ch.append(list(m.channels))
t = np.array(t); t -= t[0]; ch = np.array(ch, float)
def norm(k):  # -1..1
    x = (ch[:, M[k]] - a.pwm_min) / (a.pwm_max - a.pwm_min) * 2 - 1
    return -x if k in REV else x
yaw, thr, roll, pitch = norm("yaw"), norm("thr"), norm("roll"), norm("pitch")
sw = lambda k: (ch[:, M[k]] - a.pwm_min) / (a.pwm_max - a.pwm_min)
arm, mode, kill = sw("arm"), sw("mode"), sw("kill")
end = a.end if a.end is not None else t[-1]
frames = np.arange(a.start, end, 1.0 / a.fps)
tmp = tempfile.mkdtemp()
fig = plt.figure(figsize=(6.4, 3.2), dpi=150); fig.patch.set_alpha(0)
for n, tf in enumerate(frames):
    i = min(np.searchsorted(t, tf), len(t) - 1)
    fig.clf(); fig.patch.set_alpha(0)
    for j, (x, y, lab) in enumerate([(yaw[i], thr[i], "YAW / THR"), (roll[i], pitch[i], "ROLL / PITCH")]):
        ax = fig.add_axes([0.04 + 0.5 * j, 0.18, 0.42, 0.78]); ax.set_xlim(-1.15, 1.15); ax.set_ylim(-1.15, 1.15); ax.axis("off")
        ax.add_patch(plt.Rectangle((-1, -1), 2, 2, fill=True, fc=(0, 0, 0, 0.35), ec="white", lw=1.5))
        ax.plot([-1, 1], [0, 0], color="white", lw=0.5, alpha=0.5); ax.plot([0, 0], [-1, 1], color="white", lw=0.5, alpha=0.5)
        ax.plot(x, y, "o", ms=16, mfc="#ff3b30", mec="white", mew=1.5)
        ax.text(0, -1.1, lab, color="white", ha="center", va="top", fontsize=9, fontweight="bold")
    s = "ARMED" if arm[i] > 0.5 else "DISARMED"
    md = "MODE %d" % (1 + int(round(mode[i] * 2)))
    k = "KILL" if kill[i] > 0.5 else ""
    fig.text(0.5, 0.04, f"{s}   {md}   {k}", color="#ff3b30" if s == "ARMED" else "white", ha="center", fontsize=10, fontweight="bold")
    fig.savefig(os.path.join(tmp, "f%06d.png" % n), transparent=True)
subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-framerate", str(a.fps), "-i", os.path.join(tmp, "f%06d.png"),
                "-c:v", "prores_ks", "-profile:v", "4444", "-pix_fmt", "yuva444p10le", a.out], check=True)
print("written", a.out, "%d frames, %.1f s" % (len(frames), len(frames) / a.fps))
