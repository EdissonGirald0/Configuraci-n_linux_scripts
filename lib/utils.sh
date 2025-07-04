#!/bin/bash

# ================================
# 📚 Biblioteca de Utilidades Comunes
# ================================
# Archivo: lib/utils.sh
# Descripción: Funciones reutilizables para todos los scripts

# Colores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Configuración global
readonly CONFIG_FILE="config/config.yaml"
readonly LOG_FILE="/var/log/system_optimization.log"
readonly BACKUP_DIR="/root/system_backup_$(date +%Y%m%d)"

# ================================
# 🔧 Funciones de Logging
# ================================

# Función para logging con timestamp
log() {
    local level="${1:-INFO}"
    local message="${2:-}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${CYAN}[${timestamp}] ${level}:${NC} ${message}" | tee -a "$LOG_FILE"
}

log_info() {
    log "INFO" "$1"
}

log_warn() {
    log "WARN" "$1"
}

log_error() {
    log "ERROR" "$1"
}

log_success() {
    log "SUCCESS" "$1"
}

# ================================
# ✅ Funciones de Validación
# ================================

# Verificar si el script se ejecuta como root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}❌ Este script debe ejecutarse como root (sudo)${NC}"
        exit 1
    fi
}

# Verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Verificar si un archivo existe
file_exists() {
    [[ -f "$1" ]]
}

# Verificar si un directorio existe
dir_exists() {
    [[ -d "$1" ]]
}

# Verificar si un paquete está instalado
package_installed() {
    dpkg -l "$1" >/dev/null 2>&1
}

# ================================
# 🔄 Funciones de Gestión de Errores
# ================================

# Función para manejo de errores
error_handler() {
    local exit_code=$?
    local line_number=$1
    local command_name=$2
    
    log_error "Error en línea $line_number: $command_name (código: $exit_code)"
    
    # Crear backup de emergencia si es necesario
    if [[ -n "$BACKUP_DIR" ]]; then
        log_warn "Creando backup de emergencia..."
        create_emergency_backup
    fi
    
    exit $exit_code
}

# Configurar trap para manejo de errores
set_error_trap() {
    trap 'error_handler ${LINENO} "$BASH_COMMAND"' ERR
}

# Función para rollback
rollback_changes() {
    local backup_path="$1"
    
    if [[ -d "$backup_path" ]]; then
        log_warn "Ejecutando rollback desde: $backup_path"
        
        # Restaurar archivos críticos
        if [[ -f "$backup_path/grub" ]]; then
            cp "$backup_path/grub" /etc/default/grub
            update-grub
            log_success "GRUB restaurado"
        fi
        
        if [[ -f "$backup_path/fstab" ]]; then
            cp "$backup_path/fstab" /etc/fstab
            log_success "fstab restaurado"
        fi
        
        if [[ -f "$backup_path/sysctl.conf" ]]; then
            cp "$backup_path/sysctl.conf" /etc/sysctl.conf
            sysctl -p
            log_success "sysctl.conf restaurado"
        fi
    else
        log_error "No se encontró backup para rollback"
    fi
}

# ================================
# 💾 Funciones de Backup
# ================================

# Crear backup de archivos críticos
create_backup() {
    local backup_path="$1"
    
    log_info "Creando backup en: $backup_path"
    mkdir -p "$backup_path"
    
    # Archivos críticos del sistema
    local critical_files=(
        "/etc/default/grub"
        "/etc/fstab"
        "/etc/sysctl.conf"
        "/etc/security/limits.conf"
        "/etc/docker/daemon.json"
    )
    
    for file in "${critical_files[@]}"; do
        if [[ -f "$file" ]]; then
            cp "$file" "$backup_path/"
            log_info "Backup creado: $file"
        fi
    done
    
    log_success "Backup completado"
}

# Crear backup de emergencia
create_emergency_backup() {
    local emergency_backup="/root/emergency_backup_$(date +%Y%m%d_%H%M%S)"
    create_backup "$emergency_backup"
    log_warn "Backup de emergencia creado en: $emergency_backup"
}

# ================================
# ⚙️ Funciones de Configuración
# ================================

# Cargar configuración desde YAML
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Archivo de configuración no encontrado: $CONFIG_FILE"
        return 1
    fi
    
    # Verificar si yq está instalado para parsear YAML
    if ! command_exists yq; then
        log_warn "yq no está instalado, usando configuración por defecto"
        return 0
    fi
    
    # Cargar valores de configuración
    export SYSTEM_DISTRIBUTION=$(yq eval '.system.distribution' "$CONFIG_FILE" 2>/dev/null || echo "pop_os")
    export BACKUP_ENABLED=$(yq eval '.system.backup_enabled' "$CONFIG_FILE" 2>/dev/null || echo "true")
    export LOG_LEVEL=$(yq eval '.system.log_level' "$CONFIG_FILE" 2>/dev/null || echo "INFO")
    
    log_info "Configuración cargada desde: $CONFIG_FILE"
}

# ================================
# 🔍 Funciones de Verificación
# ================================

# Verificar requisitos del sistema
check_system_requirements() {
    log_info "Verificando requisitos del sistema..."
    
    # Verificar distribución
    if [[ ! -f /etc/os-release ]]; then
        log_error "No se puede determinar la distribución del sistema"
        return 1
    fi
    
    # Verificar espacio en disco
    local available_space=$(df / | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 1048576 ]]; then  # Menos de 1GB
        log_warn "Poco espacio en disco disponible: ${available_space}KB"
    fi
    
    # Verificar memoria RAM
    local total_mem=$(free -m | awk 'NR==2{print $2}')
    if [[ $total_mem -lt 2048 ]]; then  # Menos de 2GB
        log_warn "Poca memoria RAM disponible: ${total_mem}MB"
    fi
    
    log_success "Verificación de requisitos completada"
}

# Verificar conectividad de red
check_network_connectivity() {
    log_info "Verificando conectividad de red..."
    
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log_success "Conectividad de red verificada"
        return 0
    else
        log_error "No hay conectividad de red"
        return 1
    fi
}

# ================================
# 🛠️ Funciones de Instalación
# ================================

# Instalar paquete con manejo de errores
install_package() {
    local package="$1"
    local description="${2:-$package}"
    
    log_info "Instalando $description..."
    
    if package_installed "$package"; then
        log_info "$description ya está instalado"
        return 0
    fi
    
    if apt install -y "$package"; then
        log_success "$description instalado correctamente"
        return 0
    else
        log_error "Error al instalar $description"
        return 1
    fi
}

# Instalar múltiples paquetes
install_packages() {
    local packages=("$@")
    local failed_packages=()
    
    for package in "${packages[@]}"; do
        if ! install_package "$package"; then
            failed_packages+=("$package")
        fi
    done
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_error "Paquetes que fallaron: ${failed_packages[*]}"
        return 1
    fi
    
    return 0
}

# ================================
# 🔄 Funciones de Servicios
# ================================

# Habilitar servicio
enable_service() {
    local service="$1"
    
    if systemctl enable "$service" >/dev/null 2>&1; then
        log_success "Servicio $service habilitado"
        return 0
    else
        log_error "Error al habilitar servicio $service"
        return 1
    fi
}

# Deshabilitar servicio
disable_service() {
    local service="$1"
    
    if systemctl disable --now "$service" >/dev/null 2>&1; then
        log_success "Servicio $service deshabilitado"
        return 0
    else
        log_warn "No se pudo deshabilitar servicio $service (puede no existir)"
        return 0
    fi
}

# ================================
# 📊 Funciones de Monitoreo
# ================================

# Mostrar estadísticas del sistema
show_system_stats() {
    echo -e "${BLUE}📊 Estadísticas del Sistema:${NC}"
    echo "----------------------------------------"
    
    # CPU
    echo -e "${CYAN}CPU:${NC} $(nproc) cores"
    
    # Memoria
    local mem_info=$(free -h | awk 'NR==2{printf "Memoria: %s/%s", $3, $2}')
    echo -e "${CYAN}Memoria:${NC} $mem_info"
    
    # Disco
    local disk_info=$(df -h / | awk 'NR==2{printf "%s/%s (%s)", $3, $2, $5}')
    echo -e "${CYAN}Disco:${NC} $disk_info"
    
    # Distribución
    local distro=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
    echo -e "${CYAN}Distribución:${NC} $distro"
    
    echo "----------------------------------------"
}

# ================================
# 🎨 Funciones de UI
# ================================

# Mostrar banner
show_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    🚀 Configuración Linux                    ║"
    echo "║                    Optimización y Desarrollo                 ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Mostrar progreso
show_progress() {
    local current="$1"
    local total="$2"
    local description="$3"
    
    local percentage=$((current * 100 / total))
    local filled=$((percentage / 2))
    local empty=$((50 - filled))
    
    printf "\r[%-50s] %d%% - %s" "$(printf '#%.0s' $(seq 1 $filled))$(printf ' %.0s' $(seq 1 $empty))" "$percentage" "$description"
}

# Mostrar resumen final
show_summary() {
    echo -e "\n${GREEN}✅ Resumen de la Operación:${NC}"
    echo "----------------------------------------"
    echo -e "${CYAN}Logs:${NC} $LOG_FILE"
    echo -e "${CYAN}Backup:${NC} $BACKUP_DIR"
    echo -e "${CYAN}Configuración:${NC} $CONFIG_FILE"
    echo "----------------------------------------"
}

# ================================
# 🧹 Funciones de Limpieza
# ================================

# Limpiar archivos temporales
cleanup_temp_files() {
    log_info "Limpiando archivos temporales..."
    
    # Limpiar cache de apt
    apt clean >/dev/null 2>&1
    apt autoclean >/dev/null 2>&1
    
    # Limpiar logs antiguos
    journalctl --vacuum-time=7d >/dev/null 2>&1
    
    # Limpiar archivos temporales del usuario
    rm -rf /tmp/* >/dev/null 2>&1
    
    log_success "Limpieza completada"
}

# ================================
# 🔧 Función de Inicialización
# ================================

# Inicializar el entorno
init_environment() {
    # Configurar manejo de errores
    set_error_trap
    
    # Mostrar banner
    show_banner
    
    # Verificar privilegios de root
    check_root
    
    # Cargar configuración
    load_config
    
    # Verificar requisitos
    check_system_requirements
    
    # Crear directorio de logs si no existe
    mkdir -p "$(dirname "$LOG_FILE")"
    
    log_info "Entorno inicializado correctamente"
} 