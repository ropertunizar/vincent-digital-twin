#!/usr/bin/env python3
"""Real -> twin delay from a rosbag recorded on the laptop (same clock).
Usage: delay_xcorr.py run.bag [--model vincent_twin] [--max-lag 0.5]
Uses bag receive times of /optitrack/pose and /gazebo/model_states.
Cross-correlates the 3D speed (rotation/offset invariant), reports lag, rates and jitter."""
import argparse
import numpy as np
import rosbag


def series(bag, topic, model=None):
    t, p = [], []
    for _, msg, bt in bag.read_messages(topics=[topic]):
        if model is None:
            pos = msg.pose.position
        else:
            if model not in msg.name:
                continue
            pos = msg.pose[msg.name.index(model)].position
        t.append(bt.to_sec())
        p.append((pos.x, pos.y, pos.z))
    return np.array(t), np.array(p)


def rate_jitter(t):
    dt = np.diff(t)
    return 1.0 / np.mean(dt), np.std(dt) * 1e3


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("bag")
    ap.add_argument("--model", default="vincent_twin")
    ap.add_argument("--max-lag", type=float, default=0.5)
    ap.add_argument("--fs", type=float, default=1000.0)
    a = ap.parse_args()

    with rosbag.Bag(a.bag) as bag:
        tr, pr = series(bag, "/optitrack/pose")
        tt, pt = series(bag, "/gazebo/model_states", a.model)

    # model_states repeats the last pose between mirror updates: keep only changes
    keep = np.r_[True, np.any(np.diff(pt, axis=0) != 0, axis=1)]
    tt, pt = tt[keep], pt[keep]

    t0, t1 = max(tr[0], tt[0]), min(tr[-1], tt[-1])
    g = np.arange(t0, t1, 1.0 / a.fs)
    r = np.column_stack([np.interp(g, tr, pr[:, i]) for i in range(3)])
    w = np.column_stack([np.interp(g, tt, pt[:, i]) for i in range(3)])
    sr = np.linalg.norm(np.gradient(r, axis=0), axis=1) * a.fs
    sw = np.linalg.norm(np.gradient(w, axis=0), axis=1) * a.fs
    sr, sw = sr - sr.mean(), sw - sw.mean()

    n = int(a.max_lag * a.fs)
    lags = np.arange(-n, n + 1)
    cc = [np.dot(sr[: len(sr) - k], sw[k:]) if k >= 0 else np.dot(sr[-k:], sw[: len(sw) + k]) for k in lags]
    best = lags[int(np.argmax(cc))] / a.fs

    fr, jr = rate_jitter(tr)
    ft, jt = rate_jitter(tt)
    print(f"real -> twin delay (xcorr, 3D speed): {best*1e3:.1f} ms")
    print(f"/optitrack/pose        : {fr:.1f} Hz, jitter {jr:.1f} ms")
    print(f"twin pose updates      : {ft:.1f} Hz, jitter {jt:.1f} ms")
    print(f"window: {t1 - t0:.1f} s")


if __name__ == "__main__":
    main()
