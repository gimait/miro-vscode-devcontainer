# Devcontainer for MiRo robot in vscode

Simple vscode development container for the MiRo robot.

To run the container, vscode, the Remote Development extension for vscode and Docker are required.

The container has only been tested with NVIDIA gpus and some errors might appear when using
computers without dedicated graphic cards.

The development environment is set to run in a folder containing the MiRo MDK.

Prerequisites:
- Install Docker and NVIDIA Container Toolkit following the steps in [this webpage](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker)

Set up:

1. Go to the MiRo-e [resource webpage](http://labs.consequentialrobotics.com/download.php?file=mdk_2-200131.tgz) and download the MDK. **The gazebo simulation will only work with mdk version 200131.**

2. Extract the mdk in your workspace:

    ```
    cd <path-to-download-dir>
    tar -xzvf mdk_2-200131.tgz --transform 's/mdk-200131/mdk/' -C <path-to-miro-workspace>
    ```

3. Go to your workspace and replace the gazebo lib to use gazebo9:

    ```
    cd <path-to-miro-workspace>
    mv mdk/bin/deb64/libmiro_gazebo.so mdk/bin/deb64/libmiro_gazebo8.so && mv mdk/bin/deb64/libmiro_gazebo9.so mdk/bin/deb64/libmiro_gazebo.so
    ```

4. Clone this repository and name it `.devcontainer`:

    `git clone https://github.com/gimait/miro-vscode-devcontainer.git .devcontainer`

5. Open this folder in a vscode project, then press in reopen in container.


------


# Usage
By default the devcontainer uses the local network, but if necessary, you can change this in `devcontainer.json` (see how to do it in the vscode page).

Initially, the container is set to use the container as ros master, together with the simulation.

To connect to a real robot, you need to set the ROS_MASTER_URI to the ip of the robot:

    `export ROS_MASTER_URI=http://<robot-ip>:11311

