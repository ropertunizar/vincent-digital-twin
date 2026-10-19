#!/usr/bin/env python3
"""Spawn the SITL twin relative to the REAL drone's current OptiTrack pose.
spawn = real (x, y) + (dx, dy), z = 0, yaw = Y (default 0 = facing +x, the hub's commanded heading).
Publishes the result as /sim/spawn_offset [x, y, z] so the MATLAB hub reads the same numbers.
Falls back to ~x/~y if no OptiTrack pose arrives within ~timeout."""
import rospy
from geometry_msgs.msg import PoseStamped, Pose, Point, Quaternion
from gazebo_msgs.srv import SpawnModel
from tf.transformations import quaternion_from_euler


def main():
    rospy.init_node("spawn_sim_from_real")
    sdf_file = rospy.get_param("~sdf")
    name = rospy.get_param("~model_name", "vincent_vision")
    dx = rospy.get_param("~dx", -1.0)        # 1 m behind (drones face +x)
    dy = rospy.get_param("~dy", 0.0)
    yaw = rospy.get_param("~Y", 0.0)
    timeout = rospy.get_param("~timeout", 10.0)
    try:
        p = rospy.wait_for_message(rospy.get_param("~pose_topic", "/optitrack/pose"), PoseStamped, timeout=timeout).pose.position
        x, y = p.x + dx, p.y + dy
        rospy.loginfo("Real drone at (%.3f, %.3f) -> SITL spawn (%.3f, %.3f)", p.x, p.y, x, y)
    except rospy.ROSException:
        x, y = rospy.get_param("~x", 0.0), rospy.get_param("~y", 0.0)
        rospy.logwarn("No OptiTrack pose -> fallback spawn (%.3f, %.3f)", x, y)
    rospy.set_param("/sim/spawn_offset", [float(x), float(y), 0.0])
    # same shift for the trajectory: the SITL twin flies the shape (dx, dy) away from the real one
    rospy.set_param("/sim/traj_offset", [float(dx), float(dy), 0.0])
    rospy.wait_for_service("/gazebo/spawn_sdf_model")
    spawn = rospy.ServiceProxy("/gazebo/spawn_sdf_model", SpawnModel)
    q = quaternion_from_euler(0.0, 0.0, yaw)
    pose = Pose(Point(x, y, 0.0), Quaternion(*q))
    res = spawn(name, open(sdf_file).read(), "", pose, "world")
    rospy.loginfo("Spawn: %s %s", res.success, res.status_message)


if __name__ == "__main__":
    main()
