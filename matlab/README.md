# MATLAB — trajectory publisher and metrics

Flies an exported trajectory on the **Real drone** or the **Digital twin** through ROS/MAVROS, and evaluates the flights.

```
MULTIRUNS_ROS.m        main: take-off → fly to start → N runs of the trajectory → land; records a rosbag
MULTIRUN_METRICS.m     metrics from recorded runs (image-plane and 3D RMSE, max error, velocity errors)
startup.m              adds all folders to the MATLAB path (run once, or from your startup)
config/                CONFIGS_MULTIRUN_ROS.m (target, trajectory, take-off), CONFIGS_MULTIRUN_METRICS.m
ros/                   ROS environment and handles, data preparation, setpoint publishers, rosbag recording
commands/              take-off, fly-to, hover, land (with pilot-override-aware arming helper)
metrics/               metric functions and rosbag loaders
trajectories/nikolaus/ example trajectory (Nikolaus)
```

## Trajectory format
One folder per trajectory in `trajectories/<name>/`:
| File | Content |
|---|---|
| `q.txt`, `qd.txt`, `qdd.txt` | 3×N position, velocity, acceleration (comma separated) |
| `tvec.txt` | 1×N time vector [s] |
| `initial_position.txt` | start point |
Any trajectory generator that writes these files can be used. Axes: generator `(q1, q2, q3)` → arena `(x, y, z) = (q2, −q1, q3)`.

## Use
1. `startup` (adds the paths).
2. In `config/CONFIGS_MULTIRUN_ROS.m`: `load_folder_name = "nikolaus"` (trajectory folder), target namespace `ns` (`'/vincent'` Real drone, `'/sim'` Digital twin), `spawn_offset`, `auto_arm`.
3. `MULTIRUNS_ROS` — setpoints `mavros_msgs/PositionTarget` on `<ns>/mavros/setpoint_raw/local` (`message_mask`: 1 pos, 2 vel, 3 pos+vel, 4 pos+vel+acc). Rosbag and logs are written next to the trajectory (`03_rosbag/`, `99_log/`, not tracked by git).
4. `MULTIRUN_METRICS` on the recorded runs.

Real drone: start facing +x; the RC mode switch or sticks (> 30 %, `COM_RC_OVERRIDE 3`) take over at any time.
Toolboxes: ROS Toolbox, Signal Processing.
