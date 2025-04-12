# Scripts de Configuración para Linux

Este repositorio contiene scripts de automatización para configurar y optimizar sistemas Linux (Pop!_OS) enfocados en desarrollo de software.

## 🚀 Scripts Disponibles

### 1. Configuración del Entorno de Desarrollo
**Ubicación**: [`instalacion_herramientas/configuracion_desarrollador.sh`](instalacion_herramientas/configuracion_desarrollador.sh)

#### Componentes Instalados:
- 🔧 **Herramientas Base**: build-essential, git, curl, wget, etc.
- 🎞️ **Soporte Multimedia**: codecs y librerías multimedia
- 💽 **Sistemas de Archivos**: soporte para NTFS, exFAT, HFS+
- 🧰 **Dev Tools**: cmake, gdb, valgrind, etc.

#### Entornos de Desarrollo:
1. **Python**:
   - 📊 Ciencia de Datos: numpy, pandas, matplotlib, etc.
   - 🤖 Machine Learning: scikit-learn, torch, tensorflow
   - 🌐 Web: Django, Flask, FastAPI

2. **Node.js**:
   - Gestión de versiones con NVM
   - Paquetes globales: yarn, create-react-app, vue-cli
   - Estructura de proyectos predefinida

3. **Contenedores**:
   - Docker y Docker Compose
   - Configuraciones optimizadas
   - Permisos de usuario ajustados

### 2. Optimización del Sistema
**Ubicación**: [`scripts_optimizacion/optimizacion_popOs.sh`](scripts_optimizacion/optimizacion_popOs.sh)

#### Optimizaciones Principales:
1. **Sistema Base**:
   - Limpieza y actualización
   - Servicios optimizados
   - Arranque mejorado (GRUB)

2. **Recursos**:
   - RAM: zram y preload
   - SWAP: configuración optimizada
   - CPU: estados C-state y governors

3. **Desarrollo**:
   - Límites del sistema aumentados
   - Cache de compilación (ccache)
   - Optimizaciones para IDEs

## 📋 Guía de Uso

### Instalación Inicial
```bash
# 1. Clonar repositorio
git clone https://github.com/EdissonGirald0/Configuraci-n_linux_scripts.git

# 2. Dar permisos de ejecución
chmod +x instalacion_herramientas/configuracion_desarrollador.sh
chmod +x scripts_optimizacion/optimizacion_popOs.sh

# 3. Ejecutar scripts
./instalacion_herramientas/configuracion_desarrollador.sh
sudo ./scripts_optimizacion/optimizacion_popOs.sh
```

### Uso de Entornos Python
```bash
# Activar entornos
venv-ds    # Ciencia de Datos
venv-ml    # Machine Learning
venv-web   # Desarrollo Web

# Crear nuevo proyecto
mkdir mi_proyecto && cd mi_proyecto
python -m venv .venv
source .venv/bin/activate
pip install -r ~/virtualenvs/[entorno]/requirements.txt
```

### Desarrollo Node.js
```bash
# Gestión de versiones
node-lts      # Usar versión LTS
node-latest   # Usar última versión

# Nuevo proyecto React
mkdir mi-app && cd mi-app
node-lts
npx create-react-app .
```

## 🔍 Monitoreo y Diagnóstico

### Herramientas Disponibles
- **Grafana**: `http://localhost:3000`
  - Visualización de métricas
  - Dashboards predefinidos

- **Monitoreo del Sistema**:
  - `htop`: Procesos y recursos
  - `iotop`: I/O del disco
  - `nethogs`: Uso de red

### Verificación del Sistema
```bash
# Estado general
neofetch

# Recursos
htop
nvidia-smi  # Si tienes GPU NVIDIA
```

## ⚠️ Consideraciones Importantes

1. **Respaldos**:
   - Se crean automáticamente en `/root/system_backup_[fecha]`
   - Incluye configuraciones críticas del sistema

2. **Reversión**:
   ```bash
   # Restaurar GRUB
   sudo cp /root/system_backup_[fecha]/grub /etc/default/grub
   sudo update-grub
   ```

3. **Post-Instalación**:
   - Reiniciar el sistema
   - Verificar logs en `/var/log/system_optimization.log`
   - Configurar Git y NPM con tus credenciales