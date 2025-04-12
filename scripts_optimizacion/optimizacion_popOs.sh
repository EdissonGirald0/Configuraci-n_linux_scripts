#!/bin/bash

# Este script realiza optimizaciones avanzadas en Pop!_OS para desarrollo de software
# Incluye mejoras de rendimiento, configuración de memoria y optimizaciones específicas
# para herramientas de desarrollo como Docker, VSCode y entornos de compilación

# Verificar privilegios de root (necesario para modificar configuraciones del sistema)
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Este script debe ejecutarse como root (sudo)"
    exit 1
fi

# Configurar sistema de logs para rastrear cambios y facilitar la resolución de problemas
log_file="/var/log/system_optimization.log"
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$log_file"
}

echo "🚀 Iniciando optimización avanzada de Pop!_OS..."
log "Iniciando proceso de optimización"

# Backup de archivos importantes
backup_dir="/root/system_backup_$(date +%Y%m%d)"
mkdir -p "$backup_dir"
cp /etc/default/grub "$backup_dir/"
cp /etc/fstab "$backup_dir/"
cp /etc/sysctl.conf "$backup_dir/"

# ================================
# 🔄 Actualizar y limpiar sistema
# ================================
log "Actualizando sistema..."
apt update && apt upgrade -y
apt autoremove -y && apt autoclean
journalctl --vacuum-time=7d
# Limpiar cache de apt
apt clean
rm -rf /var/lib/apt/lists/*

# ================================
# ⚙️ Servicios innecesarios
# ================================
log "Desactivando servicios innecesarios..."
SERVICIOS_INNECESARIOS=(
    bluetooth
    avahi-daemon
    cups
    ModemManager
    whoopsie
    kerneloops
)
for servicio in "${SERVICIOS_INNECESARIOS[@]}"; do
    systemctl disable --now "$servicio" 2>/dev/null
    log "Desactivado servicio: $servicio"
done

# ================================
# ⚡ Optimización del arranque
# ================================
log "Optimizando configuración de GRUB..."
# Backup del archivo GRUB
cp /etc/default/grub /etc/default/grub.backup
sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 nowatchdog mitigations=off intel_idle.max_cstate=1 processor.max_cstate=1"/' /etc/default/grub
update-grub

# ================================
# 🧠 Optimizar uso de RAM y SWAP
# ================================
log "Optimizando memoria..."
apt install -y zram-config preload

# Configurar zram
echo "zram" > /etc/modules-load.d/zram.conf
echo "options zram num_devices=1" > /etc/modprobe.d/zram.conf

# Optimizar parámetros del kernel
cat >> /etc/sysctl.d/99-sysctl.conf << EOF
# Optimización de memoria
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=10
vm.dirty_background_ratio=5
vm.dirty_bytes=0
vm.dirty_background_bytes=0

# Optimización de red
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.core.netdev_max_backlog=2500
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_congestion_control=bbr
net.core.somaxconn=1024

# Optimización de sistema de archivos
fs.inotify.max_user_watches=524288
fs.file-max=2097152
EOF

# Aplicar cambios
sysctl -p /etc/sysctl.d/99-sysctl.conf

# ================================
# 💽 Optimización del sistema de archivos
# ================================
log "Optimizando sistema de archivos..."
# Activar TRIM para SSD
systemctl enable fstrim.timer
systemctl start fstrim.timer

# Optimizar fstab para SSD
if [ -b /dev/sda ] || [ -b /dev/nvme0n1 ]; then
    sed -i 's/errors=remount-ro/errors=remount-ro,noatime,commit=60/' /etc/fstab
fi

# ================================
# 🔋 Gestión energética avanzada
# ================================
log "Configurando gestión energética..."
apt install -y tlp tlp-rdw powertop

# Configurar TLP
cat > /etc/tlp.conf << EOF
TLP_ENABLE=1
TLP_DEFAULT_MODE=BAT
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_MIN_PERF_ON_AC=0
CPU_MAX_PERF_ON_AC=100
CPU_MIN_PERF_ON_BAT=0
CPU_MAX_PERF_ON_BAT=30
EOF

systemctl enable tlp
systemctl start tlp
powertop --auto-tune

# ================================
# 🎮 Optimización GPU
# ================================
log "Configurando GPU..."
if lspci | grep -i nvidia > /dev/null; then
    apt install -y nvidia-driver-535 nvidia-settings
    # Optimizar configuración de NVIDIA
    nvidia-smi -pm 1
    nvidia-smi --auto-boost-default=0
    nvidia-smi -ac 2100,800
elif lspci | grep -i amd > /dev/null; then
    apt install -y mesa-vulkan-drivers vulkan-tools
    # Habilitar FreeSync si está disponible
    if [ -f /sys/class/drm/card0/device/freesync ]; then
        echo 1 > /sys/class/drm/card0/device/freesync
    fi
fi

# ================================
# 📊 Sistema de monitoreo
# ================================
log "Instalando herramientas de monitoreo..."
apt install -y htop iotop nmon nethogs

# ================================
# 💻 Optimizaciones para Desarrollo
# ================================
log "Configurando optimizaciones para desarrollo..."

# Aumentar límites del sistema para IDEs, Docker y herramientas de desarrollo
cat >> /etc/security/limits.conf << EOF
# Límites para desarrolladores
# nofile: número máximo de archivos abiertos
# nproc: número máximo de procesos
# memlock: límite de memoria bloqueada para aplicaciones
*               soft    nofile          65535
*               hard    nofile          65535
*               soft    nproc           65535
*               hard    nproc           65535
*               soft    memlock         unlimited
*               hard    memlock         unlimited
EOF

# Optimizaciones específicas para Docker
if command -v docker &> /dev/null; then
    log "Optimizando Docker..."
    # Configurar daemon.json con ajustes optimizados para desarrollo
    cat > /etc/docker/daemon.json << EOF
{
    "storage-driver": "overlay2",      # Driver más eficiente para desarrollo
    "max-concurrent-downloads": 10,     # Aumenta descargas paralelas
    "max-concurrent-uploads": 10,       # Aumenta subidas paralelas
    "default-ulimits": {
        "nofile": {                    # Límites de archivos para contenedores
            "Name": "nofile",
            "Hard": 64000,
            "Soft": 64000
        }
    }
}
EOF
    systemctl restart docker
fi

# Optimizaciones para VSCode
if command -v code &> /dev/null; then
    log "Optimizando VSCode..."
    # Aumentar límite de vigilancia de archivos para grandes proyectos
    echo "fs.inotify.max_user_watches=524288" > /etc/sysctl.d/99-vscode.conf
    sysctl -p /etc/sysctl.d/99-vscode.conf
fi

# Optimizar parámetros del kernel para IDEs y compilación
cat >> /etc/sysctl.d/99-developer.conf << EOF
# Optimizaciones para desarrollo
vm.max_map_count=262144              # Necesario para ElasticSearch y JVM
kernel.threads-max=4194304           # Máximo número de hilos del sistema
EOF

# Variables de entorno para optimizar compilación
cat >> /etc/environment << EOF
# Optimización para compilación
MAKEFLAGS="-j\$(nproc)"             # Usar todos los cores para compilación
JAVA_TOOL_OPTIONS="-Xmx4G"          # Memoria máxima para herramientas Java
GRADLE_OPTS="-Xmx4G -Dorg.gradle.daemon=true -Dorg.gradle.parallel=true"
MAVEN_OPTS="-Xmx4G"                 # Memoria máxima para Maven
EOF

# ================================
# 🔧 Herramientas de Desarrollo
# ================================
log "Instalando herramientas adicionales de desarrollo..."
apt install -y \
    ccache \           # Cache para compilación
    iotop \            # Monitoreo de I/O
    sysstat \          # Estadísticas del sistema
    linux-tools-common # Herramientas de análisis

# Configurar ccache
cat >> /etc/profile.d/ccache.sh << EOF
export PATH="/usr/lib/ccache:\$PATH"
export CCACHE_DIR="/var/cache/ccache"
export CCACHE_SIZE=50G
EOF

# ================================
# 📊 Monitoreo de Desarrollo
# ================================
log "Configurando herramientas de monitoreo para desarrollo..."
apt install -y \
    prometheus-node-exporter \
    grafana \
    nethogs \
    iftop

# Configurar Grafana
systemctl enable grafana-server
systemctl start grafana-server

# ================================
# ✅ Finalización
# ================================
log "Optimización completada"
echo "
✅ Optimización completada. Por favor, realiza las siguientes acciones:
1. Revisa el log en $log_file
2. Reinicia el sistema para aplicar todos los cambios
3. Backup guardado en $backup_dir

⚠️ Para revertir cambios del GRUB:
   sudo cp $backup_dir/grub /etc/default/grub
   sudo update-grub

🔧 Optimizaciones adicionales para desarrollo:
1. Límites del sistema aumentados para IDEs y contenedores
2. Docker optimizado para desarrollo
3. VSCode configurado para mejor rendimiento
4. Herramientas de monitoreo instaladas
5. ccache configurado para compilación más rápida

📊 Accede a Grafana en http://localhost:3000 para monitoreo
"
