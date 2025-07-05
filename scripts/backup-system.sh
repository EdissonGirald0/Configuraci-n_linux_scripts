#!/bin/bash

# Script para crear snapshots del sistema antes de pruebas
# Uso: ./backup-system.sh [backup-name]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función de logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Verificar si se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   error "Este script debe ejecutarse como root (sudo)"
   exit 1
fi

# Nombre del backup
BACKUP_NAME="${1:-system_backup_$(date +%Y%m%d_%H%M%S)}"
BACKUP_DIR="/root/system_backups"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# Crear directorio de backups si no existe
mkdir -p "$BACKUP_DIR"

log "Creando snapshot del sistema: $BACKUP_NAME"

# Función para crear backup de archivos críticos
backup_critical_files() {
    log "Respaldando archivos críticos del sistema..."
    
    mkdir -p "$BACKUP_PATH/critical_files"
    
    # Lista de archivos críticos
    CRITICAL_FILES=(
        "/etc/fstab"
        "/etc/default/grub"
        "/etc/sysctl.conf"
        "/etc/systemd/system.conf"
        "/etc/systemd/user.conf"
        "/etc/security/limits.conf"
        "/etc/environment"
        "/etc/bash.bashrc"
        "/etc/profile"
        "/etc/hosts"
        "/etc/resolv.conf"
        "/etc/network/interfaces"
        "/etc/apt/sources.list"
        "/etc/apt/sources.list.d/"
        "/etc/passwd"
        "/etc/group"
        "/etc/shadow"
        "/etc/gshadow"
    )
    
    for file in "${CRITICAL_FILES[@]}"; do
        if [[ -e "$file" ]]; then
            if [[ -d "$file" ]]; then
                cp -r "$file" "$BACKUP_PATH/critical_files/"
            else
                cp "$file" "$BACKUP_PATH/critical_files/"
            fi
            log "  ✓ Respaldado: $file"
        else
            warning "  ⚠ No encontrado: $file"
        fi
    done
}

# Función para crear backup de configuraciones de usuario
backup_user_configs() {
    log "Respaldando configuraciones de usuario..."
    
    mkdir -p "$BACKUP_PATH/user_configs"
    
    # Configuraciones de usuario comunes
    USER_CONFIGS=(
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.profile"
        "$HOME/.gitconfig"
        "$HOME/.ssh/"
        "$HOME/.config/"
        "$HOME/.local/"
    )
    
    for config in "${USER_CONFIGS[@]}"; do
        if [[ -e "$config" ]]; then
            if [[ -d "$config" ]]; then
                cp -r "$config" "$BACKUP_PATH/user_configs/"
            else
                cp "$config" "$BACKUP_PATH/user_configs/"
            fi
            log "  ✓ Respaldado: $config"
        fi
    done
}

# Función para crear backup de paquetes instalados
backup_packages() {
    log "Respaldando lista de paquetes instalados..."
    
    mkdir -p "$BACKUP_PATH/packages"
    
    # Lista de paquetes apt
    dpkg --get-selections > "$BACKUP_PATH/packages/installed_packages.txt"
    
    # Lista de repositorios
    cp /etc/apt/sources.list "$BACKUP_PATH/packages/"
    if [[ -d /etc/apt/sources.list.d ]]; then
        cp -r /etc/apt/sources.list.d "$BACKUP_PATH/packages/"
    fi
    
    # Lista de snaps
    if command -v snap &> /dev/null; then
        snap list > "$BACKUP_PATH/packages/installed_snaps.txt"
    fi
    
    # Lista de flatpaks
    if command -v flatpak &> /dev/null; then
        flatpak list > "$BACKUP_PATH/packages/installed_flatpaks.txt"
    fi
    
    log "  ✓ Lista de paquetes respaldada"
}

# Función para crear backup de servicios
backup_services() {
    log "Respaldando configuración de servicios..."
    
    mkdir -p "$BACKUP_PATH/services"
    
    # Lista de servicios habilitados
    systemctl list-unit-files --state=enabled > "$BACKUP_PATH/services/enabled_services.txt"
    
    # Lista de servicios en ejecución
    systemctl list-units --type=service --state=running > "$BACKUP_PATH/services/running_services.txt"
    
    # Configuraciones de systemd
    if [[ -d /etc/systemd ]]; then
        cp -r /etc/systemd "$BACKUP_PATH/services/"
    fi
    
    log "  ✓ Configuración de servicios respaldada"
}

# Función para crear backup de red
backup_network() {
    log "Respaldando configuración de red..."
    
    mkdir -p "$BACKUP_PATH/network"
    
    # Configuración de red
    ip addr show > "$BACKUP_PATH/network/network_interfaces.txt"
    ip route show > "$BACKUP_PATH/network/routing_table.txt"
    
    # Configuraciones de red
    if [[ -d /etc/netplan ]]; then
        cp -r /etc/netplan "$BACKUP_PATH/network/"
    fi
    
    if [[ -d /etc/NetworkManager ]]; then
        cp -r /etc/NetworkManager "$BACKUP_PATH/network/"
    fi
    
    log "  ✓ Configuración de red respaldada"
}

# Función para crear backup de kernel
backup_kernel() {
    log "Respaldando información del kernel..."
    
    mkdir -p "$BACKUP_PATH/kernel"
    
    # Información del kernel
    uname -a > "$BACKUP_PATH/kernel/kernel_info.txt"
    cat /proc/version > "$BACKUP_PATH/kernel/proc_version.txt"
    
    # Módulos cargados
    lsmod > "$BACKUP_PATH/kernel/loaded_modules.txt"
    
    # Parámetros del kernel
    cat /proc/cmdline > "$BACKUP_PATH/kernel/kernel_cmdline.txt"
    
    log "  ✓ Información del kernel respaldada"
}

# Función para crear backup de hardware
backup_hardware() {
    log "Respaldando información de hardware..."
    
    mkdir -p "$BACKUP_PATH/hardware"
    
    # Información de CPU
    lscpu > "$BACKUP_PATH/hardware/cpu_info.txt"
    
    # Información de memoria
    free -h > "$BACKUP_PATH/hardware/memory_info.txt"
    
    # Información de discos
    lsblk > "$BACKUP_PATH/hardware/disk_info.txt"
    fdisk -l > "$BACKUP_PATH/hardware/partition_info.txt"
    
    # Información de GPU
    if command -v nvidia-smi &> /dev/null; then
        nvidia-smi > "$BACKUP_PATH/hardware/gpu_info.txt"
    fi
    
    # Información de PCI
    lspci > "$BACKUP_PATH/hardware/pci_devices.txt"
    
    log "  ✓ Información de hardware respaldada"
}

# Función para crear backup de logs
backup_logs() {
    log "Respaldando logs del sistema..."
    
    mkdir -p "$BACKUP_PATH/logs"
    
    # Logs importantes
    if [[ -f /var/log/syslog ]]; then
        cp /var/log/syslog "$BACKUP_PATH/logs/"
    fi
    
    if [[ -f /var/log/auth.log ]]; then
        cp /var/log/auth.log "$BACKUP_PATH/logs/"
    fi
    
    # Logs de journalctl
    journalctl --since "1 hour ago" > "$BACKUP_PATH/logs/recent_journal.log"
    
    log "  ✓ Logs del sistema respaldados"
}

# Función para crear metadatos del backup
create_backup_metadata() {
    log "Creando metadatos del backup..."
    
    cat > "$BACKUP_PATH/backup_info.txt" << EOF
Backup creado: $(date)
Nombre: $BACKUP_NAME
Sistema: $(uname -a)
Usuario: $SUDO_USER
Directorio: $BACKUP_PATH
Tamaño: $(du -sh "$BACKUP_PATH" | cut -f1)

Archivos respaldados:
- Archivos críticos del sistema
- Configuraciones de usuario
- Lista de paquetes instalados
- Configuración de servicios
- Configuración de red
- Información del kernel
- Información de hardware
- Logs del sistema

Para restaurar:
1. Revisar archivos en: $BACKUP_PATH
2. Copiar archivos necesarios de vuelta al sistema
3. Reiniciar servicios afectados
4. Reiniciar el sistema si es necesario
EOF
    
    log "  ✓ Metadatos creados"
}

# Función para comprimir backup
compress_backup() {
    log "Comprimiendo backup..."
    
    cd "$BACKUP_DIR"
    tar -czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"
    
    # Calcular tamaño
    BACKUP_SIZE=$(du -sh "${BACKUP_NAME}.tar.gz" | cut -f1)
    
    success "Backup comprimido: ${BACKUP_NAME}.tar.gz ($BACKUP_SIZE)"
    
    # Limpiar directorio sin comprimir
    rm -rf "$BACKUP_NAME"
}

# Función principal
main() {
    log "Iniciando backup del sistema..."
    
    # Crear backup completo
    backup_critical_files
    backup_user_configs
    backup_packages
    backup_services
    backup_network
    backup_kernel
    backup_hardware
    backup_logs
    create_backup_metadata
    
    # Comprimir backup
    compress_backup
    
    success "Backup completado exitosamente!"
    log "Ubicación: $BACKUP_DIR/${BACKUP_NAME}.tar.gz"
    log "Para restaurar, extrae el archivo y copia los archivos necesarios"
}

# Ejecutar función principal
main "$@" 