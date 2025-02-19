#!/bin/bash
# Unraid Restic Interactive Installation & Auto-Persistence Setup
# This script installs Restic on Unraid and ensures it persists after a reboot

# Function to display messages in a user-friendly way
echo_info() {
    echo -e "\e[1;34m[INFO]\e[0m $1"
}
echo_success() {
    echo -e "\e[1;32m[SUCCESS]\e[0m $1"
}
echo_warning() {
    echo -e "\e[1;33m[WARNING]\e[0m $1"
}
echo_error() {
    echo -e "\e[1;31m[ERROR]\e[0m $1"
}

# Welcome message
echo_info "Welcome to the Restic Installation Script for Unraid!"
echo_info "This script will install Restic and ensure it remains available after a reboot."

echo "Where would you like to store the Restic binary? [Default: /boot/config/plugins/restic/bin/]"
read -r PERSISTENT_DIR
PERSISTENT_DIR=${PERSISTENT_DIR:-/boot/config/plugins/restic/bin/}

echo "The default installation directory is /usr/local/bin/. Do you really want to change it? Proceed with caution! (y/N)"
read -r confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    INSTALL_PATH="/usr/local/bin/"
else
    echo "Please enter the desired installation directory:"
    read -r INSTALL_PATH
fi
INSTALL_PATH=${INSTALL_PATH:-/usr/local/bin/}

# Ensure the persistent directory exists
echo_info "Creating persistent directory: $PERSISTENT_DIR"
mkdir -p "$PERSISTENT_DIR"

# Get the latest Restic version dynamically
echo_info "Fetching the latest Restic version..."
RESTIC_VERSION=$(curl -s https://api.github.com/repos/restic/restic/releases/latest | grep -Po '"tag_name": "\K[^"]+')
echo_success "Latest version found: $RESTIC_VERSION"

# Determine system architecture
ARCH=$(uname -m)
[ "$ARCH" == "x86_64" ] && ARCH="amd64"

echo_info "System architecture detected: $ARCH"

# Download and extract the latest Restic binary
echo_info "Downloading Restic version $RESTIC_VERSION for architecture $ARCH..."
wget -O "$PERSISTENT_DIR/restic.bz2" "https://github.com/restic/restic/releases/download/$RESTIC_VERSION/restic_v${RESTIC_VERSION}_linux_${ARCH}.bz2"
if [ $? -eq 0 ]; then
    echo_success "Download successful. Extracting the file..."
    bzip2 -df "$PERSISTENT_DIR/restic.bz2"
    chmod +x "$PERSISTENT_DIR/restic"
    DOWNLOAD_SUCCESS=true
else
    echo_error "Download failed. Please check your internet connection and try again."
    rm -rf "$PERSISTENT_DIR"
    echo_error "Temporary directory $PERSISTENT_DIR has been removed."
    exit 1
fi

# Ensure persistence after reboot
echo_info "Configuring persistence for Restic after reboot..."
echo -e "cp $PERSISTENT_DIR/restic $INSTALL_PATH\nchmod +x $INSTALL_PATH" >> /boot/config/go

echo_info "Copying Restic to $INSTALL_PATH for immediate use..."
cp "$PERSISTENT_DIR/restic" "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

if [ "$DOWNLOAD_SUCCESS" != "true" ]; then
    rm -rf "$PERSISTENT_DIR"
    echo_error "Installation failed. Temporary directory $PERSISTENT_DIR has been removed."
    exit 1
fi

echo_success "Installation complete! Checking installation:"
restic version
