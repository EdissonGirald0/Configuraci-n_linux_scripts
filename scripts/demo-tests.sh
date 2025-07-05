#!/bin/bash

# Script de demostración para mostrar las capacidades de pruebas
# Uso: ./demo-tests.sh

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Función para mostrar banner
show_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    🧪 DEMO DE PRUEBAS                        ║"
    echo "║              Sistema de Configuración Linux                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Función para mostrar menú
show_menu() {
    echo -e "${CYAN}Selecciona una opción de demostración:${NC}"
    echo
    echo "1. 🟢 Modo Simulación (100% Seguro)"
    echo "2. 🐳 Pruebas en Docker (Aislado)"
    echo "3. 💾 Crear Backup del Sistema"
    echo "4. 🛡️  Pruebas Seguras con Backup"
    echo "5. ⚠️  Pruebas Completas (Solo VM)"
    echo "6. 📊 Ver Información del Sistema"
    echo "7. 🔧 Verificar Prerrequisitos"
    echo "8. 📖 Mostrar Ayuda"
    echo "9. 🚪 Salir"
    echo
}

# Función para modo simulación
demo_dry_run() {
    echo -e "${GREEN}🟢 DEMO: Modo Simulación${NC}"
    echo "Este modo es 100% seguro y no hace cambios reales en tu sistema."
    echo
    info "Ejecutando modo simulación..."
    
    if ./scripts/test-system.sh dry-run -v; then
        success "¡Demo de simulación completada exitosamente!"
    else
        error "Error en la demo de simulación"
    fi
}

# Función para pruebas Docker
demo_docker() {
    echo -e "${BLUE}🐳 DEMO: Pruebas en Docker${NC}"
    echo "Este modo ejecuta las pruebas en un contenedor aislado."
    echo
    info "Verificando Docker..."
    
    if ! command -v docker &> /dev/null; then
        warning "Docker no está instalado. Instalando..."
        sudo apt update
        sudo apt install -y docker.io docker-compose
        sudo usermod -aG docker $USER
        newgrp docker
    fi
    
    info "Ejecutando pruebas en Docker..."
    
    if ./scripts/test-system.sh docker; then
        success "¡Demo de Docker completada exitosamente!"
    else
        error "Error en la demo de Docker"
    fi
}

# Función para crear backup
demo_backup() {
    echo -e "${YELLOW}💾 DEMO: Crear Backup del Sistema${NC}"
    echo "Este modo crea un snapshot completo de tu sistema."
    echo
    info "Creando backup del sistema..."
    
    if sudo ./scripts/backup-system.sh "demo_backup_$(date +%Y%m%d_%H%M%S)"; then
        success "¡Backup creado exitosamente!"
        info "Ubicación: /root/system_backups/"
    else
        error "Error al crear backup"
    fi
}

# Función para pruebas seguras
demo_safe() {
    echo -e "${YELLOW}🛡️  DEMO: Pruebas Seguras${NC}"
    echo "Este modo crea un backup automático antes de las pruebas."
    echo
    warning "¿Deseas continuar con las pruebas seguras? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        info "Demo cancelada por el usuario"
        return 0
    fi
    
    info "Ejecutando pruebas seguras..."
    
    if ./scripts/test-system.sh safe -m python; then
        success "¡Demo de pruebas seguras completada!"
    else
        error "Error en las pruebas seguras"
    fi
}

# Función para pruebas completas
demo_full() {
    echo -e "${RED}⚠️  DEMO: Pruebas Completas${NC}"
    echo "ADVERTENCIA: Este modo puede modificar tu sistema."
    echo "Solo ejecuta esto en un entorno controlado o VM."
    echo
    warning "¿Estás seguro de que quieres continuar? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        info "Demo cancelada por el usuario"
        return 0
    fi
    
    warning "¿Realmente estás seguro? Esto puede modificar tu sistema. (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        info "Demo cancelada por el usuario"
        return 0
    fi
    
    info "Ejecutando pruebas completas..."
    
    if ./scripts/test-system.sh full; then
        success "¡Demo de pruebas completas finalizada!"
    else
        error "Error en las pruebas completas"
    fi
}

# Función para mostrar información del sistema
demo_system_info() {
    echo -e "${CYAN}📊 DEMO: Información del Sistema${NC}"
    echo
    info "Información del sistema:"
    echo "═══════════════════════════════════════════"
    
    echo -e "${GREEN}Distribución:${NC}"
    lsb_release -a 2>/dev/null || cat /etc/os-release
    
    echo -e "${GREEN}Kernel:${NC}"
    uname -a
    
    echo -e "${GREEN}Arquitectura:${NC}"
    arch
    
    echo -e "${GREEN}CPU:${NC}"
    lscpu | grep "Model name" | head -1
    
    echo -e "${GREEN}Memoria:${NC}"
    free -h
    
    echo -e "${GREEN}Disco:${NC}"
    df -h /
    
    echo -e "${GREEN}Docker:${NC}"
    if command -v docker &> /dev/null; then
        docker --version
    else
        echo "No instalado"
    fi
    
    echo -e "${GREEN}Python:${NC}"
    python3 --version 2>/dev/null || echo "No instalado"
    
    echo -e "${GREEN}Node.js:${NC}"
    node --version 2>/dev/null || echo "No instalado"
    
    echo "═══════════════════════════════════════════"
}

# Función para verificar prerrequisitos
demo_check_prerequisites() {
    echo -e "${CYAN}🔧 DEMO: Verificar Prerrequisitos${NC}"
    echo
    info "Verificando prerrequisitos del sistema..."
    
    local all_good=true
    
    # Verificar scripts
    if [[ -x "./scripts/test-system.sh" ]]; then
        success "✓ Script test-system.sh disponible"
    else
        error "✗ Script test-system.sh no disponible o sin permisos"
        all_good=false
    fi
    
    if [[ -x "./scripts/backup-system.sh" ]]; then
        success "✓ Script backup-system.sh disponible"
    else
        error "✗ Script backup-system.sh no disponible o sin permisos"
        all_good=false
    fi
    
    if [[ -x "./setup.sh" ]]; then
        success "✓ Script setup.sh disponible"
    else
        error "✗ Script setup.sh no disponible o sin permisos"
        all_good=false
    fi
    
    # Verificar Docker
    if command -v docker &> /dev/null; then
        success "✓ Docker instalado"
    else
        warning "⚠ Docker no instalado (opcional)"
    fi
    
    if command -v docker-compose &> /dev/null; then
        success "✓ Docker Compose instalado"
    else
        warning "⚠ Docker Compose no instalado (opcional)"
    fi
    
    # Verificar directorios
    if [[ -d "./config" ]]; then
        success "✓ Directorio config disponible"
    else
        error "✗ Directorio config no encontrado"
        all_good=false
    fi
    
    if [[ -d "./modules" ]]; then
        success "✓ Directorio modules disponible"
    else
        error "✗ Directorio modules no encontrado"
        all_good=false
    fi
    
    if [[ -d "./docker-test" ]]; then
        success "✓ Directorio docker-test disponible"
    else
        warning "⚠ Directorio docker-test no encontrado (opcional)"
    fi
    
    echo
    if [[ "$all_good" == true ]]; then
        success "¡Todos los prerrequisitos principales están listos!"
    else
        error "Algunos prerrequisitos no están disponibles"
    fi
}

# Función para mostrar ayuda
demo_help() {
    echo -e "${CYAN}📖 DEMO: Ayuda y Documentación${NC}"
    echo
    echo "Este script de demostración te permite probar el sistema de configuración"
    echo "de forma segura sin afectar tu sistema principal."
    echo
    echo -e "${GREEN}Opciones disponibles:${NC}"
    echo "1. 🟢 Modo Simulación: Muestra qué haría sin cambios reales"
    echo "2. 🐳 Docker: Pruebas en contenedor aislado"
    echo "3. 💾 Backup: Crea snapshot del sistema"
    echo "4. 🛡️  Seguro: Backup automático + pruebas"
    echo "5. ⚠️  Completo: Solo en VM/entorno controlado"
    echo
    echo -e "${GREEN}Recomendación de uso:${NC}"
    echo "1. Empieza con 'Modo Simulación'"
    echo "2. Si tienes Docker, prueba 'Docker'"
    echo "3. Para pruebas reales, usa 'Seguro'"
    echo "4. Solo usa 'Completo' en VM"
    echo
    echo -e "${GREEN}Archivos importantes:${NC}"
    echo "- ./scripts/test-system.sh: Script principal de pruebas"
    echo "- ./scripts/backup-system.sh: Creación de backups"
    echo "- ./config/ejemplo_config.yaml: Configuración de ejemplo"
    echo "- ./docker-test/: Entorno de pruebas Docker"
    echo
    echo -e "${GREEN}Para más información:${NC}"
    echo "- README.md: Documentación completa"
    echo "- docker-test/README.md: Documentación Docker"
    echo "- ./scripts/test-system.sh --help: Ayuda del script"
}

# Función principal
main() {
    show_banner
    
    while true; do
        show_menu
        read -p "Selecciona una opción (1-9): " choice
        
        case $choice in
            1)
                demo_dry_run
                ;;
            2)
                demo_docker
                ;;
            3)
                demo_backup
                ;;
            4)
                demo_safe
                ;;
            5)
                demo_full
                ;;
            6)
                demo_system_info
                ;;
            7)
                demo_check_prerequisites
                ;;
            8)
                demo_help
                ;;
            9)
                echo
                success "¡Gracias por usar el demo de pruebas!"
                exit 0
                ;;
            *)
                error "Opción inválida. Por favor selecciona 1-9."
                ;;
        esac
        
        echo
        read -p "Presiona Enter para continuar..."
        echo
    done
}

# Ejecutar función principal
main "$@" 