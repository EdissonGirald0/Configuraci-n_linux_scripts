#!/bin/bash

# Script para ejecutar pruebas del sistema en Docker
# Uso: ./run-tests.sh [test-type]

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

# Verificar que Docker esté instalado
if ! command -v docker &> /dev/null; then
    error "Docker no está instalado. Por favor instala Docker primero."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    error "Docker Compose no está instalado. Por favor instala Docker Compose primero."
    exit 1
fi

# Función para limpiar contenedores
cleanup() {
    log "Limpiando contenedores de prueba..."
    docker-compose down --volumes --remove-orphans
    docker system prune -f
}

# Función para ejecutar pruebas básicas
run_basic_tests() {
    log "Ejecutando pruebas básicas..."
    
    # Construir imagen
    docker-compose build
    
    # Ejecutar contenedor
    docker-compose up -d test-environment
    
    # Esperar a que el contenedor esté listo
    sleep 5
    
    # Ejecutar comandos de prueba
    docker exec linux-config-test bash -c "
        cd /home/tester/project
        echo '=== Verificando estructura del proyecto ==='
        ls -la
        echo '=== Verificando permisos de scripts ==='
        ls -la *.sh
        echo '=== Probando modo simulación ==='
        sudo ./setup.sh -d -m system
        echo '=== Verificando configuración ==='
        cat config/config.yaml
    "
    
    success "Pruebas básicas completadas"
}

# Función para ejecutar pruebas de módulos
run_module_tests() {
    log "Ejecutando pruebas de módulos..."
    
    docker exec linux-config-test bash -c "
        cd /home/tester/project
        echo '=== Probando módulo Python ==='
        sudo ./setup.sh -d -m python
        echo '=== Probando módulo de optimización ==='
        sudo ./setup.sh -d -m system
    "
    
    success "Pruebas de módulos completadas"
}

# Función para ejecutar pruebas de configuración
run_config_tests() {
    log "Ejecutando pruebas de configuración..."
    
    # Crear configuración de prueba
    cat > docker-test/test-config.yaml << EOF
system:
  distribution: "ubuntu"
  backup_enabled: false
  log_level: "DEBUG"

development:
  python:
    enabled: true
    versions: ["3.9"]
    environments:
      datascience:
        enabled: true
        packages:
          - numpy
          - pandas

optimization:
  memory:
    swappiness: 10
  network:
    tcp_congestion_control: "bbr"
EOF
    
    docker exec linux-config-test bash -c "
        cd /home/tester/project
        echo '=== Probando configuración personalizada ==='
        sudo ./setup.sh -d -c /home/tester/test-data/test-config.yaml
    "
    
    success "Pruebas de configuración completadas"
}

# Función para ejecutar pruebas de red
run_network_tests() {
    log "Ejecutando pruebas de red..."
    
    # Crear archivo de prueba
    echo "<h1>Test Page</h1>" > docker-test/test-data/index.html
    
    # Iniciar servicio de red
    docker-compose up -d test-network
    
    # Esperar a que el servicio esté listo
    sleep 3
    
    # Probar conectividad
    if curl -f http://localhost:8080 > /dev/null 2>&1; then
        success "Pruebas de red exitosas"
    else
        error "Pruebas de red fallaron"
    fi
}

# Función para ejecutar todas las pruebas
run_all_tests() {
    log "Ejecutando todas las pruebas..."
    
    run_basic_tests
    run_module_tests
    run_config_tests
    run_network_tests
    
    success "Todas las pruebas completadas exitosamente"
}

# Manejo de argumentos
case "${1:-all}" in
    "basic")
        run_basic_tests
        ;;
    "modules")
        run_module_tests
        ;;
    "config")
        run_config_tests
        ;;
    "network")
        run_network_tests
        ;;
    "all")
        run_all_tests
        ;;
    *)
        echo "Uso: $0 [basic|modules|config|network|all]"
        echo "  basic   - Pruebas básicas del sistema"
        echo "  modules - Pruebas de módulos específicos"
        echo "  config  - Pruebas de configuración"
        echo "  network - Pruebas de red"
        echo "  all     - Todas las pruebas (por defecto)"
        exit 1
        ;;
esac

# Limpiar al final
cleanup

success "Proceso de pruebas completado" 