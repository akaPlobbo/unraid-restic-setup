#!/bin/bash

echo "🔍 Starte Hardware-Check..."

# Update Paketquellen
echo "📦 Aktualisiere Paketlisten..."
sudo apt update

# Wichtige Tools installieren
echo "📥 Installiere benötigte Tools (inxi, mesa-utils, pciutils)..."
sudo apt install -y inxi mesa-utils pciutils

echo
echo "🖥️ CPU & RAM:"
lscpu | grep "Model name"
free -h

echo
echo "💽 Festplatten:"
lsblk

echo
echo "🧠 GPU Info:"
lspci | grep -i vga
echo
echo "🎮 OpenGL Renderer (Grafikbeschleunigung):"
glxinfo | grep "OpenGL renderer"

echo
echo "🛜 Netzwerkgeräte:"
lspci | grep -i ethernet
lspci | grep -i network

echo
echo "📷 USB-Geräte:"
lsusb

echo
echo "📄 Kompakte Systemübersicht mit inxi:"
inxi -Fxxxrz

echo
echo "🎯 NVIDIA-Treiber Check (nur wenn Internet aktiv ist)..."
echo "→ Empfohlener Treiber:"
ubuntu-drivers devices

echo
read -p "❓ Willst du den NVIDIA-Treiber jetzt installieren? (j/n): " answer
if [[ "$answer" == "j" || "$answer" == "J" ]]; then
    echo "🚀 Installiere NVIDIA-Treiber..."
    sudo apt install -y $(ubuntu-drivers devices | grep "recommended" | awk '{print $3}')
    echo "✅ Installation abgeschlossen. Bitte reboot durchführen."
    echo "Nach dem Neustart kannst du mit 'nvidia-smi' die RTX 2060 prüfen."
else
    echo "⏭️ NVIDIA-Treiber wird übersprungen."
fi

echo
echo "✅ Fertig! Du kannst jetzt die Ausgaben überprüfen."
