# Unraid Restic Setup Script

This script installs Restic on Unraid and ensures it remains available after a reboot.

## Features

- Interactive installation of Restic
- Configuration of a persistent storage location for the Restic binary
- Automatic detection of the latest Restic version
- Support for various system architectures
- Ensuring persistence of Restic after a reboot

## Prerequisites

- Unraid server with internet connection
- Bash shell

## Installation

1. Clone this repository to your Unraid server:
    ```bash
    git clone https://github.com/akaPlobbo/unraid-restic-setup.git
    cd unraid-restic-setup
    ```

2. Run the script:
    ```bash
    sh unraid_restic_setup.sh
    ```

## Usage

The script will guide you through the following steps:

1. **Welcome and Introduction**: The script displays a welcome message and a brief introduction.

2. **Binary Storage Location**: You will be asked where to store the Restic binary. The default path is `/boot/config/plugins/restic/bin`.

3. **Installation Path**: You will be asked if you want to change the default installation path (`/usr/local/bin/restic`). If yes, you can specify a new path.

4. **Creating Persistent Directory**: The script creates the specified directory if it does not already exist.

5. **Fetching Latest Restic Version**: The script fetches the latest Restic version from GitHub.

6. **System Architecture**: The script detects the system architecture (e.g., `amd64`).

7. **Download and Extraction**: The script downloads and extracts the Restic binary.

8. **Persistence After Reboot**: The script configures persistence of Restic after a reboot by adding the necessary commands to the `/boot/config/go` file.

9. **Copying Binary**: The Restic binary is copied to the installation directory and made executable.

10. **Installation Verification**: The script verifies the installation by displaying the Restic version.

11. **Completion Message**: The script displays a completion message.

## Troubleshooting

- **Download Errors**: If the download of the Restic binary fails, check your internet connection and try again.
- **Permission Issues**: Ensure you have sufficient permissions to run the script and create files in the specified directories.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Restic](https://github.com/restic/restic) for the great backup tool
- [Unraid](https://unraid.net/) for the powerful NAS operating system
