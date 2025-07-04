#!/bin/bash

# ================================
# ⚡ Módulo de Optimización del Sistema
# ================================
# Archivo: modules/system_optimization.sh
# Descripción: Optimizaciones avanzadas del sistema

# Importar utilidades
source "$(dirname "$0")/../lib/utils.sh"

# ================================
# 🔄 Actualización y Limpieza del Sistema
# ================================

update_and_clean_system() {
    log_info "Actualizando y limpiando el sistema..."
    
    # Actualizar repositorios y paquetes
    if apt update && apt upgrade -y; then
        log_success "Sistema actualizado"
    else
        log_error "Error al actualizar el sistema"
        return 1
    fi
    
    # Limpiar paquetes no necesarios
    apt autoremove -y
    apt autoclean
    
    # Limpiar logs antiguos
    journalctl --vacuum-time=7d
    
    # Limpiar cache de apt
    apt clean
    rm -rf /var/lib/apt/lists/*
    
    log_success "Limpieza del sistema completada"
    return 0
}

# ================================
# ⚙️ Gestión de Servicios
# ================================

manage_services() {
    log_info "Gestionando servicios del sistema..."
    
    # Servicios por defecto a deshabilitar
    local services_to_disable=(
        "bluetooth"
        "avahi-daemon"
        "cups"
        "ModemManager"
        "whoopsie"
        "kerneloops"
    )
    
    # Intentar cargar desde configuración
    if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
        local config_services=$(yq eval '.services.disable_unnecessary[]' "$CONFIG_FILE" 2>/dev/null)
        if [[ -n "$config_services" ]]; then
            services_to_disable=($config_services)
        fi
    fi
    
    for service in "${services_to_disable[@]}"; do
        disable_service "$service"
    done
    
    log_success "Gestión de servicios completada"
}

# ================================
# ⚡ Optimización del Arranque
# ================================

optimize_boot() {
    log_info "Optimizando configuración de arranque..."
    
    # Backup del archivo GRUB
    cp /etc/default/grub /etc/default/grub.backup
    
    # Optimizar timeout de GRUB
    sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub
    
    # Optimizar parámetros del kernel
    local grub_params='quiet splash loglevel=3 nowatchdog mitigations=off intel_idle.max_cstate=1 processor.max_cstate=1'
    sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"$grub_params\"/" /etc/default/grub
    
    # Actualizar GRUB
    if update-grub; then
        log_success "GRUB optimizado"
    else
        log_error "Error al actualizar GRUB"
        return 1
    fi
    
    return 0
}

# ================================
# 🧠 Optimización de Memoria
# ================================

optimize_memory() {
    log_info "Optimizando configuración de memoria..."
    
    # Instalar herramientas de optimización de memoria
    install_packages "zram-config" "preload"
    
    # Configurar zram
    echo "zram" > /etc/modules-load.d/zram.conf
    echo "options zram num_devices=1" > /etc/modprobe.d/zram.conf
    
    # Valores por defecto
    local swappiness=10
    local vfs_cache_pressure=50
    local dirty_ratio=10
    local dirty_background_ratio=5
    
    # Intentar cargar desde configuración
    if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
        swappiness=$(yq eval '.optimization.memory.swappiness' "$CONFIG_FILE" 2>/dev/null || echo "10")
        vfs_cache_pressure=$(yq eval '.optimization.memory.vfs_cache_pressure' "$CONFIG_FILE" 2>/dev/null || echo "50")
        dirty_ratio=$(yq eval '.optimization.memory.dirty_ratio' "$CONFIG_FILE" 2>/dev/null || echo "10")
        dirty_background_ratio=$(yq eval '.optimization.memory.dirty_background_ratio' "$CONFIG_FILE" 2>/dev/null || echo "5")
    fi
    
    # Configurar parámetros del kernel
    cat > /etc/sysctl.d/99-memory.conf << EOF
# Optimización de memoria
vm.swappiness=$swappiness
vm.vfs_cache_pressure=$vfs_cache_pressure
vm.dirty_ratio=$dirty_ratio
vm.dirty_background_ratio=$dirty_background_ratio
vm.dirty_bytes=0
vm.dirty_background_bytes=0
EOF
    
    # Aplicar cambios
    sysctl -p /etc/sysctl.d/99-memory.conf
    
    log_success "Memoria optimizada"
}

# ================================
# 🌐 Optimización de Red
# ================================

optimize_network() {
    log_info "Optimizando configuración de red..."
    
    # Valores por defecto
    local tcp_congestion_control="bbr"
    local tcp_fastopen=3
    local somaxconn=1024
    local rmem_max=16777216
    local wmem_max=16777216
    
    # Intentar cargar desde configuración
    if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
        tcp_congestion_control=$(yq eval '.optimization.network.tcp_congestion_control' "$CONFIG_FILE" 2>/dev/null || echo "bbr")
        tcp_fastopen=$(yq eval '.optimization.network.tcp_fastopen' "$CONFIG_FILE" 2>/dev/null || echo "3")
        somaxconn=$(yq eval '.optimization.network.somaxconn' "$CONFIG_FILE" 2>/dev/null || echo "1024")
        rmem_max=$(yq eval '.optimization.network.rmem_max' "$CONFIG_FILE" 2>/dev/null || echo "16777216")
        wmem_max=$(yq eval '.optimization.network.wmem_max' "$CONFIG_FILE" 2>/dev/null || echo "16777216")
    fi
    
    # Configurar parámetros de red
    cat > /etc/sysctl.d/99-network.conf << EOF
# Optimización de red
net.core.rmem_max=$rmem_max
net.core.wmem_max=$wmem_max
net.ipv4.tcp_rmem=4096 87380 $rmem_max
net.ipv4.tcp_wmem=4096 65536 $wmem_max
net.core.netdev_max_backlog=2500
net.ipv4.tcp_fastopen=$tcp_fastopen
net.ipv4.tcp_congestion_control=$tcp_congestion_control
net.core.somaxconn=$somaxconn
EOF
    
    # Aplicar cambios
    sysctl -p /etc/sysctl.d/99-network.conf
    
    log_success "Red optimizada"
}

# ================================
# 💽 Optimización del Sistema de Archivos
# ================================

optimize_filesystem() {
    log_info "Optimizando sistema de archivos..."
    
    # Activar TRIM para SSD
    systemctl enable fstrim.timer
    systemctl start fstrim.timer
    
    # Valores por defecto
    local inotify_max_watches=524288
    local file_max=2097152
    
    # Intentar cargar desde configuración
    if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
        inotify_max_watches=$(yq eval '.optimization.filesystem.inotify_max_watches' "$CONFIG_FILE" 2>/dev/null || echo "524288")
        file_max=$(yq eval '.optimization.filesystem.file_max' "$CONFIG_FILE" 2>/dev/null || echo "2097152")
    fi
    
    # Configurar parámetros del sistema de archivos
    cat > /etc/sysctl.d/99-filesystem.conf << EOF
# Optimización de sistema de archivos
fs.inotify.max_user_watches=$inotify_max_watches
fs.file-max=$file_max
EOF
    
    # Aplicar cambios
    sysctl -p /etc/sysctl.d/99-filesystem.conf
    
    # Optimizar fstab para SSD
    if [[ -b /dev/sda ]] || [[ -b /dev/nvme0n1 ]]; then
        sed -i 's/errors=remount-ro/errors=remount-ro,noatime,commit=60/' /etc/fstab
        log_info "fstab optimizado para SSD"
    fi
    
    log_success "Sistema de archivos optimizado"
}

# ================================
# 🔋 Gestión Energética
# ================================

setup_power_management() {
    log_info "Configurando gestión energética..."
    
    # Instalar herramientas de gestión energética
    install_packages "tlp" "tlp-rdw" "powertop"
    
    # Valores por defecto
    local cpu_governor_ac="performance"
    local cpu_governor_bat="powersave"
    local cpu_max_perf_ac=100
    local cpu_max_perf_bat=30
    
    # Intentar cargar desde configuración
    if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
        cpu_governor_ac=$(yq eval '.optimization.power_management.cpu_governor_ac' "$CONFIG_FILE" 2>/dev/null || echo "performance")
        cpu_governor_bat=$(yq eval '.optimization.power_management.cpu_governor_bat' "$CONFIG_FILE" 2>/dev/null || echo "powersave")
        cpu_max_perf_ac=$(yq eval '.optimization.power_management.cpu_max_perf_ac' "$CONFIG_FILE" 2>/dev/null || echo "100")
        cpu_max_perf_bat=$(yq eval '.optimization.power_management.cpu_max_perf_bat' "$CONFIG_FILE" 2>/dev/null || echo "30")
    fi
    
    # Configurar TLP
    cat > /etc/tlp.conf << EOF
TLP_ENABLE=1
TLP_DEFAULT_MODE=BAT
CPU_SCALING_GOVERNOR_ON_AC=$cpu_governor_ac
CPU_SCALING_GOVERNOR_ON_BAT=$cpu_governor_bat
CPU_MIN_PERF_ON_AC=0
CPU_MAX_PERF_ON_AC=$cpu_max_perf_ac
CPU_MIN_PERF_ON_BAT=0
CPU_MAX_PERF_ON_BAT=$cpu_max_perf_bat
EOF
    
    # Habilitar y iniciar TLP
    enable_service "tlp"
    systemctl start tlp
    
    # Optimizar con powertop
    powertop --auto-tune
    
    log_success "Gestión energética configurada"
}

# ================================
# 🎮 Optimización GPU
# ================================

optimize_gpu() {
    log_info "Configurando GPU..."
    
    # Detectar tipo de GPU
    if lspci | grep -i nvidia > /dev/null; then
        setup_nvidia_gpu
    elif lspci | grep -i amd > /dev/null; then
        setup_amd_gpu
    else
        log_info "No se detectó GPU específica"
    fi
}

setup_nvidia_gpu() {
    log_info "Configurando GPU NVIDIA..."
    
    # Valores por defecto
    local driver_version="535"
    local memory_clock=2100
    local graphics_clock=800
    
    # Intentar cargar desde configuración
    if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
        driver_version=$(yq eval '.gpu.nvidia.driver_version' "$CONFIG_FILE" 2>/dev/null || echo "535")
        memory_clock=$(yq eval '.gpu.nvidia.memory_clock' "$CONFIG_FILE" 2>/dev/null || echo "2100")
        graphics_clock=$(yq eval '.gpu.nvidia.graphics_clock' "$CONFIG_FILE" 2>/dev/null || echo "800")
    fi
    
    # Instalar drivers NVIDIA
    install_packages "nvidia-driver-$driver_version" "nvidia-settings"
    
    # Optimizar configuración de NVIDIA
    if command_exists nvidia-smi; then
        nvidia-smi -pm 1
        nvidia-smi --auto-boost-default=0
        nvidia-smi -ac "$memory_clock,$graphics_clock"
        log_success "GPU NVIDIA optimizada"
    fi
}

setup_amd_gpu() {
    log_info "Configurando GPU AMD..."
    
    # Instalar drivers AMD
    install_packages "mesa-vulkan-drivers" "vulkan-tools"
    
    # Habilitar FreeSync si está disponible
    if [[ -f /sys/class/drm/card0/device/freesync ]]; then
        echo 1 > /sys/class/drm/card0/device/freesync
        log_info "FreeSync habilitado"
    fi
    
    log_success "GPU AMD configurada"
}

# ================================
# 💻 Optimizaciones para Desarrollo
# ================================

setup_development_optimizations() {
    log_info "Configurando optimizaciones para desarrollo..."
    
    # Configurar límites del sistema
    setup_system_limits
    
    # Optimizar Docker si está instalado
    if command_exists docker; then
        optimize_docker
    fi
    
    # Optimizar VSCode si está instalado
    if command_exists code; then
        optimize_vscode
    fi
    
    # Configurar herramientas de compilación
    setup_compilation_tools
    
    log_success "Optimizaciones para desarrollo configuradas"
}

setup_system_limits() {
    log_info "Configurando límites del sistema..."
    
    # Valores por defecto
    local nofile_soft=65535
    local nofile_hard=65535
    local nproc_soft=65535
    local nproc_hard=65535
    
    # Intentar cargar desde configuración
    if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
        nofile_soft=$(yq eval '.limits.nofile_soft' "$CONFIG_FILE" 2>/dev/null || echo "65535")
        nofile_hard=$(yq eval '.limits.nofile_hard' "$CONFIG_FILE" 2>/dev/null || echo "65535")
        nproc_soft=$(yq eval '.limits.nproc_soft' "$CONFIG_FILE" 2>/dev/null || echo "65535")
        nproc_hard=$(yq eval '.limits.nproc_hard' "$CONFIG_FILE" 2>/dev/null || echo "65535")
    fi
    
    # Configurar límites
    cat >> /etc/security/limits.conf << EOF
# Límites para desarrolladores
*               soft    nofile          $nofile_soft
*               hard    nofile          $nofile_hard
*               soft    nproc           $nproc_soft
*               hard    nproc           $nproc_hard
*               soft    memlock         unlimited
*               hard    memlock         unlimited
EOF
    
    log_success "Límites del sistema configurados"
}

optimize_docker() {
    log_info "Optimizando Docker..."
    
    # Valores por defecto
    local storage_driver="overlay2"
    local max_downloads=10
    local max_uploads=10
    
    # Intentar cargar desde configuración
    if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
        storage_driver=$(yq eval '.development.docker.storage_driver' "$CONFIG_FILE" 2>/dev/null || echo "overlay2")
        max_downloads=$(yq eval '.development.docker.max_concurrent_downloads' "$CONFIG_FILE" 2>/dev/null || echo "10")
        max_uploads=$(yq eval '.development.docker.max_concurrent_uploads' "$CONFIG_FILE" 2>/dev/null || echo "10")
    fi
    
    # Configurar daemon.json
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json << EOF
{
    "storage-driver": "$storage_driver",
    "max-concurrent-downloads": $max_downloads,
    "max-concurrent-uploads": $max_uploads,
    "default-ulimits": {
        "nofile": {
            "Name": "nofile",
            "Hard": 64000,
            "Soft": 64000
        }
    }
}
EOF
    
    # Reiniciar Docker
    systemctl restart docker
    
    log_success "Docker optimizado"
}

optimize_vscode() {
    log_info "Optimizando VSCode..."
    
    # Configurar límite de vigilancia de archivos
    local inotify_watches=524288
    
    if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
        inotify_watches=$(yq eval '.ide.vscode.inotify_watches' "$CONFIG_FILE" 2>/dev/null || echo "524288")
    fi
    
    echo "fs.inotify.max_user_watches=$inotify_watches" > /etc/sysctl.d/99-vscode.conf
    sysctl -p /etc/sysctl.d/99-vscode.conf
    
    log_success "VSCode optimizado"
}

setup_compilation_tools() {
    log_info "Configurando herramientas de compilación..."
    
    # Instalar herramientas
    install_packages "ccache" "iotop" "sysstat" "linux-tools-common"
    
    # Configurar ccache
    local ccache_size="50G"
    
    if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
        ccache_size=$(yq eval '.compilation.ccache_size' "$CONFIG_FILE" 2>/dev/null || echo "50G")
    fi
    
    cat > /etc/profile.d/ccache.sh << EOF
export PATH="/usr/lib/ccache:\$PATH"
export CCACHE_DIR="/var/cache/ccache"
export CCACHE_SIZE=$ccache_size
EOF
    
    # Configurar variables de entorno para compilación
    local java_memory="4G"
    local gradle_memory="4G"
    local maven_memory="4G"
    
    if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
        java_memory=$(yq eval '.compilation.java_memory' "$CONFIG_FILE" 2>/dev/null || echo "4G")
        gradle_memory=$(yq eval '.compilation.gradle_memory' "$CONFIG_FILE" 2>/dev/null || echo "4G")
        maven_memory=$(yq eval '.compilation.maven_memory' "$CONFIG_FILE" 2>/dev/null || echo "4G")
    fi
    
    cat >> /etc/environment << EOF
# Optimización para compilación
MAKEFLAGS="-j\$(nproc)"
JAVA_TOOL_OPTIONS="-Xmx$java_memory"
GRADLE_OPTS="-Xmx$gradle_memory -Dorg.gradle.daemon=true -Dorg.gradle.parallel=true"
MAVEN_OPTS="-Xmx$maven_memory"
EOF
    
    log_success "Herramientas de compilación configuradas"
}

# ================================
# 📊 Sistema de Monitoreo
# ================================

setup_monitoring() {
    log_info "Configurando sistema de monitoreo..."
    
    # Instalar herramientas de monitoreo
    local monitoring_tools=("htop" "iotop" "nethogs" "iftop")
    
    if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
        local config_tools=$(yq eval '.monitoring.tools[]' "$CONFIG_FILE" 2>/dev/null)
        if [[ -n "$config_tools" ]]; then
            monitoring_tools=($config_tools)
        fi
    fi
    
    install_packages "${monitoring_tools[@]}"
    
    # Configurar Grafana si está habilitado
    if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
        local grafana_enabled=$(yq eval '.monitoring.grafana.enabled' "$CONFIG_FILE" 2>/dev/null || echo "false")
        if [[ "$grafana_enabled" == "true" ]]; then
            setup_grafana
        fi
    fi
    
    log_success "Sistema de monitoreo configurado"
}

setup_grafana() {
    log_info "Configurando Grafana..."
    
    # Instalar Grafana
    install_packages "grafana"
    
    # Configurar Grafana
    local admin_password="admin123"
    local port=3000
    
    if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
        admin_password=$(yq eval '.monitoring.grafana.admin_password' "$CONFIG_FILE" 2>/dev/null || echo "admin123")
        port=$(yq eval '.monitoring.grafana.port' "$CONFIG_FILE" 2>/dev/null || echo "3000")
    fi
    
    # Configurar contraseña de administrador
    grafana-cli admin reset-admin-password "$admin_password"
    
    # Habilitar y iniciar Grafana
    enable_service "grafana-server"
    systemctl start grafana-server
    
    log_success "Grafana configurado en puerto $port"
}

# ================================
# 🔧 Función Principal
# ================================

main_system_optimization() {
    log_info "Iniciando optimización del sistema..."
    
    # Crear backup antes de comenzar
    if [[ "$BACKUP_ENABLED" == "true" ]]; then
        create_backup "$BACKUP_DIR"
    fi
    
    # Ejecutar optimizaciones
    local optimizations=(
        "update_and_clean_system"
        "manage_services"
        "optimize_boot"
        "optimize_memory"
        "optimize_network"
        "optimize_filesystem"
        "setup_power_management"
        "optimize_gpu"
        "setup_development_optimizations"
        "setup_monitoring"
    )
    
    local total=${#optimizations[@]}
    local current=0
    
    for optimization in "${optimizations[@]}"; do
        ((current++))
        show_progress "$current" "$total" "Ejecutando $optimization..."
        
        if $optimization; then
            log_success "$optimization completado"
        else
            log_error "Error en $optimization"
            # Continuar con las siguientes optimizaciones
        fi
    done
    
    echo "" # Nueva línea después del progreso
    
    # Limpiar archivos temporales
    cleanup_temp_files
    
    # Mostrar estadísticas finales
    show_system_stats
    
    log_success "Optimización del sistema completada"
    show_summary
    
    echo -e "${GREEN}✅ Optimización completada exitosamente${NC}"
    echo -e "${YELLOW}⚠️  Se recomienda reiniciar el sistema para aplicar todos los cambios${NC}"
    
    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_system_optimization
fi 