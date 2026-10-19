# Running the Digital twin (PX4 SITL) next to the real drone

## What runs where
| Terminal | Command (each starts with `source ~/catkin_ws/src/vincent_twin/ip_vincent.sh &&`) |
|---|---|
| Roscore | `roscore` |
| NanoPi | `ssh root@192.168.0.7` → wait for `CON: Got HEARTBEAT, connected` |
| OptiTrack | `roslaunch optitrack_arena vincent_optitrack.launch` |
| Gazebo-twin | `roslaunch vincent_twin twin_bringup.launch` (arena, mirror, virtual wall) |
| SITL | `roslaunch vincent_twin sitl_vincent.launch` (real drone on its take-off spot) |
| RViz | `roslaunch vincent_twin twin_rviz.launch` |

SITL only (no real drone): skip NanoPi/OptiTrack; `sitl_vincent.launch` then falls back to `x:=` / `y:=` (no OptiTrack pose).

## What `sitl_vincent.launch` does
1. Starts PX4 SITL **instance 1** (`-i 1`): MAV_SYS_ID 2, onboard UDP 14581 → 14541, QGC UDP 18571 → 14550, Gazebo TCP **4561**. Working dir `~/.ros/sitl_vincent_1` (parameters persist there).
2. `PX4_SIM_MODEL=gazebo-classic_iris` → airframe 10015 (quad X). Without it PX4 starts its internal SIH simulator and never connects to Gazebo.
3. `spawn_sim_from_real.py`: reads `/optitrack/pose`, spawns `vincent_sim` (Gazebo name `vincent_vision`) at real (x, y) + (dx, dy) = (−1, 0), yaw 0; publishes `/sim/spawn_offset` and `/sim/traj_offset`.
4. MAVROS in `/sim` (`udp://:14541@127.0.0.1:14581`, target sysid 2).
5. Scan relay `/vincent_sim/scan` → `/sim/mavros/obstacle/send` (rate-limited 20 Hz wall clock).

Expected log: `Real drone at (x, y) -> SITL spawn (…)`, `Spawn: True`, then `Simulator connected on TCP port 4561`, `Ready for takeoff!`.

## One-time SITL configuration (persists in `~/.ros/sitl_vincent_1`)
Estimator like the real drone (vision only), in QGC → Vehicle 2 → MAVLink console:
```
param set EKF2_EV_CTRL 11
param set EKF2_HGT_REF 3
param set EKF2_GPS_CTRL 0
param set SYS_HAS_GPS 0
param set EKF2_MAG_TYPE 5
param set EKF2_EV_DELAY 0
param save
```
Controller identical to the real drone (64 MC_*/MPC_* params):
```bash
rosrun mavros mavparam -n sim/mavros load -qgc config/px4_params/sitl_from_real_controller_nocomments.params
```
then `param save` on Vehicle 2.

## Digital twin failsafes and battery (set once, `param save`)
| Param | Value | Why |
|---|---|---|
| `NAV_RCL_ACT` | 3 (Land) | SITL has no RC; default RTL sent it home when leaving OFFBOARD |
| `COM_OBL_RC_ACT` | 4 (Land) | offboard loss → land in place |
| `SIM_BAT_MIN_PCT` | 95 | simulated battery never triggers low-battery reactions |
| `MC_BAT_SCALE_EN` | 0 (both twins) | no thrust scaling with voltage |
Simulated mocap (vision plugin in `models/vincent_sim/model.sdf`): `randomWalk 0`, `noiseDensity 0.0005` (the PX4 default 0.01/0.01 drifts by cm per minute → shapes shift run to run).
SITL parameters persist in `~/.ros/sitl_vincent_1/parameters.bson` — deleting that folder resets the Digital twin to iris defaults. Back it up.

## SITL model calibration (`scripts/make_vincent_sim.sh` + edits in `models/vincent_sim_base/model.sdf`)
| Quantity | Value | Source |
|---|---|---|
| Mass | 2.15 kg | measured with battery (CAD SDF had 1.5 kg = dry) |
| Inertia | CAD × 1.43 (ixx = iyy 0.041737, izz 0.079139) | mass ratio, to be recomputed |
| motorConstant | 2.07e-05 (≈ 25 N/motor at maxRotVelocity 1100) | V2812 925KV + 9×4 @ ~23 V estimate; iris value 5.84e-06 cannot lift 2.15 kg |
| Ports | TCP 4561 / UDP 14561 | instance 1 |
| Laser | forward ±45°, 19 beams, 20 Hz, 3 m | same as the mirror |

## Rules / troubleshooting
| Symptom | Cause | Fix |
|---|---|---|
| `INFO [init] SIH simulator`, missing baro/mag | no airframe (`PX4_SIM_MODEL` unset) | env line in the launch (already there) |
| `simulator_mavlink poll timeout` | PX4 connected to a dead socket / Gazebo crashed | restart **Gazebo-twin**, then SITL |
| Gazebo `Segmentation fault` on spawn | re-spawning a PX4 model into a running Gazebo | always fresh Gazebo-twin before SITL |
| NanoPi `TX queue overflow`, no heartbeat | obstacle scan flood (lockstep sped up Gazebo clock) | relay rate limit (already in) |
| SITL spins props but doesn't lift | mass vs motorConstant mismatch | calibrated values above |
| SITL turns 180° and skids at take-off | spawned at yaw π; hub commands yaw 0 | spawn facing +x (default) |
| `Updating ModelState: model does not exist` | world and model with the same name | world is `vincent_twin_world` |
| Real drone: Position → Hold, "sysid mismatch" in QGC | both vehicles on QGC UDP 14550 | restart; separate ports (open item) |
| Real drone: sticks act "mirrored" | Collision Prevention with forward scan + SITL nearby | `CP_DIST -1` on the real drone for trajectory runs |
| MATLAB: `rosparam` returns cell | ROS list → MATLAB cell | `cell2mat` (already in) |
| Digital twin flies home after a run | RC-loss failsafe = RTL (no RC in SITL) | `NAV_RCL_ACT 3` |
| Digital twin drifts during AUTO.LAND ("PositionTargetGlobal failed because no origin") | no global origin in SITL | land with an OFFBOARD descent, or set a GPS origin |
| Drone briefly drops to Land between runs | gap in OFFBOARD setpoints > timeout | keep streaming setpoints between runs |
| rosbag 4 KB / recorder node gone | disk full | keep > 5 GB free (`rosclean purge`, `~/.cache`) |
| Digital twin shapes shift run to run | vision plugin random walk | `randomWalk 0` (see above) |
| Gazebo RTF < 0.95 | GPU/CPU load (Firefox, QGC map, OBS software encoder) | close them; OBS with FFmpeg VAAPI |

## MATLAB runs
`01_MultiRun_Ros/00_CONFIGS/CONFIGS_MULTIRUN_ROS.m`:
| Target | `ns` | `spawn_offset` | `auto_arm` | `simulation` (MULTIRUNS_ROS.m) |
|---|---|---|---|---|
| Digital twin (PX4 SITL) | `'/sim'` | read from `/sim/spawn_offset` − `/sim/traj_offset` | true | true |
| Real drone | `'/vincent'` | `[0 0 0]` | true (pilot override) | false |

Run `clear functions` before each `MULTIRUNS_ROS`. Real drone: start facing +x; mode switch or sticks (> 30%, `COM_RC_OVERRIDE 3`) take over.
