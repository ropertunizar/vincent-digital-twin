cmake_minimum_required(VERSION 3.0.2)
project(vincent_twin)
find_package(catkin REQUIRED)
catkin_package()
catkin_install_python(PROGRAMS scripts/twin_mirror.py scripts/scan_frd_relay.py scripts/delay_xcorr.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION})
