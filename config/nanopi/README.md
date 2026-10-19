# NanoPi NEO Air (companion computer)

- MAVROS to the Pixhawk 6C over **TELEM2** (`/dev/ttyS1`, 115200), namespace **`/vincent`**, target sysid 1.
- GCS bridge: `udp://@192.168.0.108:14550` (QGC on the laptop). Planned: move to 14560 to separate it from the SITL (QGC cross-talk).
- ROS master on the **laptop** (`roslaunch --wait` waits for it); the NanoPi loses power at every battery swap.
- Autostart from `/root/.bashrc` at ssh login, guarded so only one MAVROS runs (`bashrc_snippet.txt`). Note: an interactive `bash -ic` also triggers it.
- `px4_vincent.launch` → `/opt/ros/noetic/share/mavros/launch/`. Prefixed frames (`vincent/map`, `vincent/base_link`), MAVROS TF off, `obstacle/mav_frame = BODY_FRD`.
- `TM: RTT too high for timesync` warnings (125–170 ms) are normal on this link.
