#!/usr/bin/env python3
"""Ask PX4 to stream RC_CHANNELS (MAVLink 65) on the companion link every time the drone (re)connects,
so <ns>/mavros/rc/in is available for recording (the request is lost at every FC reboot)."""
import rospy
from mavros_msgs.msg import State
from mavros_msgs.srv import MessageInterval

class RCStream:
    def __init__(self):
        self.ns = rospy.get_param("~ns", "/vincent")
        self.rate = rospy.get_param("~rate", 20.0)
        self.connected = False
        rospy.Subscriber(self.ns + "/mavros/state", State, self.cb, queue_size=1)

    def cb(self, st):
        if st.connected and not self.connected:
            rospy.sleep(2.0)
            try:
                srv = rospy.ServiceProxy(self.ns + "/mavros/set_message_interval", MessageInterval)
                ok = srv(message_id=65, message_rate=self.rate).success
                rospy.loginfo("RC_CHANNELS stream %.0f Hz requested: %s", self.rate, ok)
            except Exception as e:
                rospy.logwarn("RC_CHANNELS request failed: %s", e)
        self.connected = st.connected

if __name__ == "__main__":
    rospy.init_node("rc_stream_request"); RCStream(); rospy.spin()
