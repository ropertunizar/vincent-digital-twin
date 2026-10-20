#!/usr/bin/env python3
"""Mirror the real drone's OptiTrack pose onto the Gazebo model vincent_twin (kinematic).
While the real drone is armed (<state_topic>), the four propeller links spin (CCW: rotor_0/1, CW: rotor_2/3)."""
import math
import rospy
from geometry_msgs.msg import PoseStamped
from gazebo_msgs.msg import ModelState, LinkState
from mavros_msgs.msg import State
from tf.transformations import quaternion_from_euler, quaternion_multiply

# rotor link, position in base_link, spin direction (+1 CCW seen from above, -1 CW)
ROTORS = [("rotor_0", (0.18, -0.175, 0.095), +1),
          ("rotor_1", (-0.18, 0.175, 0.095), +1),
          ("rotor_2", (0.18, 0.175, 0.095), -1),
          ("rotor_3", (-0.18, -0.175, 0.095), -1)]


class TwinMirror:
    def __init__(self):
        self.model = rospy.get_param("~model_name", "vincent_twin")
        self.dx = rospy.get_param("~off_x", 0.0)
        self.dy = rospy.get_param("~off_y", 0.0)
        self.dz = rospy.get_param("~off_z", 0.0)
        dyaw = rospy.get_param("~off_yaw", 0.0)
        self.c, self.s = math.cos(dyaw), math.sin(dyaw)
        self.q_off = quaternion_from_euler(0.0, 0.0, dyaw)
        self.spin_rate = rospy.get_param("~prop_spin_rate", 30.0)   # rad/s, visual only
        self.armed = False
        self.angle = 0.0
        self.t_last = None
        self.pub = rospy.Publisher("/gazebo/set_model_state", ModelState, queue_size=1)
        self.pub_link = rospy.Publisher("/gazebo/set_link_state", LinkState, queue_size=8)
        topic = rospy.get_param("~pose_topic", "/optitrack/pose")
        rospy.Subscriber(topic, PoseStamped, self.cb, queue_size=1, tcp_nodelay=True)
        rospy.Subscriber(rospy.get_param("~state_topic", "/vincent/mavros/state"), State, self.cb_state, queue_size=1)
        rospy.loginfo("twin_mirror: %s -> %s (props spin when armed)", topic, self.model)

    def cb_state(self, msg):
        self.armed = msg.armed

    def cb(self, msg):
        p, q = msg.pose.position, msg.pose.orientation
        st = ModelState()
        st.model_name = self.model
        st.reference_frame = "world"
        st.pose.position.x = self.c * p.x - self.s * p.y + self.dx
        st.pose.position.y = self.s * p.x + self.c * p.y + self.dy
        st.pose.position.z = p.z + self.dz
        qn = quaternion_multiply(self.q_off, [q.x, q.y, q.z, q.w])
        st.pose.orientation.x, st.pose.orientation.y, st.pose.orientation.z, st.pose.orientation.w = qn
        self.pub.publish(st)

        # propellers: set each rotor link relative to base_link (offset + spin angle)
        now = rospy.get_time()
        dt = 0.0 if self.t_last is None else min(now - self.t_last, 0.1)
        self.t_last = now
        if self.armed:
            self.angle = (self.angle + self.spin_rate * dt) % (2 * math.pi)
        for name, (x, y, z), d in ROTORS:
            ls = LinkState()
            ls.link_name = f"{self.model}::{name}"
            ls.reference_frame = f"{self.model}::base_link"
            ls.pose.position.x, ls.pose.position.y, ls.pose.position.z = x, y, z
            qr = quaternion_from_euler(0.0, 0.0, d * self.angle)
            ls.pose.orientation.x, ls.pose.orientation.y, ls.pose.orientation.z, ls.pose.orientation.w = qr
            self.pub_link.publish(ls)


if __name__ == "__main__":
    rospy.init_node("twin_mirror")
    TwinMirror()
    rospy.spin()
