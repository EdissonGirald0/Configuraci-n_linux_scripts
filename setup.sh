#!/bin/bash

# ================================
# 🚀 Script Principal de Configuración Linux
# ================================
# Archivo: setup.sh
# Descripción: Script principal refactorizado que orquesta todos los módulos

# Importar utilidades
source "$(dirname "$0")/lib/utils.sh"

# ================================
# 📋 Funciones de Ayuda
# ================================

show_help() {
    echo -e "${PURPLE}🚀 Script de Configuración Linux - Ayuda${NC}"
    echo "=================================================="
    echo ""
    echo "Uso: $0 [OPCIONES]"
    echo ""
    echo "OPCIONES:"
    echo "  -h, --help              Mostrar esta ayuda"
    echo "  -c, --config FILE       Archivo de configuración personalizado"
    echo "  -m, --modules LIST      Módulos específicos a ejecutar"
    echo "  -s, --skip LIST         Módulos a omitir"
    echo "  -d, --dry-run           Ejecutar en modo simulación"
    echo "  -v, --verbose           Modo verboso"
    echo "  --backup                Crear backup antes de ejecutar"
    echo "  --no-backup             No crear backup"
    echo ""
    echo "MÓDULOS DISPONIBLES:"
    echo "  all                     Todos los módulos (por defecto)"
    echo "  system                  Optimización del sistema"
    echo "  python                  Configuración de Python"
    echo "  nodejs                  Configuración de Node.js"
    echo "  docker                  Configuración de Docker"
    echo "  ide                     Configuración de IDEs"
    echo "  tools                   Herramientas de desarrollo"
    echo ""
    echo "EJEMPLOS:"
    echo "  $0                      # Ejecutar todos los módulos"
    echo "  $0 -m system,python     # Solo optimización y Python"
    echo "  $0 -s nodejs,docker     # Omitir Node.js y Docker"
    echo "  $0 -c my_config.yaml    # Usar configuración personalizada"
    echo ""
    echo "CONFIGURACIÓN:"
    echo "  El script usa config/config.yaml por defecto"
    echo "  Puedes personalizar la configuración editando este archivo"
    echo ""
}

# ================================
# ⚙️ Procesamiento de Argumentos
# ================================

parse_arguments() {
    local modules_to_run="all"
    local modules_to_skip=""
    local custom_config=""
    local dry_run=false
    local verbose=false
    local backup_enabled=true
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--config)
                custom_config="$2"
                shift 2
                ;;
            -m|--modules)
                modules_to_run="$2"
                shift 2
                ;;
            -s|--skip)
                modules_to_skip="$2"
                shift 2
                ;;
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            --backup)
                backup_enabled=true
                shift
                ;;
            --no-backup)
                backup_enabled=false
                shift
                ;;
            *)
                echo -e "${RED}Error: Opción desconocida $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Exportar variables para uso global
    export MODULES_TO_RUN="$modules_to_run"
    export MODULES_TO_SKIP="$modules_to_skip"
    export CUSTOM_CONFIG="$custom_config"
    export DRY_RUN="$dry_run"
    export VERBOSE="$verbose"
    export BACKUP_ENABLED="$backup_enabled"
}

# ================================
# 🔍 Validación de Módulos
# ================================

validate_modules() {
    local available_modules=(
        "all"
        "system"
        "python"
        "nodejs"
        "docker"
        "ide"
        "tools"
    )
    
    # Validar módulos a ejecutar
    if [[ "$MODULES_TO_RUN" != "all" ]]; then
        IFS=',' read -ra modules <<< "$MODULES_TO_RUN"
        for module in "${modules[@]}"; do
            if [[ ! " ${available_modules[@]} " =~ " ${module} " ]]; then
                log_error "Módulo desconocido: $module"
                echo -e "${YELLOW}Módulos disponibles: ${available_modules[*]}${NC}"
                exit 1
            fi
        done
    fi
    
    # Validar módulos a omitir
    if [[ -n "$MODULES_TO_SKIP" ]]; then
        IFS=',' read -ra skip_modules <<< "$MODULES_TO_SKIP"
        for module in "${skip_modules[@]}"; do
            if [[ ! " ${available_modules[@]} " =~ " ${module} " ]]; then
                log_error "Módulo a omitir desconocido: $module"
                exit 1
            fi
        done
    fi
}

# ================================
# 📁 Gestión de Configuración
# ================================

setup_configuration() {
    # Usar configuración personalizada si se especifica
    if [[ -n "$CUSTOM_CONFIG" ]]; then
        if [[ -f "$CUSTOM_CONFIG" ]]; then
            export CONFIG_FILE="$CUSTOM_CONFIG"
            log_info "Usando configuración personalizada: $CUSTOM_CONFIG"
        else
            log_error "Archivo de configuración no encontrado: $CUSTOM_CONFIG"
            exit 1
        fi
    fi
    
    # Verificar si existe el archivo de configuración
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_warn "Archivo de configuración no encontrado: $CONFIG_FILE"
        log_info "Usando configuración por defecto"
    fi
}

# ================================
# 🔧 Gestión de Módulos
# ================================

get_modules_to_execute() {
    local modules=()
    
    if [[ "$MODULES_TO_RUN" == "all" ]]; then
        modules=("system" "python" "nodejs" "docker" "ide" "tools")
    else
        IFS=',' read -ra modules <<< "$MODULES_TO_RUN"
    fi
    
    # Filtrar módulos a omitir
    if [[ -n "$MODULES_TO_SKIP" ]]; then
        IFS=',' read -ra skip_modules <<< "$MODULES_TO_SKIP"
        for skip_module in "${skip_modules[@]}"; do
            modules=("${modules[@]/$skip_module}")
        done
    fi
    
    echo "${modules[@]}"
}

execute_module() {
    local module="$1"
    local module_script=""
    
    case "$module" in
        "system")
            module_script="modules/system_optimization.sh"
            ;;
        "python")
            module_script="modules/python_setup.sh"
            ;;
        "nodejs")
            module_script="modules/nodejs_setup.sh"
            ;;
        "docker")
            module_script="modules/docker_setup.sh"
            ;;
        "ide")
            module_script="modules/ide_setup.sh"
            ;;
        "tools")
            module_script="modules/tools_setup.sh"
            ;;
        *)
            log_error "Módulo desconocido: $module"
            return 1
            ;;
    esac
    
    if [[ -f "$module_script" ]]; then
        log_info "Ejecutando módulo: $module"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "[DRY RUN] Simulando ejecución de $module_script"
            return 0
        fi
        
        # Ejecutar módulo
        if bash "$module_script"; then
            log_success "Módulo $module completado"
            return 0
        else
            log_error "Error en módulo $module"
            return 1
        fi
    else
        log_error "Script del módulo no encontrado: $module_script"
        return 1
    fi
}

# ================================
# 📊 Monitoreo de Progreso
# ================================

show_execution_summary() {
    local total_modules="$1"
    local successful_modules="$2"
    local failed_modules="$3"
    
    echo -e "\n${BLUE}📊 Resumen de Ejecución:${NC}"
    echo "=================================================="
    echo -e "${CYAN}Total de módulos:${NC} $total_modules"
    echo -e "${GREEN}Exitosos:${NC} $successful_modules"
    
    if [[ $failed_modules -gt 0 ]]; then
        echo -e "${RED}Fallidos:${NC} $failed_modules"
    fi
    
    echo "=================================================="
    
    if [[ $failed_modules -eq 0 ]]; then
        echo -e "${GREEN}✅ Todos los módulos se ejecutaron correctamente${NC}"
    else
        echo -e "${YELLOW}⚠️  Algunos módulos fallaron. Revisa los logs para más detalles${NC}"
    fi
}

# ================================
# 🔧 Función Principal
# ================================

main() {
    # Procesar argumentos
    parse_arguments "$@"
    
    # Inicializar entorno
    init_environment
    
    # Validar módulos
    validate_modules
    
    # Configurar configuración
    setup_configuration
    
    # Obtener módulos a ejecutar
    local modules_to_execute=($(get_modules_to_execute))
    
    if [[ ${#modules_to_execute[@]} -eq 0 ]]; then
        log_warn "No hay módulos para ejecutar"
        exit 0
    fi
    
    # Mostrar información de ejecución
    echo -e "${BLUE}📋 Información de Ejecución:${NC}"
    echo "=================================================="
    echo -e "${CYAN}Módulos a ejecutar:${NC} ${modules_to_execute[*]}"
    echo -e "${CYAN}Configuración:${NC} $CONFIG_FILE"
    echo -e "${CYAN}Modo simulación:${NC} $DRY_RUN"
    echo -e "${CYAN}Backup:${NC} $BACKUP_ENABLED"
    echo "=================================================="
    echo ""
    
    # Crear backup si está habilitado
    if [[ "$BACKUP_ENABLED" == "true" && "$DRY_RUN" != "true" ]]; then
        log_info "Creando backup del sistema..."
        create_backup "$BACKUP_DIR"
    fi
    
    # Ejecutar módulos
    local total_modules=${#modules_to_execute[@]}
    local successful_modules=0
    local failed_modules=0
    local current=0
    
    for module in "${modules_to_execute[@]}"; do
        ((current++))
        show_progress "$current" "$total_modules" "Ejecutando $module..."
        
        if execute_module "$module"; then
            ((successful_modules++))
        else
            ((failed_modules++))
        fi
    done
    
    echo "" # Nueva línea después del progreso
    
    # Mostrar resumen
    show_execution_summary "$total_modules" "$successful_modules" "$failed_modules"
    
    # Mostrar información post-ejecución
    if [[ $failed_modules -eq 0 ]]; then
        echo -e "\n${GREEN}🎉 Configuración completada exitosamente${NC}"
        echo -e "${CYAN}📝 Próximos pasos:${NC}"
        echo "  1. Reinicia el sistema para aplicar todos los cambios"
        echo "  2. Revisa los logs en: $LOG_FILE"
        echo "  3. Configura tus credenciales de Git y NPM"
        echo "  4. Personaliza la configuración en: $CONFIG_FILE"
        
        if [[ "$BACKUP_ENABLED" == "true" ]]; then
            echo -e "${CYAN}💾 Backup guardado en:${NC} $BACKUP_DIR"
        fi
    else
        echo -e "\n${YELLOW}⚠️  Configuración completada con errores${NC}"
        echo -e "${CYAN}📝 Acciones recomendadas:${NC}"
        echo "  1. Revisa los logs en: $LOG_FILE"
        echo "  2. Ejecuta los módulos fallidos individualmente"
        echo "  3. Verifica la configuración en: $CONFIG_FILE"
    fi
    
    return $failed_modules
}

# ================================
# 🚀 Punto de Entrada
# ================================

# Ejecutar función principal con todos los argumentos
main "$@" 