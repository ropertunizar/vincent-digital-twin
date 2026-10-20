# Stick overlay for flight videos

Shows the pilot's RC sticks (two gimbals) plus ARMED / MODE / KILL on top of a flight video.

## 1. Before the session (once per startup)
- `twin_bringup.launch` runs `rc_stream_request.py`, which asks PX4 to stream the sticks (`RC_CHANNELS`, 20 Hz) every time the drone (re)connects. Check: `rostopic hz /vincent/mavros/rc/in` → ~20 Hz.
- MATLAB runs already record `<ns>/mavros/rc/in` (see `matlab/config/CONFIGS_MULTIRUN_ROS.m`).

## 2. Record a manual session
```bash
rosrun vincent_twin record_manual.sh wall      # -> ~/bags/<date>/wall_<time>.bag ; Ctrl-C after landing
```
Start OBS (and/or the camera) after the bag. Arm the drone **on camera**: the arming is the sync point.

## 3. Find the sync point in the video
Open the OBS recording in any player and note the second where the drone **arms** (the Mirror's propellers start spinning in Gazebo / the motors start on the camera). Example: 4.0 s.

## 4. Render
**Burned into the video (one command, synced automatically):**
```bash
python3 ~/catkin_ws/src/vincent_twin/scripts/rc_overlay.py <bag> out.mp4 --composite "<obs video>" --arm-obs-at 4.0
```
The script finds the arming in the bag (PX4 armed state), shifts the sticks so both coincide, and puts the overlay bottom-right at half size (`--corner br|bl|tr|tl`). The ARMED indicator turns red at the same moment the propellers start.
- Several armings in one bag: `--list-arms` prints them, `--arm-n 2` picks the second.
- Only a part: `--start 10 --end 60` (seconds of stick data).

**As a separate transparent clip (for an editor):**
```bash
python3 ~/catkin_ws/src/vincent_twin/scripts/rc_overlay.py <bag> sticks.webm      # small, VP9 + alpha
python3 ~/catkin_ws/src/vincent_twin/scripts/rc_overlay.py <bag> sticks.mov       # ProRes 4444 + alpha (large)
```
In **Kdenlive**: OBS video on V1, `sticks.webm` on V2. Add a clip marker at the arming frame in both (Clip Monitor → right-click → Markers → Add Marker; a shortcut such as **M** can be assigned in Settings → Configure Keyboard Shortcuts), enable snapping and drag V2 until the markers snap. Scale/position with the Transform effect, then Render → MP4 (H.264/AAC).

## Requirements
`pip install rosbags numpy opencv-python-headless imageio-ffmpeg` (the script uses a static ffmpeg from `imageio-ffmpeg` if the system one is missing or broken).

## Channel map
`RC_MAP_*`: yaw 1, throttle 2 (reversed), roll 3, pitch 4, arm 5, mode 6, kill 8. Change with `--map` / `--rev` for another radio.
