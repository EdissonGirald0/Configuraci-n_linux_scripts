#!/bin/bash

echo "🚀 Iniciando optimización avanzada de Pop!_OS..."

# ================================
# 🔄 Actualizar y limpiar sistema
# ================================
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y && sudo apt autoclean
sudo journalctl --vacuum-time=7d

# ================================
# ⚙️ Servicios innecesarios
# ================================
echo "🛑 Desactivando servicios innecesarios..."
SERVICIOS_INNECESARIOS=(bluetooth avahi-daemon cups)
for servicio in "${SERVICIOS_INNECESARIOS[@]}"; do
    sudo systemctl disable --now "$servicio" 2>/dev/null
done

# ================================
# ⚡ Parallel boot + GRUB tweaks
# ================================
echo "⚡ Acelerando el arranque..."
sudo sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 nowatchdog mitigations=off"/' /etc/default/grub
sudo update-grub

# ================================
# 🧠 Optimizar uso de RAM
# ================================
echo "🧠 Configurando uso de memoria..."
sudo apt install -y zram-config preload
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# ================================
# 💽 Mejoras al sistema de archivos
# ================================
echo "💽 Activando TRIM y mejoras en fstab..."
sudo systemctl enable fstrim.timer
sudo sed -i 's/errors=remount-ro/errors=remount-ro,noatime/' /etc/fstab

# ================================
# 🔋 Ahorro energético
# ================================
echo "🔋 Instalando TLP para gestión energética..."
sudo apt install -y tlp tlp-rdw powertop
sudo systemctl enable tlp
sudo powertop --auto-tune

# ================================
# 🖥 Configurar CPU governor
# ================================
echo "🎚 Estableciendo modo de rendimiento del CPU..."
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance | sudo tee $cpu
done

# ================================
# 🎮 Optimizar driver GPU
# ================================
echo "🎮 Optimizando driver de GPU..."
GPU_VENDOR=$(lspci | grep -E "VGA|3D" | awk '{print $5}' | head -1)

if lspci | grep -i nvidia; then
    echo "📦 NVIDIA detectada, instalando drivers propietarios..."
    sudo apt install -y nvidia-driver-535
elif lspci | grep -i amd; then
    echo "📦 AMD detectada, activando mesa drivers..."
    sudo apt install -y mesa-vulkan-drivers
elif lspci | grep -i intel; then
    echo "📦 Intel detectada, instalando drivers..."
    sudo apt install -y intel-media-va-driver-non-free
fi

# ================================
# 📶 Optimizar red
# ================================
echo "📶 Ajustando parámetros de red..."
sudo tee -a /etc/sysctl.conf > /dev/null <<EOF
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.core.netdev_max_backlog=2500
EOF
sudo sysctl -p

# ================================
# ✅ Final
# ================================
echo "✅ Optimización completa. Reinicia el sistema para aplicar todos los cambios."
