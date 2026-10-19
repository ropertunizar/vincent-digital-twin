# Experiments

## Virtual wall: the twin acts on the Real drone
A wall that exists only in the Gazebo twin stops the real drone ([video](https://youtu.be/cXBxUWjQOjg)).
- The OptiTrack pose drives the Mirror in Gazebo (< 2 ms added latency on the ground station); a simulated 360° range sensor on the Mirror (72 beams, 20 Hz, 0.3–3 m) is relayed by `vincent_twin/scripts/scan_frd_relay.py` to `<ns>/mavros/obstacle/send` → PX4 Collision Prevention.
- PX4: `CP_DIST 1.0`, `CP_DELAY 0.15`, `CP_GUIDE_ANG 0`, `CP_GO_NO_DATA 0`, `MPC_POS_MODE 4`; pilot in Position mode.
- Result (2026-10-13): 6 approaches up to 0.51 m/s, never crossed the wall, stops at 1.21–1.26 m; virtual distance vs onboard estimate 8 mm RMS; obstacle information ≈ 30 ms behind the onboard state.
- Notes: a no-hit beam must be sent as range_max + 1 cm (UINT16_MAX means "no data" and blocks motion with `CP_GO_NO_DATA 0`). Use the full 360° scan: a partial field of view with `CP_GO_NO_DATA 1` distorted the stick response. Keep `CP_DIST -1` when the Digital twin flies next to the Real drone (the scan would see it).

## Trajectory pipeline: same software on the Digital twin and the Real drone
`matlab/MULTIRUNS_ROS.m` flies the Nikolaus trajectory (`matlab/trajectories/nikolaus/`) on either target by changing only the namespace; `matlab/MULTIRUN_METRICS.m` computes image-plane and 3D tracking errors from the recorded rosbags.
