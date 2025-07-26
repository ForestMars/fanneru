# ファンネル
## fan'neru (funnels) 

Inspired by Gundam anime, ファンネル (funnels) is a drone control platform 
for piloting multiple drones using BCI (Brain Computer Interfaces.) 

# Background 

In "Mobile Suit Gundam: Char's Counterattack," the Funnels are a key technology 
used by the Nu Gundam, piloted by Amuro Ray. These Funnels are small, 
remotely controlled drones that can attack enemies autonomously. 

They're equipped with beam cannons and are launched from the Nu Gundam's back.

The Funnels' psycoframe technology also allows Amuro to sense and react to 
threats more effectively, making them a game-changer in the fight against 
Char Aznable's forces.


# Drone Control Project {#drone_control_project}

This project builds a system where a Raspberry Pi controls a primary drone 
via a wired connection (simulated using TCP) and coordinates secondary 
drones over radio frequency (RF, simulated via TCP/UDP). We use a simulator 
(ArduPilot SITL) to test the control logic, so no physical drones are needed
(yet) for this *pilot* version. 

This guide is designed for beginners and new contributors to jump in and
start contributing, even if you\'re new to drones or the languages used. 
(mainly Python)

## Project Overview {#project_overview}

-   **Goal**: Develop software for a Raspberry Pi to control a primary
    drone (via MAVLink) and have that drone command secondary drones
    (via RF-like communication).
-   **Current Stage**: Simulation using ArduPilot SITL, with the Pi
    sending commands to a virtual primary drone and simulating RF
    control for secondary drones.
-   **Tools**:
    -   Raspberry Pi: Runs the control software.
    -   MacBook: Runs the simulator (ArduPilot SITL) and code editor
        (Cursor).
    -   [Cursor](https://cursor.sh): Code editor for writing and
        debugging Python scripts.
-   **Languages**: Python for control logic, Bash for setup scripts.
-   **Future Plans**: Transition to physical drones with a flight
    controller (e.g., Pixhawk) and RF modules (e.g., NRF24L01).

## Prerequisites

-   **Hardware**:
    -   Raspberry Pi (e.g., Pi 4 or 3B+) with a microSD card (16GB+),
        power supply, and network connection (Wi-Fi or Ethernet).
    -   MacBook running macOS (e.g., Ventura, Sonoma) for the simulator
        and coding.
-   **Software**:
    -   [Raspberry Pi Imager](https://www.raspberrypi.com/software/): To
        install Raspberry Pi OS.
    -   [Cursor](https://cursor.sh): Code editor for your MacBook.
    -   [Homebrew](https://brew.sh): To manage dependencies on macOS.
-   **Network**: The Raspberry Pi and MacBook must be on the same
    network (Wi-Fi or Ethernet).

## Getting Started

### Step 1: Verify and Prepare the Raspberry Pi 

1.  **Confirm Raspberry Pi OS**: Ensure your Pi runs Raspberry Pi OS
    (Lite for performance or Desktop for a GUI). If not installed,
    download [Raspberry Pi
    Imager](https://www.raspberrypi.com/software/) on your MacBook and
    flash Raspberry Pi OS Lite or Desktop to a microSD card.
2.  **Boot and Connect**: Insert the microSD card, power on the Pi, and
    connect it to the same network as your MacBook (Wi-Fi or Ethernet).
3.  **Find the Pi's IP Address**: On the Pi (via monitor/keyboard or SSH
    if enabled):

```
    hostname -I
```

Note the IP (e.g., 192.168.1.101) or use `raspberrypi.local` for SSH.
SSH from your MacBook:

    ssh pi@raspberrypi.local
    # Default password: raspberry

### Step 2: Clone the Repository {#step_2_clone_the_repository}

-   Clone the project to your MacBook:

```
    git clone <repository-url> ~/drone_project
    cd ~/drone_project
```

-   If starting fresh:

```
    mkdir ~/drone_project
    cd ~/drone_project
    git init
    echo "logs/*" > .gitignore
    echo "*.pyc" >> .gitignore
    echo "__pycache__/" >> .gitignore
```

### Step 3: Set Up the Raspberry Pi

1.  **Sync the Project**: Copy files to the Pi:

```{=html}
<!-- -->
```
    rsync -avz ~/drone_project pi@raspberrypi.local:~/ --exclude logs

1.  **Run the Install Script**: SSH into the Pi:

```{=html}
<!-- -->
```
    ssh pi@raspberrypi.local

Run:

    cd ~/drone_project
    ./scripts/install_pi.sh

This installs Python, `pymavlink`, `pyyaml`, `git`, `raspi-config`,
enables SSH, and creates project directories.

### Step 4: Set Up the Simulator on the MacBook

1.  **Run the Simulator Install Script**: In your project directory:


```
    cd ~/drone_project
    ./scripts/install_simulator.sh
```

This installs Homebrew, Python, `pymavlink`, and ArduPilot SITL, then
builds the simulator.

1.  **Test the Simulator**: Start a quadcopter:

```
    cd ~/ardupilot/ArduCopter
    sim_vehicle.py -v ArduCopter --model quad --console --map --out tcp:0.0.0.0:5760
```

If Gazebo fails (macOS graphics issue), use `--no-gazebo` or Docker:

    docker run -it --rm -p 5760:5760 ardupilot/ardupilot-sitl sim_vehicle.py -v ArduCopter --model quad --console --map --out tcp:0.0.0.0:5760

### Step 5: Test the Project {#step_5_test_the_project}

1.  **Update Configuration**: In Cursor, edit `config/settings.yaml`:

```
    primary_drone:
      connection: "tcp:<MACBOOK_IP>:5760"
    secondary_drones:
      - ip: "<MACBOOK_IP>"
        port: 5762
      - ip: "<MACBOOK_IP>"
        port: 5764
```

Replace `<MACBOOK_IP>` with your MacBook's IP (run `ifconfig` and
check `en0` or `en1`).

1.  **Run Primary Drone Control**: Start the simulator (Step 4). On the
    Pi:

```
    cd ~/drone_project
    python3 src/primary_drone.py
```

This arms and commands takeoff.

1.  **Test RF Simulation**: Start a second simulator:


```
    cd ~/ardupilot/ArduCopter
    sim_vehicle.py -v ArduCopter --model quad --instance 1 --out tcp:0.0.0.0:5762
```

On the Pi:

```
    python3 src/rf_controller.py
```

## Project Structure {#project_structure}

-   **src/**: Python modules for control logic
    -   `__init__.py`
    -   `primary_drone.py`: Controls the primary drone via MAVLink
    -   `rf_controller.py`: Simulates RF control for secondary drones
    -   `swarm_coordinator.py`: Coordinates primary and secondary drones
        (TBD)
-   **scripts/**: Bash scripts for setup and running
    -   `install_pi.sh`: Installs dependencies on the Raspberry Pi
    -   `install_simulator.sh`: Installs ArduPilot SITL on the MacBook
    -   `run_sim.sh`: Launches simulator and control scripts
-   **config/**: Configuration files
    -   `settings.yaml`: IPs and ports for drones
-   **logs/**: Telemetry and debug logs
-   **.gitignore**: Excludes logs, pycache, etc.
-   **README.mediawiki**: This file

## Contributing

We welcome contributions from beginners and experienced coders! Here\'s
how to get involved:

-   **Explore the Code**: Open `src/primary_drone.py` in Cursor to see
    MAVLink communication. Check `src/rf_controller.py` for RF
    simulation.
-   **Add Features**: Add telemetry logging (e.g., GPS to
    `logs/telemetry.csv`). Implement `swarm_coordinator.py` for swarm
    behavior. Suggest ideas like a web interface or computer vision.



```
    rsync -avz ~/drone_project pi@raspberrypi.local:~/ --exclude logs
``` 

## Troubleshooting

-   **Simulator Won't Start**:
    -   Check Python dependencies:
        `pip3 show pymavlink empy pexpect future`.
    -   If Gazebo fails, use `--no-gazebo` or Docker (see Step 4).
-   **Pi Connection Issues**:
    -   Verify Pi's IP and SSH: `sudo systemctl status ssh`.
    -   Ensure MacBook and Pi are on the same network.
-   **Code Errors**:
    -   Check `logs/` for telemetry or errors.

## Resources

-   [Raspberry Pi
    Setup](https://www.raspberrypi.com/documentation/computers/getting-started.html)
-   [ArduPilot
    SITL](https://ardupilot.org/dev/docs/sitl-simulator-software-in-the-loop.html)
-   [MAVLink
    Guide](https://ardupilot.org/dev/docs/mavlink-commands.html)
-   [macOS ArduPilot
    Setup](https://ardupilot.org/dev/docs/building-setup-mac.html)
-   [Learn Python](https://www.python.org/about/gettingstarted/)
-   [Drone Basics](https://ardupilot.org/copter/)

## Next Steps {#next_steps}

-   **Simulation**: Add commands to `primary_drone.py` (e.g., waypoints,
    landing).
-   **Swarm Logic**: Develop `swarm_coordinator.py` for multi-drone
    control.
-   **Hardware**: Transition to a flight controller (e.g., Pixhawk) and
    RF modules (e.g., NRF24L01).

If you need help, ask here in the issue queue or
reach out to the maintainers.

https://gundam.fandom.com/wiki/Mobile_Suit_Gundam:_Char%27s_Counterattack
