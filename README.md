# Scripts de Configuración para Linux

Este repositorio contiene scripts de automatización para configurar y optimizar sistemas Linux, específicamente orientados a Pop!_OS.

## 🚀 Scripts Disponibles

### 1. Configuración del Entorno de Desarrollo
**Ubicación**: [`instalacion_herramientas/configuracion_desarrollador.sh`](instalacion_herramientas/configuracion_desarrollador.sh)

Este script instala y configura:

- 🔧 Herramientas básicas del sistema
- 🎞️ Codecs multimedia
- 💽 Soporte para sistemas de archivos
- 🧰 Herramientas de desarrollo
- 🐍 Python y librerías de ciencia de datos
- 🤖 Frameworks de Machine Learning/IA
- 🖥️ Herramientas de desarrollo Backend
- 🌐 Herramientas de desarrollo Frontend
- 🐳 Docker y contenedores
- 🧠 Visual Studio Code
- 🔄 Configuración básica de Git

### 2. Optimización del Sistema
**Ubicación**: [`scripts_optimizacion/optimizacion_popOs.sh`](scripts_optimizacion/optimizacion_popOs.sh)

Este script realiza:

- 🔄 Actualización y limpieza del sistema
- ⚙️ Desactivación de servicios innecesarios
- ⚡ Optimización del arranque y GRUB
- 🧠 Optimización del uso de RAM
- 💽 Mejoras en el sistema de archivos
- 🔋 Configuración de ahorro energético
- 🖥️ Optimización del CPU
- 🎮 Configuración de drivers GPU
- 📶 Optimización de red

## 📋 Uso

1. Clona este repositorio:
```bash
git clone https://github.com/tuusuario/Configuraci-n_linux_scripts.git
```

2. Otorga permisos de ejecución:
```bash
chmod +x instalacion_herramientas/configuracion_desarrollador.sh
chmod +x scripts_optimizacion/optimizacion_popOs.sh
```

3. Ejecuta los scripts según necesites:
```bash
./instalacion_herramientas/configuracion_desarrollador.sh
./scripts_optimizacion/optimizacion_popOs.sh
```

⚠️ **Nota**: Ejecuta estos scripts bajo tu propia responsabilidad. Se recomienda revisar el contenido antes de ejecutarlos.

## 🌟 Uso de Entornos Virtuales

### 🐍 Entornos Python
El script crea tres entornos virtuales especializados:

1. **Entorno de Ciencia de Datos** (`~/virtualenvs/datascience`):
```bash
# Activar entorno
venv-ds

# Principales librerías instaladas:
- numpy, pandas, matplotlib, seaborn
- jupyterlab, scipy, statsmodels, plotly
- notebook, ipykernel
```

2. **Entorno de Machine Learning** (`~/virtualenvs/ml`):
```bash
# Activar entorno
venv-ml

# Principales librerías instaladas:
- scikit-learn, torch, tensorflow
- keras, opencv-python
- transformers
```

3. **Entorno de Desarrollo Web** (`~/virtualenvs/webdev`):
```bash
# Activar entorno
venv-web

# Principales librerías instaladas:
- fastapi, uvicorn, sqlalchemy
- django, djangorestframework
- flask, flask-sqlalchemy
```

### 🌐 Entornos Node.js
El script configura NVM para gestionar versiones de Node.js:

```bash
# Usar versión LTS de Node.js
node-lts

# Usar última versión de Node.js
node-latest

# Ver versiones instaladas
nvm ls

# Instalar una versión específica
nvm install 16.14.0

# Usar una versión específica
nvm use 16.14.0
```

### 📁 Estructura de Proyectos
El script crea la siguiente estructura de directorios:

```
~/projects/
└── node/
    ├── react/
    ├── vue/
    ├── angular/
    └── express/
```

### 🔧 Archivos de Requisitos
Cada entorno virtual de Python tiene su propio archivo de requirements:

```bash
# Instalar requisitos para ciencia de datos
cd ~/virtualenvs/datascience
pip install -r requirements.txt

# Instalar requisitos para machine learning
cd ~/virtualenvs/ml
pip install -r requirements.txt

# Instalar requisitos para desarrollo web
cd ~/virtualenvs/webdev
pip install -r requirements.txt
```