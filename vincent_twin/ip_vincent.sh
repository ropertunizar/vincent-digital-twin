# Laptop: source in every ROS terminal. ROS master now runs on the laptop.
export ROS_MASTER_URI=http://192.168.0.108:11311
export ROS_IP=192.168.0.108
export ROS_HOSTNAME=192.168.0.108
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$HOME/catkin_ws/src/vincent_twin/models:$HOME/catkin_ws/src/PX4/PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic/models
export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:/home/jdeese/catkin_ws/src/PX4/PX4-Autopilot/build/px4_sitl_default/build_gazebo-classic
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/jdeese/catkin_ws/src/PX4/PX4-Autopilot/build/px4_sitl_default/build_gazebo-classic
export PX4_HOME_LAT=41.68631
export PX4_HOME_LON=-0.8879
export PX4_HOME_ALT=200
