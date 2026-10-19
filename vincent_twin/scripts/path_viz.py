#!/usr/bin/env python3
"""Paths for RViz (fixed frame 'map' = OptiTrack/Gazebo world):
  /viz/path_real      real drone, OptiTrack ground truth (/optitrack/pose)
  /viz/path_sim       SITL twin, Gazebo ground truth (/gazebo/model_states, model vincent_vision)
  /viz/path_ref_real  setpoints sent to the real drone (/vincent/mavros/setpoint_raw/local, local = world)
  /viz/path_ref_sim   setpoints sent to the SITL twin (/sim/mavros/setpoint_raw/local + /sim/spawn_offset)
Publish std_msgs/Empty on /viz/clear to reset all paths."""
import rospy
from std_msgs.msg import Empty, Header
from nav_msgs.msg import Path
from geometry_msgs.msg import PoseStamped
from gazebo_msgs.msg import ModelStates
from mavros_msgs.msg import PositionTarget


class PathViz:
    def __init__(self):
        self.min_dt = 1.0 / rospy.get_param("~rate", 10.0)
        self.max_len = rospy.get_param("~max_len", 6000)
        self.sim_model = rospy.get_param("~sim_model", "vincent_vision")
        self.paths, self.pubs, self.last = {}, {}, {}
        for k in ["real", "sim", "ref_real", "ref_sim"]:
            p = Path(); p.header.frame_id = "map"
            self.paths[k] = p
            self.pubs[k] = rospy.Publisher("/viz/path_" + k, Path, queue_size=1, latch=True)
            self.last[k] = 0.0
        rospy.Subscriber("/optitrack/pose", PoseStamped, lambda m: self.add("real", m.pose.position.x, m.pose.position.y, m.pose.position.z), queue_size=10)
        rospy.Subscriber("/gazebo/model_states", ModelStates, self.cb_sim, queue_size=1)
        rospy.Subscriber("/vincent/mavros/setpoint_raw/local", PositionTarget, lambda m: self.add("ref_real", m.position.x, m.position.y, m.position.z), queue_size=10)
        rospy.Subscriber("/sim/mavros/setpoint_raw/local", PositionTarget, self.cb_ref_sim, queue_size=10)
        rospy.Subscriber("/viz/clear", Empty, self.clear, queue_size=1)
        # draw only during trajectories: /started_publishing_vel carries the start stamp (first ~30 msgs of a run)
        # and the end stamp (~30 msgs after it); stamp 0 in between. New non-zero stamp = toggle.
        self.only_traj = rospy.get_param("~only_trajectory", True)
        self.in_traj = not self.only_traj
        self.last_mark = None
        self._pub_t = {}
        self._off, self._off_t = [0.0, 0.0, 0.0], 0.0
        rospy.Subscriber("/started_publishing_vel", Header, self.cb_mark, queue_size=50)

    def cb_sim(self, m):
        if self.sim_model in m.name:
            p = m.pose[m.name.index(self.sim_model)].position
            self.add("sim", p.x, p.y, p.z)

    def cb_mark(self, m):
        st = m.stamp.to_sec()
        if st == 0.0 or st == self.last_mark:
            return
        self.last_mark = st
        if self.only_traj:
            self.in_traj = not self.in_traj
            rospy.loginfo("trajectory %s", "start" if self.in_traj else "end")

    def cb_ref_sim(self, m):
        now = rospy.get_time()
        if now - self._off_t > 1.0:
            self._off = rospy.get_param("/sim/spawn_offset", [0.0, 0.0, 0.0]); self._off_t = now
        off = self._off
        self.add("ref_sim", m.position.x + off[0], m.position.y + off[1], m.position.z + off[2])

    def add(self, k, x, y, z):
        if not self.in_traj:
            return
        now = rospy.get_time()
        if now - self.last[k] < self.min_dt:
            return
        self.last[k] = now
        ps = PoseStamped(); ps.header.frame_id = "map"; ps.header.stamp = rospy.Time.now()
        ps.pose.position.x, ps.pose.position.y, ps.pose.position.z = x, y, z
        ps.pose.orientation.w = 1.0
        p = self.paths[k]
        p.poses.append(ps)
        if len(p.poses) > self.max_len:
            del p.poses[0]
        p.header.stamp = ps.header.stamp
        if now - self._pub_t.get(k, 0.0) > 0.5:      # publish each path at 2 Hz (full path republish is heavy)
            self._pub_t[k] = now
            self.pubs[k].publish(p)

    def clear(self, _):
        for k, p in self.paths.items():
            p.poses = []
            self.pubs[k].publish(p)
        rospy.loginfo("paths cleared")


if __name__ == "__main__":
    rospy.init_node("path_viz")
    PathViz()
    rospy.spin()
