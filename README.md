# 🚀 Scripts de Configuración para Linux 

Este repositorio contiene scripts de automatización **completamente refactorizados** para configurar y optimizar sistemas Linux (Pop!_OS) enfocados en desarrollo de software.

## 🎯 **NUEVO:**

### ✨ **Mejoras Principales**
- 🏗️ **Arquitectura Modular**: Scripts organizados en módulos independientes
- ⚙️ **Configuración YAML**: Personalización completa sin editar código
- 🛡️ **Gestión de Errores Robusta**: Rollback automático y logging detallado
- 🔧 **Funcionalidades Avanzadas**: Modo simulación, módulos selectivos, backup automático

### 📁 **Estructura del Proyecto**
```
Configuración_linux_scripts/
├── 📁 config/
│   ├── config.yaml              # Configuración centralizada
│   └── ejemplo_config.yaml      # Ejemplo de configuración
├── 📁 lib/
│   └── utils.sh                 # Biblioteca de utilidades
├── 📁 modules/
│   ├── python_setup.sh          # Configuración de Python
│   ├── system_optimization.sh   # Optimización del sistema
│   └── [otros módulos...]
├── setup.sh                     # Script principal refactorizado
├── install_dependencies.sh      # Instalador de dependencias
└── README.md      # Documentación completa
```

## 🚀 **Instalación Rápida**

### 1. **Instalar Dependencias**
```bash
# Clonar repositorio
git clone https://github.com/EdissonGirald0/Configuraci-n_linux_scripts.git
cd Configuraci-n_linux_scripts

# Instalar dependencias del sistema
sudo ./install_dependencies.sh
```

### 2. **Ejecutar Configuración Completa**
```bash
# Configuración completa del sistema
sudo ./setup.sh
```

### 3. **Uso Avanzado**
```bash
# Solo optimización del sistema
sudo ./setup.sh -m system

# Python y Node.js
sudo ./setup.sh -m python,nodejs

# Modo simulación (sin cambios reales)
sudo ./setup.sh -d

# Configuración personalizada
sudo ./setup.sh -c config/mi_config.yaml

# Ver ayuda completa
./setup.sh --help
```

## 🔧 **Scripts Disponibles**

### 🆕 **Script Principal **
**Ubicación**: [`setup.sh`](setup.sh)

#### Características:
- ✅ **Módulos Selectivos**: Ejecutar solo componentes específicos
- ✅ **Configuración YAML**: Personalización completa
- ✅ **Modo Simulación**: Probar sin hacer cambios
- ✅ **Backup Automático**: Respaldo antes de cambios críticos
- ✅ **Logging Detallado**: Sistema de logs con niveles
- ✅ **Progreso Visual**: Barra de progreso durante ejecución

#### Uso:
```bash
# Ejecutar todos los módulos
sudo ./setup.sh

# Módulos específicos
sudo ./setup.sh -m system,python

# Omitir módulos
sudo ./setup.sh -s nodejs,docker

# Configuración personalizada
sudo ./setup.sh -c mi_config.yaml

# Modo simulación
sudo ./setup.sh -d
```

### 📦 **Instalador de Dependencias**
**Ubicación**: [`install_dependencies.sh`](install_dependencies.sh)

#### Instala:
- 🔧 Herramientas base del sistema
- 🐍 Python y herramientas de desarrollo
- 🎞️ Soporte multimedia
- 💽 Soporte para sistemas de archivos
- 📊 Herramientas de monitoreo

### 🐍 **Módulo Python**
**Ubicación**: [`modules/python_setup.sh`](modules/python_setup.sh)

#### Configura:
- ✅ **Python Base**: Instalación y configuración
- ✅ **pyenv**: Gestión de versions múltiples
- ✅ **Entornos Virtuales**:
  - 📊 **Ciencia de Datos**: numpy, pandas, matplotlib, jupyterlab
  - 🤖 **Machine Learning**: scikit-learn, torch, tensorflow
  - 🌐 **Desarrollo Web**: Django, Flask, FastAPI
- ✅ **Aliases Rápidos**: `venv-ds`, `venv-ml`, `venv-web`

### ⚡ **Módulo Optimización del Sistema**
**Ubicación**: [`modules/system_optimization.sh`](modules/system_optimization.sh)

#### Optimizaciones:
- 🔄 **Sistema Base**: Actualización y limpieza automática
- ⚙️ **Servicios**: Deshabilitación de servicios innecesarios
- ⚡ **Arranque**: Optimización de GRUB
- 🧠 **Memoria**: zram, swappiness, cache pressure
- 🌐 **Red**: BBR, TCP Fast Open, buffers optimizados
- 💽 **Sistema de Archivos**: TRIM, inotify, optimizaciones SSD
- 🔋 **Energía**: TLP, powertop, governors
- 🎮 **GPU**: Drivers NVIDIA/AMD optimizados
- 💻 **Desarrollo**: Límites del sistema, Docker, VSCode

## ⚙️ **Configuración Personalizada**

### Archivo de Configuración Principal
**Ubicación**: [`config/config.yaml`](config/config.yaml)

```yaml
# Configuración general del sistema
system:
  distribution: "pop_os"
  backup_enabled: true
  backup_retention_days: 30
  log_level: "INFO"

# Configuración de herramientas de desarrollo
development:
  python:
    enabled: true
    versions: ["3.9", "3.10", "3.11"]
    environments:
      datascience:
        enabled: true
        packages:
          - numpy
          - pandas
          - matplotlib
          - jupyterlab
      machine_learning:
        enabled: true
        packages:
          - scikit-learn
          - torch
          - tensorflow

# Configuración de optimización
optimization:
  memory:
    swappiness: 10
    vfs_cache_pressure: 50
  network:
    tcp_congestion_control: "bbr"
  power_management:
    tlp_enabled: true
    cpu_governor_ac: "performance"
    cpu_governor_bat: "powersave"
```

### Personalización
1. **Copiar configuración de ejemplo**:
   ```bash
   cp config/ejemplo_config.yaml config/mi_config.yaml
   ```

2. **Editar configuración**:
   ```bash
   nano config/mi_config.yaml
   ```

3. **Usar configuración personalizada**:
   ```bash
   sudo ./setup.sh -c config/mi_config.yaml
   ```

## 📋 **Guía de Uso**

### Configuración Inicial
```bash
# 1. Instalar dependencias
sudo ./install_dependencies.sh

# 2. Configuración completa
sudo ./setup.sh

# 3. Reiniciar sistema
sudo reboot
```

### Uso de Entornos Python
```bash
# Activar entornos
venv-ds    # Ciencia de Datos
venv-ml    # Machine Learning
venv-web   # Desarrollo Web

# Crear nuevo proyecto
create-python-project mi_proyecto datascience
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

## 🔍 **Monitoreo y Diagnóstico**

### Herramientas Instaladas
- **htop**: Monitor de procesos avanzado
- **iotop**: Monitoreo de I/O del disco
- **nethogs**: Uso de red por proceso
- **iftop**: Monitoreo de conexiones de red
- **Grafana**: Dashboard de métricas (opcional)

### Verificación del Sistema
```bash
# Estado general
neofetch

# Recursos
htop
nvidia-smi  # Si tienes GPU NVIDIA

# Logs del sistema
tail -f /var/log/system_optimization.log
```

## ⚠️ **Consideraciones Importantes**

### Seguridad
- ✅ **Backup Automático**: Se crean en `/root/system_backup_[fecha]`
- ✅ **Validación**: Verificación de permisos y requisitos
- ✅ **Rollback**: Restauración automática en caso de errores

### Reversión
```bash
# Restaurar GRUB
sudo cp /root/system_backup_[fecha]/grub /etc/default/grub
sudo update-grub

# Restaurar otros archivos
sudo cp /root/system_backup_[fecha]/fstab /etc/fstab
sudo cp /root/system_backup_[fecha]/sysctl.conf /etc/sysctl.conf
sudo sysctl -p
```

### Post-Instalación
- 🔄 Reiniciar el sistema
- 📊 Verificar logs en `/var/log/system_optimization.log`
- ⚙️ Configurar Git y NPM con tus credenciales
- 🎨 Personalizar configuración en `config/config.yaml`

## 📊 **Comparación: Original vs Refactorizado**

| Aspecto | Versión Original | Versión Refactorizada |
|---------|------------------|----------------------|
| **Estructura** | Scripts monolíticos | Arquitectura modular |
| **Configuración** | Valores hardcodeados | Archivo YAML centralizado |
| **Manejo de errores** | Básico | Sistema robusto con rollback |
| **Logging** | Echo simple | Sistema de logs con niveles |
| **Flexibilidad** | Fija | Altamente configurable |
| **Mantenimiento** | Difícil | Fácil y modular |
| **Reutilización** | Limitada | Biblioteca de utilidades |
| **Monitoreo** | Manual | Progreso visual y logs |
| **Seguridad** | Básica | Backup y validación |

## 🎉 **Beneficios de la Refactorización**

### Para Desarrolladores
- ✅ **Configuración rápida**: Un comando para todo el entorno
- ✅ **Entornos preconfigurados**: Python, Node.js, Docker listos
- ✅ **Optimizaciones probadas**: Mejor rendimiento garantizado
- ✅ **Herramientas integradas**: Monitoreo y diagnóstico incluidos

### Para el Sistema
- ✅ **Rendimiento optimizado**: Configuraciones específicas para desarrollo
- ✅ **Estabilidad mejorada**: Manejo de errores y rollback
- ✅ **Recursos optimizados**: Memoria, red y almacenamiento
- ✅ **Seguridad reforzada**: Backup y validación automática

## 📚 **Documentación Completa**

Para información detallada sobre todas las funcionalidades, consulta:
- 📖 **[README_REFACTORIZADO.md](README_REFACTORIZADO.md)**: Documentación completa
- ⚙️ **[config/config.yaml](config/config.yaml)**: Configuración por defecto
- 🔧 **[config/ejemplo_config.yaml](config/ejemplo_config.yaml)**: Ejemplo de configuración

## 🤝 **Contribuciones**

### Cómo Contribuir
1. **Fork** el repositorio
2. **Crear** una rama para tu feature
3. **Implementar** siguiendo las convenciones establecidas
4. **Probar** en un entorno de desarrollo
5. **Documentar** los cambios
6. **Crear** un Pull Request

### Convenciones de Código
- **Bash**: Seguir las mejores prácticas de Bash
- **Documentación**: Comentar todas las funciones
- **Logging**: Usar el sistema de logs establecido
- **Configuración**: Agregar opciones al archivo YAML
- **Testing**: Probar en diferentes distribuciones

## 📞 **Soporte**

### Recursos de Ayuda
- 📖 **Documentación**: README_REFACTORIZADO.md
- 🐛 **Issues**: GitHub Issues para reportar problemas
- 💬 **Discusiones**: GitHub Discussions para preguntas
- 📧 **Contacto**: Crear un issue para contacto directo

### Información del Sistema
```bash
# Información del sistema
./setup.sh --help

# Verificar estado
systemctl status docker
systemctl status tlp

# Logs del sistema
journalctl -f
```

---

## 🏆 **Conclusión**

La refactorización de este proyecto ha transformado un conjunto de scripts básicos en una **solución profesional, modular y robusta** para la configuración de entornos de desarrollo Linux.

### Características Destacadas
- 🚀 **Arquitectura moderna**: Modular y escalable
- ⚙️ **Configuración flexible**: Personalizable sin editar código
- 🛡️ **Robustez**: Manejo de errores y rollback automático
- 📊 **Monitoreo**: Herramientas de diagnóstico integradas
- 🔧 **Mantenibilidad**: Fácil actualización y extensión

### Próximos Pasos
1. **Instalar** el sistema refactorizado
2. **Personalizar** la configuración según necesidades
3. **Explorar** los módulos disponibles
4. **Contribuir** al desarrollo del proyecto

¡Disfruta de tu entorno de desarrollo optimizado! 🎉