# 🚀 Scripts de Configuración Linux - Versión Refactorizada

## 📋 Resumen del Proyecto

Este proyecto ha sido completamente refactorizado para proporcionar una solución modular, configurable y robusta para la configuración y optimización de sistemas Linux (especialmente Pop!_OS) enfocada en desarrollo de software.

## 🎯 Mejoras Implementadas

### ✅ **Arquitectura Modular**
- **Separación de responsabilidades**: Cada funcionalidad está en su propio módulo
- **Reutilización de código**: Biblioteca de utilidades compartidas
- **Mantenibilidad**: Fácil actualización y extensión de funcionalidades

### ✅ **Sistema de Configuración**
- **Configuración centralizada**: Archivo YAML para todas las opciones
- **Personalización completa**: Cada aspecto es configurable
- **Valores por defecto**: Funciona sin configuración personalizada

### ✅ **Gestión de Errores Robusta**
- **Logging detallado**: Sistema de logs con timestamps y niveles
- **Manejo de errores**: Rollback automático en caso de fallos
- **Validación**: Verificación de requisitos y dependencias

### ✅ **Funcionalidades Avanzadas**
- **Modo simulación**: Ejecución sin cambios reales
- **Backup automático**: Respaldo de configuraciones críticas
- **Progreso visual**: Barra de progreso durante la ejecución
- **Módulos selectivos**: Ejecutar solo módulos específicos

## 📁 Estructura del Proyecto

```
Configuración_linux_scripts/
├── 📁 config/
│   └── config.yaml              # Configuración centralizada
├── 📁 lib/
│   └── utils.sh                 # Biblioteca de utilidades
├── 📁 modules/
│   ├── python_setup.sh          # Configuración de Python
│   ├── system_optimization.sh   # Optimización del sistema
│   ├── nodejs_setup.sh          # Configuración de Node.js
│   ├── docker_setup.sh          # Configuración de Docker
│   ├── ide_setup.sh             # Configuración de IDEs
│   └── tools_setup.sh           # Herramientas de desarrollo
├── setup.sh                     # Script principal
├── README.md                    # Documentación original
└── README_REFACTORIZADO.md      # Esta documentación
```

## 🚀 Instalación y Uso

### Instalación Rápida

```bash
# 1. Clonar repositorio
git clone https://github.com/EdissonGirald0/Configuraci-n_linux_scripts.git
cd Configuraci-n_linux_scripts

# 2. Dar permisos de ejecución
chmod +x setup.sh
chmod +x lib/utils.sh
chmod +x modules/*.sh

# 3. Ejecutar configuración completa
sudo ./setup.sh
```

### Uso Avanzado

```bash
# Ejecutar módulos específicos
sudo ./setup.sh -m system,python

# Omitir módulos
sudo ./setup.sh -s nodejs,docker

# Usar configuración personalizada
sudo ./setup.sh -c mi_configuracion.yaml

# Modo simulación (sin cambios reales)
sudo ./setup.sh -d

# Ver ayuda completa
./setup.sh --help
```

## ⚙️ Configuración

### Archivo de Configuración (`config/config.yaml`)

El archivo de configuración permite personalizar todos los aspectos del sistema:

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
      machine_learning:
        enabled: true
        packages:
          - scikit-learn
          - torch
          - tensorflow

# Configuración de optimización del sistema
optimization:
  memory:
    swappiness: 10
    vfs_cache_pressure: 50
  network:
    tcp_congestion_control: "bbr"
    tcp_fastopen: 3
  power_management:
    tlp_enabled: true
    cpu_governor_ac: "performance"
    cpu_governor_bat: "powersave"
```

### Personalización

1. **Copiar configuración por defecto**:
   ```bash
   cp config/config.yaml config/mi_configuracion.yaml
   ```

2. **Editar configuración**:
   ```bash
   nano config/mi_configuracion.yaml
   ```

3. **Usar configuración personalizada**:
   ```bash
   sudo ./setup.sh -c config/mi_configuracion.yaml
   ```

## 🔧 Módulos Disponibles

### 1. **Sistema** (`system`)
Optimizaciones avanzadas del sistema operativo:
- ✅ Actualización y limpieza automática
- ✅ Gestión de servicios innecesarios
- ✅ Optimización de arranque (GRUB)
- ✅ Configuración de memoria (zram, swappiness)
- ✅ Optimización de red (BBR, TCP Fast Open)
- ✅ Optimización de sistema de archivos (TRIM, inotify)
- ✅ Gestión energética (TLP, powertop)
- ✅ Optimización GPU (NVIDIA/AMD)
- ✅ Límites del sistema para desarrollo
- ✅ Herramientas de monitoreo

### 2. **Python** (`python`)
Configuración completa de Python:
- ✅ Instalación de Python base y pyenv
- ✅ Gestión de versiones múltiples
- ✅ Entornos virtuales preconfigurados:
  - 📊 Ciencia de Datos (numpy, pandas, matplotlib)
  - 🤖 Machine Learning (scikit-learn, torch, tensorflow)
  - 🌐 Desarrollo Web (Django, Flask, FastAPI)
- ✅ Aliases para activación rápida
- ✅ Función para crear proyectos nuevos

### 3. **Node.js** (`nodejs`)
Configuración de entorno JavaScript:
- ✅ Instalación de NVM
- ✅ Gestión de versiones (LTS, Latest)
- ✅ Paquetes globales comunes
- ✅ Configuración de npm
- ✅ Estructura de proyectos

### 4. **Docker** (`docker`)
Configuración de contenedores:
- ✅ Instalación de Docker y Docker Compose
- ✅ Configuración optimizada para desarrollo
- ✅ Permisos de usuario
- ✅ Configuración del daemon

### 5. **IDE** (`ide`)
Configuración de entornos de desarrollo:
- ✅ Visual Studio Code
- ✅ Extensiones útiles
- ✅ Configuración optimizada
- ✅ Límites de archivos para proyectos grandes

### 6. **Herramientas** (`tools`)
Herramientas adicionales de desarrollo:
- ✅ Herramientas de compilación (ccache)
- ✅ Monitoreo del sistema
- ✅ Herramientas de red
- ✅ Utilidades de desarrollo

## 📊 Monitoreo y Diagnóstico

### Herramientas de Monitoreo Instaladas

- **htop**: Monitor de procesos avanzado
- **iotop**: Monitoreo de I/O del disco
- **nethogs**: Uso de red por proceso
- **iftop**: Monitoreo de conexiones de red
- **Grafana**: Dashboard de métricas (opcional)

### Verificación del Sistema

```bash
# Estado general del sistema
neofetch

# Recursos del sistema
htop

# GPU (si tienes NVIDIA)
nvidia-smi

# Estado de servicios
systemctl status docker
systemctl status tlp
```

## 🔍 Logs y Diagnóstico

### Archivos de Log

- **Log principal**: `/var/log/system_optimization.log`
- **Logs del sistema**: `journalctl -f`
- **Logs de Docker**: `journalctl -u docker`

### Comandos de Diagnóstico

```bash
# Ver logs del script
tail -f /var/log/system_optimization.log

# Verificar configuración del sistema
sysctl -a | grep -E "(vm\.|net\.|fs\.)"

# Verificar servicios
systemctl list-units --failed

# Verificar espacio en disco
df -h

# Verificar memoria
free -h
```

## ⚠️ Consideraciones Importantes

### Seguridad
- ✅ **Backup automático**: Se crean respaldos antes de cambios críticos
- ✅ **Validación**: Verificación de permisos y requisitos
- ✅ **Rollback**: Restauración automática en caso de errores

### Rendimiento
- ✅ **Optimizaciones probadas**: Configuraciones optimizadas para desarrollo
- ✅ **Monitoreo**: Herramientas para verificar mejoras
- ✅ **Personalización**: Ajuste según hardware específico

### Mantenimiento
- ✅ **Modular**: Fácil actualización de componentes individuales
- ✅ **Configurable**: Sin necesidad de editar código
- ✅ **Documentado**: Comentarios y documentación completa

## 🛠️ Solución de Problemas

### Problemas Comunes

1. **Error de permisos**:
   ```bash
   sudo chmod +x setup.sh
   sudo ./setup.sh
   ```

2. **Módulo falla**:
   ```bash
   # Ejecutar módulo individual
   sudo bash modules/python_setup.sh
   
   # Ver logs detallados
   tail -f /var/log/system_optimization.log
   ```

3. **Configuración no se aplica**:
   ```bash
   # Reiniciar servicios
   sudo systemctl daemon-reload
   sudo systemctl restart docker
   
   # Reiniciar sistema
   sudo reboot
   ```

### Rollback Manual

```bash
# Restaurar GRUB
sudo cp /root/system_backup_YYYYMMDD/grub /etc/default/grub
sudo update-grub

# Restaurar fstab
sudo cp /root/system_backup_YYYYMMDD/fstab /etc/fstab

# Restaurar sysctl
sudo cp /root/system_backup_YYYYMMDD/sysctl.conf /etc/sysctl.conf
sudo sysctl -p
```

## 🔄 Actualizaciones

### Actualizar el Proyecto

```bash
# Actualizar desde Git
git pull origin main

# Verificar cambios en configuración
git diff config/config.yaml

# Ejecutar actualización
sudo ./setup.sh -m system
```

### Agregar Nuevos Módulos

1. Crear archivo en `modules/nuevo_modulo.sh`
2. Implementar funciones siguiendo el patrón establecido
3. Agregar al script principal `setup.sh`
4. Documentar en esta guía

## 📈 Comparación: Antes vs Después

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

## 🎉 Beneficios de la Refactorización

### Para Desarrolladores
- ✅ **Configuración rápida**: Un comando para todo el entorno
- ✅ **Entornos preconfigurados**: Python, Node.js, Docker listos
- ✅ **Optimizaciones probadas**: Mejor rendimiento garantizado
- ✅ **Herramientas integradas**: Monitoreo y diagnóstico incluidos

### Para Administradores
- ✅ **Instalación automatizada**: Sin intervención manual
- ✅ **Configuración consistente**: Mismo entorno en todos los sistemas
- ✅ **Mantenimiento simplificado**: Actualizaciones modulares
- ✅ **Diagnóstico avanzado**: Logs y herramientas de monitoreo

### Para el Sistema
- ✅ **Rendimiento optimizado**: Configuraciones específicas para desarrollo
- ✅ **Estabilidad mejorada**: Manejo de errores y rollback
- ✅ **Recursos optimizados**: Memoria, red y almacenamiento
- ✅ **Seguridad reforzada**: Backup y validación automática

## 🤝 Contribuciones

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

## 📞 Soporte

### Recursos de Ayuda

- 📖 **Documentación**: Este archivo README
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

## 🏆 Conclusión

La refactorización de este proyecto ha transformado un conjunto de scripts básicos en una solución profesional, modular y robusta para la configuración de entornos de desarrollo Linux. 

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