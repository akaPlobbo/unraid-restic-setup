#!/bin/bash
# Unraid Restic Interactive Installation & Auto-Persistence Setup
# This script installs Restic on Unraid and ensures it persists after a reboot

# Function to display messages in a professional format
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

# Ask user for installation preferences
echo_info "Willkommen zum Restic Installationsskript für Unraid."
echo_info "Dieses Skript wird Restic installieren und sicherstellen, dass es nach einem Neustart verfügbar bleibt."

echo "Bitte geben Sie den Speicherort für die Restic-Binärdatei an [Standard: /boot/config/plugins/restic/bin/]:"
read -r PERSISTENT_DIR
PERSISTENT_DIR=${PERSISTENT_DIR:-/boot/config/plugins/restic/bin/}

echo "Das Standardinstallationsverzeichnis ist /usr/local/bin/. Möchtest du das wirklich ändern? Auf eigene Gefahr! (y/N)"
read -r confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    INSTALL_PATH="/usr/local/bin/"
else
    echo "Bitte geben Sie das gewünschte Installationsverzeichnis an:"
    read -r INSTALL_PATH
fi
INSTALL_PATH=${INSTALL_PATH:-/usr/local/bin/}

# Ensure the persistent directory exists
echo_info "Erstelle persistentes Verzeichnis: $PERSISTENT_DIR"
mkdir -p "$PERSISTENT_DIR"

# Get latest Restic version dynamically
echo_info "Abrufen der neuesten Restic-Version..."
RESTIC_VERSION=$(curl -s https://api.github.com/repos/restic/restic/releases/latest | grep -Po '"tag_name": "\K[^"]+')
echo_success "Neueste Version gefunden: $RESTIC_VERSION"

# Determine system architecture
ARCH=$(uname -m)
[ "$ARCH" == "x86_64" ] && ARCH="amd64"

echo_info "Systemarchitektur erkannt: $ARCH"

# Download and extract the latest Restic binary
echo_info "Herunterladen von Restic Version $RESTIC_VERSION für Architektur $ARCH..."
wget -O "$PERSISTENT_DIR/restic.bz2" "https://github.com/restic/restic/releases/download/$RESTIC_VERSION/restic_${RESTIC_VERSION}_linux_${ARCH}.bz2"
if [ $? -eq 0 ]; then
    echo_success "Download erfolgreich. Entpacken der Datei..."
    bzip2 -df "$PERSISTENT_DIR/restic.bz2"
    chmod +x "$PERSISTENT_DIR/restic"
else
    echo_error "Fehler beim Herunterladen von Restic. Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut."
    exit 1
fi

# Ensure persistence after reboot
echo_info "Konfigurieren der Persistenz für Restic nach einem Neustart..."
echo -e "cp $PERSISTENT_DIR/restic $INSTALL_PATH\nchmod +x $INSTALL_PATH" >> /boot/config/go

echo_info "Kopiere Restic zur sofortigen Nutzung nach $INSTALL_PATH..."
cp "$PERSISTENT_DIR/restic" "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

echo_success "Installation abgeschlossen! Überprüfung der Installation:"
restic version
