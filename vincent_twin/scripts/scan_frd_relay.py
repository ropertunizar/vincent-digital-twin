#!/usr/bin/env python3
"""Relay the twin's LaserScan to mavros obstacle/send.
ROS LaserScan angles are counter-clockwise (FLU); MAVLink OBSTACLE_DISTANCE is clockwise from forward (FRD).
flip=true reverses the range order (verified on the bench 2026-10-13).
No hit (inf/nan/>max) is sent as range_max + 0.01 = 'no obstacle up to max', NOT UINT16_MAX = 'no data'
(with CP_GO_NO_DATA=0, 'no data' blocks motion in that direction)."""
import math
import rospy
from sensor_msgs.msg import LaserScan


def main():
    rospy.init_node("scan_frd_relay")
    flip = rospy.get_param("~flip", True)
    pub = rospy.Publisher("scan_out", LaserScan, queue_size=1)

    def cb(m):
        free = m.range_max + 0.01
        ranges = [r if (math.isfinite(r) and m.range_min <= r <= m.range_max) else free for r in m.ranges]
        o = LaserScan()
        o.header = m.header
        o.angle_increment = m.angle_increment
        o.time_increment = m.time_increment
        o.scan_time = m.scan_time
        o.range_min, o.range_max = m.range_min, m.range_max
        if flip:
            o.angle_min, o.angle_max = -m.angle_max, -m.angle_min
            o.ranges = list(reversed(ranges))
        else:
            o.angle_min, o.angle_max = m.angle_min, m.angle_max
            o.ranges = ranges
        pub.publish(o)

    rospy.Subscriber("scan_in", LaserScan, cb, queue_size=1, tcp_nodelay=True)
    rospy.spin()


if __name__ == "__main__":
    main()
