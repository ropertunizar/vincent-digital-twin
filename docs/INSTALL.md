# Installation

Tested setup (laptop): **Ubuntu 20.04, ROS 1 Noetic, Gazebo Classic 11, PX4-Autopilot (SITL build), MAVROS built from source, MATLAB R2024+**.
Companion computer (drone): NanoPi NEO Air, Ubuntu 20.04, ROS Noetic, MAVROS (binary).

> Version note (2026-10-14): the real flight controller runs **PX4 v1.16.0**; the SITL build on the laptop reports **v1.15.0**. For sim-vs-real comparisons, rebuild SITL from the v1.16 tag (see open items).

## 1. ROS Noetic + Gazebo 11 (laptop)
```bash
sudo apt install ros-noetic-desktop-full          # includes Gazebo 11 + gazebo_ros
sudo apt install python3-catkin-tools python3-rosdep python3-wstool
sudo apt install ros-noetic-gazebo-plugins ros-noetic-gazebo-msgs ros-noetic-tf \
                 ros-noetic-vrpn-client-ros ros-noetic-hector-trajectory-server \
                 ros-noetic-geographic-msgs rsync git
```

## 2. MAVROS
Laptop (source build, as used here) or binary:
```bash
sudo apt install ros-noetic-mavros ros-noetic-mavros-extras ros-noetic-mavros-msgs
sudo /opt/ros/noetic/lib/mavros/install_geographiclib_datasets.sh
```
`mavros_extras` is required (vision_pose, obstacle_distance plugins). Make sure `obstacle_distance` is **not** blacklisted in `px4_pluginlists.yaml`.

## 3. PX4-Autopilot (SITL, Gazebo Classic)
Cloned inside the catkin workspace so `$(find px4)` resolves:
```bash
cd ~/catkin_ws/src && mkdir -p PX4 && cd PX4
git clone https://github.com/PX4/PX4-Autopilot.git --recursive
cd PX4-Autopilot && git checkout v1.16.0 && git submodule update --init --recursive   # match the real drone
bash ./Tools/setup/ubuntu.sh --no-nuttx
DONT_RUN=1 make px4_sitl_default gazebo-classic
```
This produces `build/px4_sitl_default/` (PX4 binary + `etc/`) and `build/px4_sitl_default/build_gazebo-classic/` (Gazebo plugins: `libgazebo_mavlink_interface.so`, `libgazebo_vision_plugin.so`, …).
The Vincent models (`vincent`, `vincent_vision`) and the arena (`UZ_arena`) go into
`Tools/simulation/gazebo-classic/sitl_gazebo-classic/models/` (copies in `px4_models/` of this repo).

## 4. This repository
```bash
cd ~/catkin_ws/src && git clone git@github.com:<user>/vincent-digital-twin.git
ln -s ~/catkin_ws/src/vincent-digital-twin/vincent_twin ~/catkin_ws/src/vincent_twin   # or copy
cd ~/catkin_ws && catkin build vincent_twin && source devel/setup.bash
bash $(rospack find vincent_twin)/scripts/make_vincent_sim.sh     # generates the SITL copies from px4_models
```
`optitrack_arena` (OptiTrack → MAVROS bridge, `optitrack_pose_tf`, `vincent_optitrack.launch`) is a separate lab package and must also be in the workspace.

## 5. Environment (`vincent_twin/ip_vincent.sh`, sourced in every terminal)
```bash
export ROS_MASTER_URI=http://192.168.0.108:11311     # laptop
export ROS_IP=192.168.0.108 ROS_HOSTNAME=192.168.0.108
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$HOME/catkin_ws/src/vincent_twin/models:$HOME/catkin_ws/src/PX4/PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic/models
export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:$HOME/catkin_ws/src/PX4/PX4-Autopilot/build/px4_sitl_default/build_gazebo-classic
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/catkin_ws/src/PX4/PX4-Autopilot/build/px4_sitl_default/build_gazebo-classic
export PX4_HOME_LAT=41.68631 PX4_HOME_LON=-0.8879 PX4_HOME_ALT=200   # arena (simulated GPS home)
```

## 6. Companion computer (NanoPi)
```bash
sudo apt install ros-noetic-mavros ros-noetic-mavros-extras
sudo /opt/ros/noetic/lib/mavros/install_geographiclib_datasets.sh
cp config/nanopi/px4_vincent.launch /opt/ros/noetic/share/mavros/launch/
```
Autostart (`/root/.bashrc`, see `config/nanopi/bashrc_snippet.txt`):
```bash
export ROS_MASTER_URI=http://192.168.0.108:11311
export ROS_IP=192.168.0.7
if ! pgrep -f mavros_node >/dev/null; then roslaunch --wait mavros px4_vincent.launch; fi
```
Passwordless ssh from the laptop: `ssh-copy-id root@192.168.0.7`.

## 7. MATLAB (Autonomy Hub)
Toolboxes: **ROS Toolbox**, **Optimization Toolbox** (`quadprog`), Signal Processing (metrics). The MathWorks UAV example helpers are **not** needed (local `exampleHelperUAVTakeOff.m` / `exampleHelperUAVLand.m`).
```matlab
addpath(genpath('<repo>/matlab'));   % or in startup.m
```
Trajectories live in `matlab/trajectories/<name>/` (paths are repo-relative); run `startup` once.

## 8. Analysis (Python)
```bash
pip install pyulog rosbags numpy scipy matplotlib
```
