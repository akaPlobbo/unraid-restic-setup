#!/bin/bash
# Unraid Restic Interactive Installation & Auto-Persistence Setup
# This script installs Restic on Unraid and ensures it persists after a reboot

# Function to display messages in a stylish format
echo_info() {
    echo -e "\e[1;34m[ℹ️ INFO]\e[0m $1"
}
echo_success() {
    echo -e "\e[1;32m[✅ SUCCESS]\e[0m $1"
}
echo_warning() {
    echo -e "\e[1;33m[⚠️ WARNING]\e[0m $1"
}
echo_error() {
    echo -e "\e[1;31m[❌ ERROR]\e[0m $1"
}

# Display a custom Restic logo
echo -e "\e[1;36m"
echo "====================================="
echo " 🚀 Restic Unraid Setup Script 🚀 "
echo "====================================="
echo -e "\e[0m"

# Welcome message
echo_info "\e[1;35m***********************************\e[0m"
echo_info "\e[1;35m*   Welcome to Restic Installer  *\e[0m"
echo_info "\e[1;35m*   for Unraid - Easy & Secure   *\e[0m"
echo_info "\e[1;35m***********************************\e[0m"
echo_info "This script will install Restic and ensure it remains available after a reboot."

# Prompt for binary storage location
echo -e "\e[1;36m📁 Where would you like to store the Restic binary?\e[0m"
echo -e "\e[1;33m(Default: /boot/config/plugins/restic/bin)\e[0m"
read -r PERSISTENT_DIR
PERSISTENT_DIR=${PERSISTENT_DIR:-/boot/config/plugins/restic/bin}

# Prompt for installation path
echo -e "\e[1;36m🛠️ The default installation directory is /usr/local/bin/restic.\e[0m"
echo -e "\e[1;33mDo you really want to change it? Proceed with caution! (y/N)\e[0m"
read -r confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    INSTALL_PATH="/usr/local/bin/restic"
else
    echo -e "\e[1;36m📌 Please enter the desired installation directory:\e[0m"
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
wget -O "$PERSISTENT_DIR/restic.bz2" "https://github.com/restic/restic/releases/download/$RESTIC_VERSION/restic_${RESTIC_VERSION#v}_linux_${ARCH}.bz2"
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

# Cool farewell sequence
echo -e "\e[1;36m"
echo "====================================="
echo " 🎉 Restic is ready! 🎉 "
echo "💾 Your backups are in safe hands! 💾"
echo "🚀 Happy Backing Up & Stay Secure! 🚀"
echo "====================================="
echo -e "\e[0m"
