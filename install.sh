#!/bin/bash
# scripts/install_pi.sh
# Installs dependencies for the drone control project on Raspberry Pi

set -e  # Exit on error

echo "Updating Raspberry Pi OS..."
sudo apt update && sudo apt upgrade -y

echo "Verifying raspi-config..."
if ! command -v raspi-config &> /dev/null; then
    echo "Installing raspi-config..."
    sudo apt install raspi-config -y
else
    echo "raspi-config already installed"
fi

echo "Enabling SSH..."
sudo raspi-config nonint do_ssh 0

echo "Installing Python and pip..."
sudo apt install python3 python3-pip -y

echo "Installing project dependencies..."
pip3 install pymavlink pyyaml

echo "Installing git..."
sudo apt install git -y

echo "Setting up project directories..."
mkdir -p ~/drone_project/{src,scripts,config,logs}
touch ~/drone_project/src/__init__.py

echo "Setup complete! Sync project with: rsync -avz ~/drone_project pi@<PI_IP>:~/"