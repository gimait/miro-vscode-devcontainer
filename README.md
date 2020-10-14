# miro-vscode-devcontainer

Simple vscode development container for the MiRo robot.

To run the container, vscode, the Remote Development extension for vscode and Docker are required.

The container has only been tested with NVIDIA gpus and some errors might appear when using
computers without dedicated graphic cards.

The development environment is set to run in a folder containing the MiRo MDK.

You can install the environment as follows:

1. Go to the folder containing the MiRo MDK and your code
2. Clone this repository and name it `.devcontainer`:

    ```git clone https://github.com/gimait/miro-vscode-devcontainer.git .devcontainer```

3. Open the folder in vscode and press `Reopen in Container`.