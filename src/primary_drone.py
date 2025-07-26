# src/primary_drone.py

from pymavlink import mavutil
import time

class PrimaryDrone:
    def __init__(self, connection_string="tcp:192.168.1.100:5760"):
        # Replace with MacBook’s IP (run `ifconfig` on MacBook)
        self.connection = mavutil.mavlink_connection(connection_string)
        self.connection.wait_heartbeat()
        print("Connected to primary drone")

    def arm(self):
        self.connection.mav.command_long_send(
            self.connection.target_system, self.connection.target_component,
            mavutil.mavlink.MAV_CMD_COMPONENT_ARM_DISARM, 0, 1, 0, 0, 0, 0, 0, 0
        )
        print("Arming drone")

    def takeoff(self, altitude=10):
        self.connection.mav.set_mode_send(
            self.connection.target_system,
            mavutil.mavlink.MAV_MODE_FLAG_CUSTOM_MODE_ENABLED,
            4)  # GUIDED mode
        time.sleep(1)
        self.connection.mav.command_long_send(
            self.connection.target_system, self.connection.target_component,
            mavutil.mavlink.MAV_CMD_NAV_TAKEOFF, 0, 0, 0, 0, 0, 0, 0, altitude
        )
        print(f"Taking off to {altitude}m")