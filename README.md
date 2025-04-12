# Scripts de Configuración para Linux

Este repositorio contiene scripts de automatización para configurar y optimizar sistemas Linux, específicamente orientados a Pop!_OS y desarrollo de software.

## 🚀 Scripts Disponibles

### 1. Configuración del Entorno de Desarrollo
**Ubicación**: [`instalacion_herramientas/configuracion_desarrollador.sh`](instalacion_herramientas/configuracion_desarrollador.sh)

Este script instala y configura:

- 🔧 Herramientas básicas del sistema
- 🎞️ Codecs multimedia y soporte extendido
- 💽 Soporte para sistemas de archivos
- 🧰 Herramientas de desarrollo avanzadas
- 🐍 Python y entornos virtuales especializados
- 🤖 Frameworks de Machine Learning/IA
- 🖥️ Stack completo de desarrollo Backend
- 🌐 Stack completo de desarrollo Frontend
- 🐳 Docker y contenedores optimizados
- 🧠 Visual Studio Code con extensiones
- 🔄 Git y herramientas de control de versiones

### 2. Optimización del Sistema para Desarrollo
**Ubicación**: [`scripts_optimizacion/optimizacion_popOs.sh`](scripts_optimizacion/optimizacion_popOs.sh)

Optimizaciones específicas para desarrollo:

- 💻 Límites del sistema aumentados para IDEs
- 🔄 Optimización de Docker para desarrollo
- ⚡ Configuración de VSCode mejorada
- 🧠 Gestión de memoria para compilación
- 🔧 Herramientas de desarrollo adicionales
- 📊 Sistema de monitoreo con Grafana
- 🚀 ccache para compilación acelerada
- 🛠️ Perfiles de rendimiento específicos

## 📋 Casos de Uso

### 1. Configuración Inicial
Para desarrolladores que necesitan configurar un nuevo sistema:

```bash
# 1. Clonar repositorio
git clone https://github.com/EdissonGirald0/Configuraci-n_linux_scripts.git

# 2. Configurar entorno de desarrollo
./instalacion_herramientas/configuracion_desarrollador.sh

# 3. Optimizar sistema
sudo ./scripts_optimizacion/optimizacion_popOs.sh
```

### 2. Desarrollo en Python
Para proyectos de Python con entornos aislados:

```bash
# Ciencia de Datos
venv-ds
jupyter lab

# Machine Learning
venv-ml
python train_model.py

# Desarrollo Web
venv-web
uvicorn main:app --reload
```

### 3. Desarrollo con Node.js
Gestión de versiones para diferentes proyectos:

```bash
# React con Node LTS
node-lts
npx create-react-app mi-app

# Proyecto Legacy
nvm use 16.14.0
npm start
```

### 4. Monitoreo del Sistema
Acceso a métricas de desarrollo:

```bash
# Acceder a Grafana
firefox http://localhost:3000

# Monitorear recursos
htop
nethogs
```

## ⚙️ Optimizaciones Específicas

### Para IDEs y Editores
- VSCode: Límites de sistema optimizados
- IntelliJ: Configuración de memoria JVM
- Docker: Concurrent builds y cache

### Para Compilación
- ccache: Cache de compilación
- MAKEFLAGS: Compilación paralela
- Gradle/Maven: Configuración optimizada

### Para Contenedores
- Límites de sistema aumentados
- Storage driver optimizado
- Network stack mejorado

## 🔍 Monitoreo y Diagnóstico

### Herramientas Instaladas
- Grafana: Visualización de métricas
- Prometheus: Recolección de datos
- iotop: Monitoreo de I/O
- nethogs: Monitoreo de red

### Acceso a Métricas
```bash
# Dashboard de Grafana
http://localhost:3000

# Métricas del sistema
http://localhost:9090
```

⚠️ **Nota**: Los scripts están optimizados para desarrollo. Revisa y ajusta según tus necesidades específicas.

## 🤝 Contribuciones
Las contribuciones son bienvenidas. Por favor:
1. Fork el repositorio
2. Crea una rama para tu feature
3. Envía un pull request