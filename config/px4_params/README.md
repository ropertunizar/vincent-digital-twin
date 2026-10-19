# PX4 parameter files
| File | For | Content |
|---|---|---|
| `20261013_vincent_pixhawk6c_collisionavoidance.params` | real drone (if present) | full set: indoor vision EKF (`EKF2_EV_CTRL 11`, `EKF2_EV_DELAY 125`, `EKF2_HGT_REF 3`, `SYS_HAS_GPS 0`), autotuned rates, CP params of the wall experiment |
| `sitl_from_real_controller.params` | Digital twin (PX4 SITL) (vehicle 2) | 64 controller params (MC_*, MPC_*) copied from the real drone; load in QGC or `mavparam load -qgc` (use the `_nocomments` file) |

Real-drone state after 2026-10-14: `CP_DIST -1` (CP off for trajectory runs), `CP_GO_NO_DATA 1`, `COM_RC_OVERRIDE 3`, `EKF2_EV_POS_Z -0.013` (OptiTrack pivot on the FC). Save a fresh full param file before each campaign.
