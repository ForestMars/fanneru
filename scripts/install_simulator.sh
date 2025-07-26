#!/bin/bash
# scripts/install_simulator.sh
# Installs ArduPilot SITL and dependencies on macOS for drone simulation

set -e  # Exit on error

echo "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew already installed"
fi

echo "Installing dependencies via Homebrew..."
brew install python3 git || true  # Continue if already installed

echo "Installing Python dependencies..."
pip3 install pymavlink empy pexpect future

echo "Cloning ArduPilot repository..."
if [ ! -d "~/ardupilot" ]; then
    git clone https://github.com/ArduPilot/ardupilot.git ~/ardupilot
    cd ~/ardupilot
    git submodule update --init --recursive
else
    echo "ArduPilot repository already cloned"
fi

echo "Building ArduPilot SITL..."
cd ~/ardupilot
./waf configure --board sitl
./waf copter

echo "Simulator setup complete! Start it with:"
echo "cd ~/ardupilot/ArduCopter && sim_vehicle.py -v ArduCopter --model quad --console --map --out tcp:0.0.0.0:5760"