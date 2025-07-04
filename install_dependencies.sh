#!/bin/bash

# ================================
# 📦 Instalador de Dependencias
# ================================
# Archivo: install_dependencies.sh
# Descripción: Instala las dependencias necesarias para el proyecto refactorizado

# Importar utilidades
source "$(dirname "$0")/lib/utils.sh"

# ================================
# 🔧 Dependencias del Sistema
# ================================

install_system_dependencies() {
    log_info "Instalando dependencias del sistema..."
    
    # Paquetes base necesarios
    local base_packages=(
        "curl"
        "wget"
        "git"
        "build-essential"
        "software-properties-common"
        "ca-certificates"
        "gnupg"
        "lsb-release"
        "unzip"
        "zip"
    )
    
    # Paquetes para parsear YAML
    local yaml_packages=(
        "yq"
    )
    
    # Instalar paquetes base
    if install_packages "${base_packages[@]}"; then
        log_success "Paquetes base instalados"
    else
        log_error "Error al instalar paquetes base"
        return 1
    fi
    
    # Instalar yq para parsear YAML
    if ! command_exists yq; then
        log_info "Instalando yq para parsear archivos YAML..."
        
        # Detectar arquitectura
        local arch=$(uname -m)
        local yq_version="v4.40.5"
        local yq_url=""
        
        case "$arch" in
            "x86_64")
                yq_url="https://github.com/mikefarah/yq/releases/download/${yq_version}/yq_linux_amd64"
                ;;
            "aarch64"|"arm64")
                yq_url="https://github.com/mikefarah/yq/releases/download/${yq_version}/yq_linux_arm64"
                ;;
            *)
                log_error "Arquitectura no soportada: $arch"
                return 1
                ;;
        esac
        
        # Descargar e instalar yq
        if curl -L "$yq_url" -o /tmp/yq && chmod +x /tmp/yq && sudo mv /tmp/yq /usr/local/bin/yq; then
            log_success "yq instalado correctamente"
        else
            log_error "Error al instalar yq"
            return 1
        fi
    else
        log_info "yq ya está instalado"
    fi
    
    return 0
}

# ================================
# 🐍 Dependencias de Python
# ================================

install_python_dependencies() {
    log_info "Instalando dependencias de Python..."
    
    # Verificar si Python está instalado
    if ! command_exists python3; then
        log_info "Instalando Python 3..."
        install_packages "python3" "python3-pip" "python3-venv"
    fi
    
    # Instalar herramientas de Python
    local python_tools=(
        "pip"
        "setuptools"
        "wheel"
    )
    
    for tool in "${python_tools[@]}"; do
        log_info "Actualizando $tool..."
        python3 -m pip install --upgrade "$tool"
    done
    
    log_success "Dependencias de Python instaladas"
    return 0
}

# ================================
# 🔧 Herramientas de Desarrollo
# ================================

install_dev_tools() {
    log_info "Instalando herramientas de desarrollo..."
    
    # Herramientas de desarrollo básicas
    local dev_tools=(
        "cmake"
        "gdb"
        "valgrind"
        "pkg-config"
        "libssl-dev"
        "libffi-dev"
        "libxml2-dev"
        "libxslt1-dev"
        "python3-dev"
        "libjpeg-dev"
        "zlib1g-dev"
        "libfreetype6-dev"
    )
    
    if install_packages "${dev_tools[@]}"; then
        log_success "Herramientas de desarrollo instaladas"
    else
        log_error "Error al instalar herramientas de desarrollo"
        return 1
    fi
    
    return 0
}

# ================================
# 🎞️ Soporte Multimedia
# ================================

install_multimedia_support() {
    log_info "Instalando soporte multimedia..."
    
    # Codecs y librerías multimedia
    local multimedia_packages=(
        "ubuntu-restricted-extras"
        "ffmpeg"
        "gstreamer1.0-plugins-base"
        "gstreamer1.0-plugins-good"
        "gstreamer1.0-plugins-bad"
        "gstreamer1.0-plugins-ugly"
        "libavcodec-extra"
    )
    
    if install_packages "${multimedia_packages[@]}"; then
        log_success "Soporte multimedia instalado"
    else
        log_error "Error al instalar soporte multimedia"
        return 1
    fi
    
    return 0
}

# ================================
# 💽 Soporte de Sistemas de Archivos
# ================================

install_filesystem_support() {
    log_info "Instalando soporte para sistemas de archivos..."
    
    # Soporte para diferentes sistemas de archivos
    local filesystem_packages=(
        "exfat-fuse"
        "exfat-utils"
        "ntfs-3g"
        "hfsplus"
        "hfsutils"
        "hfsprogs"
        "dosfstools"
    )
    
    if install_packages "${filesystem_packages[@]}"; then
        log_success "Soporte de sistemas de archivos instalado"
    else
        log_error "Error al instalar soporte de sistemas de archivos"
        return 1
    fi
    
    return 0
}

# ================================
# 🔍 Verificación de Dependencias
# ================================

verify_dependencies() {
    log_info "Verificando dependencias instaladas..."
    
    local required_commands=(
        "curl"
        "wget"
        "git"
        "python3"
        "pip3"
        "yq"
        "cmake"
        "gcc"
        "make"
    )
    
    local missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        log_error "Dependencias faltantes: ${missing_commands[*]}"
        return 1
    else
        log_success "Todas las dependencias están instaladas"
        return 0
    fi
}

# ================================
# 📊 Información del Sistema
# ================================

show_system_info() {
    echo -e "${BLUE}📊 Información del Sistema:${NC}"
    echo "=================================================="
    
    # Distribución
    if [[ -f /etc/os-release ]]; then
        local distro=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
        echo -e "${CYAN}Distribución:${NC} $distro"
    fi
    
    # Kernel
    echo -e "${CYAN}Kernel:${NC} $(uname -r)"
    
    # Arquitectura
    echo -e "${CYAN}Arquitectura:${NC} $(uname -m)"
    
    # Memoria
    local mem_info=$(free -h | awk 'NR==2{printf "%s/%s", $3, $2}')
    echo -e "${CYAN}Memoria:${NC} $mem_info"
    
    # Espacio en disco
    local disk_info=$(df -h / | awk 'NR==2{printf "%s/%s (%s)", $3, $2, $5}')
    echo -e "${CYAN}Disco:${NC} $disk_info"
    
    echo "=================================================="
}

# ================================
# 🔧 Función Principal
# ================================

main() {
    # Mostrar banner
    show_banner
    
    # Mostrar información del sistema
    show_system_info
    
    # Verificar privilegios de root
    check_root
    
    # Verificar conectividad de red
    if ! check_network_connectivity; then
        log_error "No hay conectividad de red"
        exit 1
    fi
    
    log_info "Iniciando instalación de dependencias..."
    
    # Actualizar repositorios
    log_info "Actualizando repositorios..."
    apt update
    
    # Instalar dependencias
    local installation_steps=(
        "install_system_dependencies"
        "install_python_dependencies"
        "install_dev_tools"
        "install_multimedia_support"
        "install_filesystem_support"
    )
    
    local total_steps=${#installation_steps[@]}
    local current=0
    local successful_steps=0
    local failed_steps=0
    
    for step in "${installation_steps[@]}"; do
        ((current++))
        show_progress "$current" "$total_steps" "Ejecutando $step..."
        
        if $step; then
            ((successful_steps++))
        else
            ((failed_steps++))
        fi
    done
    
    echo "" # Nueva línea después del progreso
    
    # Verificar dependencias
    if verify_dependencies; then
        log_success "Instalación de dependencias completada"
    else
        log_error "Algunas dependencias no se instalaron correctamente"
        ((failed_steps++))
    fi
    
    # Mostrar resumen
    echo -e "\n${BLUE}📊 Resumen de Instalación:${NC}"
    echo "=================================================="
    echo -e "${CYAN}Total de pasos:${NC} $total_steps"
    echo -e "${GREEN}Exitosos:${NC} $successful_steps"
    
    if [[ $failed_steps -gt 0 ]]; then
        echo -e "${RED}Fallidos:${NC} $failed_steps"
    fi
    
    echo "=================================================="
    
    if [[ $failed_steps -eq 0 ]]; then
        echo -e "\n${GREEN}✅ Dependencias instaladas correctamente${NC}"
        echo -e "${CYAN}📝 Próximos pasos:${NC}"
        echo "  1. Ejecutar el script principal: sudo ./setup.sh"
        echo "  2. Personalizar la configuración en config/config.yaml"
        echo "  3. Revisar la documentación en README_REFACTORIZADO.md"
    else
        echo -e "\n${YELLOW}⚠️  Instalación completada con errores${NC}"
        echo -e "${CYAN}📝 Acciones recomendadas:${NC}"
        echo "  1. Revisar los logs para identificar problemas"
        echo "  2. Ejecutar manualmente los pasos fallidos"
        echo "  3. Verificar la conectividad de red"
    fi
    
    return $failed_steps
}

# ================================
# 🚀 Punto de Entrada
# ================================

# Ejecutar función principal
main "$@" 