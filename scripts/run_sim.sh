#!/bin/bash
# scripts/run_sim.sh
# Run on MacBook to start simulator
cd ~/ardupilot/ArduPilot
sim_vehicle.py -v ArduCopter --model quad --console --map --out tcp:0.0.0.0:5760 &
# Run control script on Pi
ssh pi@raspberrypi.local "cd ~/drone_project && python3 src/primary_drone.py"