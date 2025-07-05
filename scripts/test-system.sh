#!/bin/bash

# Script principal para pruebas del sistema de configuración Linux
# Uso: ./test-system.sh [test-type] [options]

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

# Variables globales
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_ENABLED=true
DOCKER_ENABLED=true
DRY_RUN=false
VERBOSE=false

# Función para mostrar ayuda
show_help() {
    cat << EOF
🧪 Script de Pruebas del Sistema de Configuración Linux

Uso: $0 [test-type] [options]

TIPOS DE PRUEBA:
  dry-run     Modo simulación (sin cambios reales)
  docker      Pruebas en contenedor Docker
  backup      Crear backup antes de pruebas
  safe        Pruebas seguras con backup automático
  full        Pruebas completas (solo en entorno controlado)

OPCIONES:
  -h, --help          Mostrar esta ayuda
  -v, --verbose       Modo verbose
  -n, --no-backup     No crear backup
  -d, --no-docker     No usar Docker
  -m, --modules       Módulos específicos (ej: python,system)
  -c, --config        Archivo de configuración personalizado

EJEMPLOS:
  $0 dry-run                    # Solo simulación
  $0 docker                     # Pruebas en Docker
  $0 safe -m python             # Pruebas seguras solo Python
  $0 full -c mi_config.yaml     # Pruebas completas con config personalizada

CONSIDERACIONES DE SEGURIDAD:
  - dry-run: Completamente seguro, solo muestra qué haría
  - docker: Aislado, no afecta el sistema principal
  - backup: Crea snapshot antes de pruebas
  - safe: Recomendado para pruebas en sistema real
  - full: Solo en entornos controlados o VMs

EOF
}

# Función para verificar prerrequisitos
check_prerequisites() {
    log "Verificando prerrequisitos..."
    
    # Verificar que estamos en el directorio correcto
    if [[ ! -f "$PROJECT_DIR/setup.sh" ]]; then
        error "No se encontró setup.sh. Ejecuta desde el directorio del proyecto."
        exit 1
    fi
    
    # Verificar permisos de scripts
    if [[ ! -x "$PROJECT_DIR/setup.sh" ]]; then
        warning "setup.sh no tiene permisos de ejecución. Agregando..."
        chmod +x "$PROJECT_DIR/setup.sh"
    fi
    
    # Verificar Docker si está habilitado
    if [[ "$DOCKER_ENABLED" == true ]]; then
        if ! command -v docker &> /dev/null; then
            warning "Docker no está instalado. Deshabilitando pruebas Docker..."
            DOCKER_ENABLED=false
        fi
        
        if ! command -v docker-compose &> /dev/null; then
            warning "Docker Compose no está instalado. Deshabilitando pruebas Docker..."
            DOCKER_ENABLED=false
        fi
    fi
    
    success "Prerrequisitos verificados"
}

# Función para crear backup
create_backup() {
    if [[ "$BACKUP_ENABLED" == false ]]; then
        warning "Backup deshabilitado"
        return 0
    fi
    
    log "Creando backup del sistema..."
    
    if [[ ! -x "$SCRIPT_DIR/backup-system.sh" ]]; then
        error "Script de backup no encontrado o sin permisos"
        return 1
    fi
    
    BACKUP_NAME="test_backup_$(date +%Y%m%d_%H%M%S)"
    
    if sudo "$SCRIPT_DIR/backup-system.sh" "$BACKUP_NAME"; then
        success "Backup creado: $BACKUP_NAME"
        return 0
    else
        error "Error al crear backup"
        return 1
    fi
}

# Función para pruebas en modo simulación
run_dry_run_tests() {
    log "Ejecutando pruebas en modo simulación..."
    
    cd "$PROJECT_DIR"
    
    # Probar todos los módulos en modo simulación
    if sudo ./setup.sh -d -v; then
        success "Pruebas de simulación completadas"
    else
        error "Error en pruebas de simulación"
        return 1
    fi
    
    # Probar módulos específicos si se especificaron
    if [[ -n "$MODULES" ]]; then
        log "Probando módulos específicos: $MODULES"
        if sudo ./setup.sh -d -m "$MODULES" -v; then
            success "Pruebas de módulos específicos completadas"
        else
            error "Error en pruebas de módulos específicos"
            return 1
        fi
    fi
}

# Función para pruebas en Docker
run_docker_tests() {
    if [[ "$DOCKER_ENABLED" == false ]]; then
        warning "Docker no disponible, saltando pruebas Docker"
        return 0
    fi
    
    log "Ejecutando pruebas en Docker..."
    
    if [[ ! -d "$PROJECT_DIR/docker-test" ]]; then
        error "Directorio docker-test no encontrado"
        return 1
    fi
    
    cd "$PROJECT_DIR/docker-test"
    
    if [[ ! -x "run-tests.sh" ]]; then
        error "Script run-tests.sh no encontrado o sin permisos"
        return 1
    fi
    
    # Ejecutar pruebas Docker
    if ./run-tests.sh all; then
        success "Pruebas Docker completadas"
    else
        error "Error en pruebas Docker"
        return 1
    fi
}

# Función para pruebas seguras
run_safe_tests() {
    log "Ejecutando pruebas seguras..."
    
    # Crear backup primero
    if ! create_backup; then
        error "No se pudo crear backup. Abortando pruebas seguras."
        return 1
    fi
    
    cd "$PROJECT_DIR"
    
    # Ejecutar módulos específicos en modo simulación primero
    if [[ -n "$MODULES" ]]; then
        log "Probando módulos en modo simulación: $MODULES"
        if ! sudo ./setup.sh -d -m "$MODULES" -v; then
            error "Error en simulación. Abortando pruebas reales."
            return 1
        fi
        
        # Preguntar confirmación para pruebas reales
        echo
        warning "¿Deseas continuar con las pruebas reales? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            info "Pruebas canceladas por el usuario"
            return 0
        fi
    fi
    
    # Ejecutar pruebas reales
    if sudo ./setup.sh -m "$MODULES" -v; then
        success "Pruebas seguras completadas"
    else
        error "Error en pruebas seguras"
        return 1
    fi
}

# Función para pruebas completas
run_full_tests() {
    warning "⚠️  ADVERTENCIA: Las pruebas completas pueden modificar tu sistema"
    warning "Solo ejecuta esto en un entorno controlado o VM"
    echo
    
    # Preguntar confirmación
    echo -e "${RED}¿Estás seguro de que quieres ejecutar pruebas completas? (y/N)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        info "Pruebas canceladas por el usuario"
        return 0
    fi
    
    # Segunda confirmación
    echo -e "${RED}¿Realmente estás seguro? Esto puede modificar tu sistema. (y/N)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        info "Pruebas canceladas por el usuario"
        return 0
    fi
    
    log "Ejecutando pruebas completas..."
    
    # Crear backup
    if ! create_backup; then
        error "No se pudo crear backup. Abortando pruebas completas."
        return 1
    fi
    
    cd "$PROJECT_DIR"
    
    # Ejecutar configuración completa
    if sudo ./setup.sh -v; then
        success "Pruebas completas finalizadas"
    else
        error "Error en pruebas completas"
        return 1
    fi
}

# Función para mostrar resumen
show_summary() {
    echo
    echo -e "${PURPLE}═══════════════════════════════════════════${NC}"
    echo -e "${PURPLE}           RESUMEN DE PRUEBAS              ${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════${NC}"
    echo -e "Tipo de prueba: ${CYAN}$TEST_TYPE${NC}"
    echo -e "Módulos probados: ${CYAN}${MODULES:-todos}${NC}"
    echo -e "Backup creado: ${CYAN}$BACKUP_ENABLED${NC}"
    echo -e "Docker usado: ${CYAN}$DOCKER_ENABLED${NC}"
    echo -e "Modo verbose: ${CYAN}$VERBOSE${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════${NC}"
    echo
}

# Función principal
main() {
    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -n|--no-backup)
                BACKUP_ENABLED=false
                shift
                ;;
            -d|--no-docker)
                DOCKER_ENABLED=false
                shift
                ;;
            -m|--modules)
                MODULES="$2"
                shift 2
                ;;
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            dry-run|docker|backup|safe|full)
                TEST_TYPE="$1"
                shift
                ;;
            *)
                error "Opción desconocida: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Verificar tipo de prueba
    if [[ -z "$TEST_TYPE" ]]; then
        error "Debes especificar un tipo de prueba"
        show_help
        exit 1
    fi
    
    # Mostrar información inicial
    echo -e "${PURPLE}🧪 Script de Pruebas del Sistema de Configuración Linux${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
    echo
    
    # Verificar prerrequisitos
    check_prerequisites
    
    # Ejecutar pruebas según el tipo
    case "$TEST_TYPE" in
        "dry-run")
            run_dry_run_tests
            ;;
        "docker")
            run_docker_tests
            ;;
        "backup")
            create_backup
            ;;
        "safe")
            run_safe_tests
            ;;
        "full")
            run_full_tests
            ;;
        *)
            error "Tipo de prueba desconocido: $TEST_TYPE"
            exit 1
            ;;
    esac
    
    # Mostrar resumen
    show_summary
    
    success "Proceso de pruebas completado"
}

# Ejecutar función principal
main "$@" 