# src/rf_controller.py

import socket

class RFController:
    def __init__(self, target_ip="192.168.1.100", port=5762):
        self.target = (target_ip, port)

    def send_command(self, command):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            sock.connect(self.target)
            sock.send(command.encode())
            print(f"Sent RF command: {command}")
        except Exception as e:
            print(f"RF error: {e}")
        finally:
            sock.close()