#!/usr/bin/env python3
"""Mirror the real drone's OptiTrack pose onto the Gazebo model vincent_twin (kinematic)."""
import math
import rospy
from geometry_msgs.msg import PoseStamped
from gazebo_msgs.msg import ModelState
from tf.transformations import quaternion_from_euler, quaternion_multiply


class TwinMirror:
    def __init__(self):
        self.model = rospy.get_param("~model_name", "vincent_twin")
        self.dx = rospy.get_param("~off_x", 0.0)
        self.dy = rospy.get_param("~off_y", 0.0)
        self.dz = rospy.get_param("~off_z", 0.0)
        dyaw = rospy.get_param("~off_yaw", 0.0)
        self.c, self.s = math.cos(dyaw), math.sin(dyaw)
        self.q_off = quaternion_from_euler(0.0, 0.0, dyaw)
        self.pub = rospy.Publisher("/gazebo/set_model_state", ModelState, queue_size=1)
        topic = rospy.get_param("~pose_topic", "/optitrack/pose")
        rospy.Subscriber(topic, PoseStamped, self.cb, queue_size=1, tcp_nodelay=True)
        rospy.loginfo("twin_mirror: %s -> %s", topic, self.model)

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


if __name__ == "__main__":
    rospy.init_node("twin_mirror")
    TwinMirror()
    rospy.spin()
