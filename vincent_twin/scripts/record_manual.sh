#!/bin/bash
# Record a MANUAL session (pilot on the sticks): sticks, state, poses, virtual scan.
# Usage: record_manual.sh [name]   -> ~/bags/YYYY-MM-DD/<name>_HH-MM-SS.bag   (Ctrl-C to stop)
NS=${NS:-/vincent}
D=~/bags/$(date +%F); mkdir -p "$D"; cd "$D"
NAME=${1:-manual}_$(date +%H-%M-%S)
if ! timeout 3 rostopic echo -n1 $NS/mavros/rc/in >/dev/null 2>&1; then
  echo "!!! no stick data on $NS/mavros/rc/in - is twin_bringup (rc_stream_request) running and the drone connected?"
fi
echo "Recording $D/$NAME.bag  (Ctrl-C to stop)"
exec rosbag record -O "$NAME.bag" \
  $NS/mavros/rc/in $NS/mavros/state $NS/mavros/local_position/pose $NS/mavros/setpoint_raw/target_local \
  $NS/mavros/obstacle/send /vincent_twin/scan /optitrack/pose
