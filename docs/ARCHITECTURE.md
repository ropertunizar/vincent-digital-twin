# Architecture

## Components
- **Real drone**: Vincent (X500 V2, Pixhawk 6C PX4 1.16, NanoPi MAVROS). Localisation: OptiTrack → VRPN → `optitrack_pose_tf` (12 Hz) → MAVROS vision_pose → EKF2 (delay 125 ms).
- **Mirror**: kinematic copy of the real drone in Gazebo, driven by `/optitrack/pose` (~53 Hz), carrying virtual sensors.
- **Digital twin**: PX4 SITL instance 1 in the same Gazebo world, simulated mocap (vision plugin), vision-only EKF, real controller gains, calibrated mass/thrust.
- **Ground station (laptop)**: ROS master, Gazebo, MATLAB Autonomy Hub, QGC, RViz.

## Data paths
| Path | Route | Rate / latency |
|---|---|---|
| Real pose → mirror | Motive → VRPN `/optitrack/pose` → `twin_mirror.py` → Gazebo | ~53 Hz, < 2 ms laptop side |
| Real pose → PX4 | `/optitrack/pose` → `optitrack_pose_tf` → `/vincent/mavros/vision_pose/pose` → WiFi → NanoPi → serial | 12 Hz, 125 ms (EKF2_EV_DELAY) |
| Twin → real (virtual obstacle) | mirror ray → `scan_frd_relay.py` → `/vincent/mavros/obstacle/send` → PX4 CP | 20 Hz, ≈ 30 ms behind EKF state |
| Hub → drones | MATLAB → `/<ns>/mavros/setpoint_raw/local` | 1/dt (10 Hz Nikolaus) |
| SITL ↔ Gazebo | MAVLink TCP 4561 (lockstep) | sim rate |

## Ports and IDs
| | Real | SITL |
|---|---|---|
| MAVLink sysid | 1 | 2 |
| MAVROS | `/vincent`, serial `/dev/ttyS1:115200` | `/sim`, `udp://:14541@127.0.0.1:14581` |
| QGC | via MAVROS GCS bridge → 14550 | UDP 18571 → 14550 |
| Gazebo | — | TCP 4561 |

## Naming (planned rename)
`/vincent` → `/vincent_real`, `/sim` → `/vincent_sim`, mirror model `vincent_twin` → `vincent_mirror`.
