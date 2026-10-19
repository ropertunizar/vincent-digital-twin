# PX4 Gazebo models (originals)
Copies of the models inside `PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic/models/`:
- `vincent` — Vincent quad (body STL + iris props, motor plugins, MAVLink interface TCP 4560). CAD mass 1.5 kg (dry).
- `vincent_vision` — wrapper: `vincent` + vision plugin (simulated motion capture, 30 Hz, noise 0.01).
- `UZ_arena` — arena SfM mesh (`UZ_Arena_cleaner_lowpoly.dae` + textures), `arena.urdf` (pose 3.5 0 −0.05, yaw −1.57).

Install: copy into the PX4 models folder. `vincent_twin/scripts/make_vincent_sim.sh` builds the SITL copies from these.
