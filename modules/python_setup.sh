#!/bin/bash

# ================================
# 🐍 Módulo de Configuración Python
# ================================
# Archivo: modules/python_setup.sh
# Descripción: Configuración de Python y entornos virtuales

# Importar utilidades
source "$(dirname "$0")/../lib/utils.sh"

# ================================
# 🔧 Configuración de Python Base
# ================================

setup_python_base() {
    log_info "Configurando Python base..."
    
    # Instalar herramientas base de Python
    local python_packages=(
        "python3"
        "python3-pip"
        "python3-venv"
        "python3-dev"
        "python3-setuptools"
    )
    
    if install_packages "${python_packages[@]}"; then
        log_success "Python base configurado correctamente"
    else
        log_error "Error al configurar Python base"
        return 1
    fi
    
    # Actualizar pip
    log_info "Actualizando pip..."
    python3 -m pip install --upgrade pip
    
    # Instalar pyenv para gestión de versiones
    setup_pyenv
    
    return 0
}

# ================================
# 🔧 Configuración de pyenv
# ================================

setup_pyenv() {
    log_info "Configurando pyenv..."
    
    # Verificar si pyenv ya está instalado
    if command_exists pyenv; then
        log_info "pyenv ya está instalado"
        return 0
    fi
    
    # Instalar pyenv
    if curl https://pyenv.run | bash; then
        # Configurar pyenv en .bashrc
        cat >> ~/.bashrc << 'EOL'

# pyenv Configuration
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOL
        
        log_success "pyenv instalado y configurado"
        
        # Cargar configuración en la sesión actual
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
        
        # Instalar versiones de Python especificadas
        install_python_versions
        
    else
        log_error "Error al instalar pyenv"
        return 1
    fi
}

# ================================
# 📦 Instalación de Versiones Python
# ================================

install_python_versions() {
    log_info "Instalando versiones de Python..."
    
    # Versiones por defecto si no hay configuración
    local versions=("3.9" "3.10" "3.11")
    
    # Intentar cargar desde configuración
    if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
        local config_versions=$(yq eval '.development.python.versions[]' "$CONFIG_FILE" 2>/dev/null)
        if [[ -n "$config_versions" ]]; then
            versions=($config_versions)
        fi
    fi
    
    for version in "${versions[@]}"; do
        log_info "Instalando Python $version..."
        if pyenv install "$version"; then
            log_success "Python $version instalado"
        else
            log_warn "Error al instalar Python $version"
        fi
    done
    
    # Establecer versión por defecto
    if [[ ${#versions[@]} -gt 0 ]]; then
        local default_version="${versions[-1]}"
        pyenv global "$default_version"
        log_success "Python $default_version establecido como predeterminado"
    fi
}

# ================================
# 🌍 Configuración de Entornos Virtuales
# ================================

setup_virtual_environments() {
    log_info "Configurando entornos virtuales..."
    
    # Crear directorio para entornos virtuales
    mkdir -p ~/virtualenvs
    
    # Configurar entornos desde configuración
    setup_datascience_env
    setup_ml_env
    setup_webdev_env
    
    # Crear aliases para activar entornos
    create_venv_aliases
    
    log_success "Entornos virtuales configurados"
}

# ================================
# 📊 Entorno de Ciencia de Datos
# ================================

setup_datascience_env() {
    log_info "Configurando entorno de Ciencia de Datos..."
    
    local env_path="$HOME/virtualenvs/datascience"
    
    # Verificar si el entorno ya existe
    if [[ -d "$env_path" ]]; then
        log_info "Entorno de Ciencia de Datos ya existe"
        return 0
    fi
    
    # Crear entorno virtual
    if python3 -m venv "$env_path"; then
        # Activar entorno e instalar paquetes
        source "$env_path/bin/activate"
        
        # Paquetes por defecto
        local packages=(
            "numpy"
            "pandas"
            "matplotlib"
            "seaborn"
            "jupyterlab"
            "scipy"
            "statsmodels"
            "plotly"
        )
        
        # Intentar cargar desde configuración
        if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
            local config_packages=$(yq eval '.development.python.environments.datascience.packages[]' "$CONFIG_FILE" 2>/dev/null)
            if [[ -n "$config_packages" ]]; then
                packages=($config_packages)
            fi
        fi
        
        # Instalar paquetes
        pip install --upgrade pip
        for package in "${packages[@]}"; do
            log_info "Instalando $package en entorno de Ciencia de Datos..."
            pip install "$package"
        done
        
        # Generar requirements.txt
        pip freeze > "$env_path/requirements.txt"
        
        deactivate
        log_success "Entorno de Ciencia de Datos configurado"
    else
        log_error "Error al crear entorno de Ciencia de Datos"
        return 1
    fi
}

# ================================
# 🤖 Entorno de Machine Learning
# ================================

setup_ml_env() {
    log_info "Configurando entorno de Machine Learning..."
    
    local env_path="$HOME/virtualenvs/ml"
    
    # Verificar si el entorno ya existe
    if [[ -d "$env_path" ]]; then
        log_info "Entorno de Machine Learning ya existe"
        return 0
    fi
    
    # Crear entorno virtual
    if python3 -m venv "$env_path"; then
        # Activar entorno e instalar paquetes
        source "$env_path/bin/activate"
        
        # Paquetes por defecto
        local packages=(
            "scikit-learn"
            "torch"
            "torchvision"
            "torchaudio"
            "tensorflow"
            "keras"
            "opencv-python"
        )
        
        # Intentar cargar desde configuración
        if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
            local config_packages=$(yq eval '.development.python.environments.machine_learning.packages[]' "$CONFIG_FILE" 2>/dev/null)
            if [[ -n "$config_packages" ]]; then
                packages=($config_packages)
            fi
        fi
        
        # Instalar paquetes
        pip install --upgrade pip
        
        # Instalar PyTorch con configuración específica
        pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
        
        # Instalar otros paquetes
        for package in "${packages[@]}"; do
            if [[ "$package" != "torch" && "$package" != "torchvision" && "$package" != "torchaudio" ]]; then
                log_info "Instalando $package en entorno de Machine Learning..."
                pip install "$package"
            fi
        done
        
        # Generar requirements.txt
        pip freeze > "$env_path/requirements.txt"
        
        deactivate
        log_success "Entorno de Machine Learning configurado"
    else
        log_error "Error al crear entorno de Machine Learning"
        return 1
    fi
}

# ================================
# 🌐 Entorno de Desarrollo Web
# ================================

setup_webdev_env() {
    log_info "Configurando entorno de Desarrollo Web..."
    
    local env_path="$HOME/virtualenvs/webdev"
    
    # Verificar si el entorno ya existe
    if [[ -d "$env_path" ]]; then
        log_info "Entorno de Desarrollo Web ya existe"
        return 0
    fi
    
    # Crear entorno virtual
    if python3 -m venv "$env_path"; then
        # Activar entorno e instalar paquetes
        source "$env_path/bin/activate"
        
        # Paquetes por defecto
        local packages=(
            "fastapi"
            "uvicorn"
            "sqlalchemy"
            "django"
            "flask"
        )
        
        # Intentar cargar desde configuración
        if command_exists yq && [[ -f "$CONFIG_FILE" ]]; then
            local config_packages=$(yq eval '.development.python.environments.web_development.packages[]' "$CONFIG_FILE" 2>/dev/null)
            if [[ -n "$config_packages" ]]; then
                packages=($config_packages)
            fi
        fi
        
        # Instalar paquetes
        pip install --upgrade pip
        for package in "${packages[@]}"; do
            log_info "Instalando $package en entorno de Desarrollo Web..."
            pip install "$package"
        done
        
        # Generar requirements.txt
        pip freeze > "$env_path/requirements.txt"
        
        deactivate
        log_success "Entorno de Desarrollo Web configurado"
    else
        log_error "Error al crear entorno de Desarrollo Web"
        return 1
    fi
}

# ================================
# 📝 Crear Aliases para Entornos
# ================================

create_venv_aliases() {
    log_info "Creando aliases para entornos virtuales..."
    
    # Verificar si los aliases ya existen
    if grep -q "alias venv-ds" ~/.bashrc; then
        log_info "Aliases ya existen"
        return 0
    fi
    
    # Agregar aliases al .bashrc
    cat >> ~/.bashrc << 'EOL'

# Aliases para entornos virtuales de Python
alias venv-ds='source ~/virtualenvs/datascience/bin/activate'
alias venv-ml='source ~/virtualenvs/ml/bin/activate'
alias venv-web='source ~/virtualenvs/webdev/bin/activate'

# Función para crear nuevo proyecto con entorno
create-python-project() {
    local project_name="$1"
    local env_type="$2"
    
    if [[ -z "$project_name" ]]; then
        echo "Uso: create-python-project <nombre_proyecto> [datascience|ml|webdev]"
        return 1
    fi
    
    mkdir -p "$project_name"
    cd "$project_name"
    python3 -m venv .venv
    source .venv/bin/activate
    
    case "$env_type" in
        "datascience"|"ds")
            pip install -r ~/virtualenvs/datascience/requirements.txt
            ;;
        "ml")
            pip install -r ~/virtualenvs/ml/requirements.txt
            ;;
        "webdev"|"web")
            pip install -r ~/virtualenvs/webdev/requirements.txt
            ;;
        *)
            echo "Tipo de entorno no válido. Usando entorno básico."
            ;;
    esac
    
    echo "Proyecto $project_name creado y entorno activado."
}
EOL
    
    log_success "Aliases creados"
}

# ================================
# 🔧 Función Principal
# ================================

main_python_setup() {
    log_info "Iniciando configuración de Python..."
    
    # Verificar conectividad de red
    if ! check_network_connectivity; then
        log_error "No hay conectividad de red para instalar paquetes"
        return 1
    fi
    
    # Configurar Python base
    if ! setup_python_base; then
        log_error "Error en configuración de Python base"
        return 1
    fi
    
    # Configurar entornos virtuales
    if ! setup_virtual_environments; then
        log_error "Error en configuración de entornos virtuales"
        return 1
    fi
    
    log_success "Configuración de Python completada"
    echo -e "${GREEN}✅ Python configurado correctamente${NC}"
    echo -e "${CYAN}📝 Usa los siguientes comandos para activar entornos:${NC}"
    echo "  venv-ds    # Ciencia de Datos"
    echo "  venv-ml    # Machine Learning"
    echo "  venv-web   # Desarrollo Web"
    echo -e "${CYAN}📁 Entornos creados en: ~/virtualenvs/${NC}"
    
    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_python_setup
fi 