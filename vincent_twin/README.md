# vincent_twin (ROS 1 package)

Gazebo-side of the digital twin: the world, the mirror of the real drone, the PX4 Digital twin (PX4 SITL), the virtual sensors and the tools to visualise and measure.

## Launch files
| Launch | Starts | Main args |
|---|---|---|
| `twin_bringup.launch` | Gazebo (`worlds/vincent_twin.world`), `twin_mirror.py`, `scan_frd_relay.py` (mirror scan → real drone) | `pose_topic` (`/optitrack/pose`), `off_x/off_y/off_z/off_yaw` (mirror offset, `off_z = -0.136`), `flip_scan` (true), `gui` |
| `sitl_vincent.launch` | PX4 SITL instance 1 (`/sim`), `spawn_sim_from_real.py`, MAVROS `/sim`, SITL scan relay | `dx` (-1.0), `dy` (0), `Y` (0), `x`/`y` (fallback spawn), `scan_to_cp`, `ID` (1) |
| `twin_rviz.launch` | `path_viz.py` + RViz (`rviz/twin.rviz`) | — |
| `vincent_optitrack.launch` | VRPN client + `optitrack_pose_tf` (belongs to the lab package `optitrack_arena`; cleaned copy kept here) | `server` (Motive IP) |

Start order: Gazebo-twin **before** SITL. Restarting Gazebo-twin means relaunching SITL.

## Nodes (`scripts/`)
| Node | In | Out | Notes |
|---|---|---|---|
| `twin_mirror.py` | `/optitrack/pose` (PoseStamped) | `/gazebo/set_model_state` (model `vincent_twin`) | kinematic mirror; params `pose_topic`, `model_name`, `off_*` |
| `scan_frd_relay.py` | `scan_in` (LaserScan, ROS CCW) | `scan_out` → `/<ns>/mavros/obstacle/send` | flips to MAVLink CW (`flip`), **no-hit → range_max + 1 cm** ("free"), **wall-clock rate limit** `max_rate` (20 Hz) |
| `spawn_sim_from_real.py` | `/optitrack/pose` (once) | spawns SITL model; params `/sim/spawn_offset`, `/sim/traj_offset` | spawn = real (x, y) + (dx, dy), yaw `Y`; fallback `x/y` |
| `path_viz.py` | `/optitrack/pose`, `/gazebo/model_states`, `/vincent/…/setpoint_raw/local`, `/sim/…/setpoint_raw/local` | `/viz/path_real`, `/viz/path_ref_real`, `/viz/path_sim`, `/viz/path_ref_sim` | world frame `map`; clear with `rostopic pub -1 /viz/clear std_msgs/Empty`; 10 Hz points, 2 Hz publish |
| `delay_xcorr.py` | rosbag | stdout | real → mirror delay by cross-correlation of 3D speed (`rosrun vincent_twin delay_xcorr.py run.bag`) |
| `make_vincent_sim.sh` | PX4 models `vincent`, `vincent_vision` | `models/vincent_sim_base`, `models/vincent_sim` | generates SITL copies (ports 4561/14561, laser); mass/inertia/motor calibration then applied in `vincent_sim_base` |

## Models (`models/`)
| Model | Role | Physics | Sensors |
|---|---|---|---|
| `vincent_twin` | **mirror** of the real drone (to be renamed `vincent_mirror`) | kinematic, no gravity, **no collision** | forward ray ±45°, 19 beams, 20 Hz, 0.3–3 m → `/vincent_twin/scan` |
| `vincent_sim` / `vincent_sim_base` | **Digital twin (PX4 SITL)** (Gazebo name `vincent_vision`) | 2.15 kg, inertia CAD × 1.43, `motorConstant` 2.07e-05 | IMU/baro/mag/vision plugins (PX4), forward ray → `/vincent_sim/scan` |
| `UZ_arena_twin` | arena SfM mesh | **visual only** (no collision → invisible to lasers) | — |

## World (`worlds/vincent_twin.world`, name `vincent_twin_world`)
- Scene + lights copied from the paper world `UZ_arena.world` (sun + 2 point lights, ambient 0.4).
- `ground_collision`: invisible collision-only plane (drones stand on z = 0; the mesh floor stays visible).
- `UZ_arena_twin` at `0.000054 0 -0.009488 0 -0.005698 0` (+ inner visual pose `3.5 0 -0.10 0 0 -1.57` from `arena.urdf`).
- `vincent_twin` (mirror) and `virtual_wall` (static box 0.05 × 3 × 2 m at `6 -0.28 1.0`).
- The world must not share a name with any model (Gazebo's `ModelByName` would return the world).

## Frames
- `map` / Gazebo world = OptiTrack frame (ENU, metres). The real drone's PX4 local frame = this frame.
- SITL local frame: origin at its spawn point, axes aligned with the world → setpoint to SITL = world point − `/sim/spawn_offset` (+ `/sim/traj_offset` to fly the shape 1 m behind).
- Mirror pivot = OptiTrack rigid-body pivot (moved onto the flight controller) → `off_z = -0.136` puts the feet on z = 0.

## Environment
`ip_vincent.sh` (source in every terminal): ROS master on the laptop, Gazebo model/plugin paths, `PX4_HOME_*` (arena).
