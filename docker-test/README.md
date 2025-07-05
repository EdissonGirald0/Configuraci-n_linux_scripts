# 🧪 Entorno de Pruebas Docker

Este directorio contiene un entorno de pruebas completo para el sistema de configuración Linux sin afectar tu sistema principal.

## 🚀 **Inicio Rápido**

### Prerrequisitos
```bash
# Instalar Docker
sudo apt update
sudo apt install docker.io docker-compose

# Agregar usuario al grupo docker
sudo usermod -aG docker $USER
newgrp docker
```

### Ejecutar Pruebas
```bash
# Ir al directorio de pruebas
cd docker-test

# Dar permisos de ejecución
chmod +x run-tests.sh

# Ejecutar todas las pruebas
./run-tests.sh

# O ejecutar pruebas específicas
./run-tests.sh basic      # Pruebas básicas
./run-tests.sh modules    # Pruebas de módulos
./run-tests.sh config     # Pruebas de configuración
./run-tests.sh network    # Pruebas de red
```

## 📋 **Tipos de Pruebas**

### 1. **Pruebas Básicas** (`basic`)
- ✅ Verificación de estructura del proyecto
- ✅ Permisos de scripts
- ✅ Modo simulación del sistema
- ✅ Validación de configuración

### 2. **Pruebas de Módulos** (`modules`)
- ✅ Módulo Python
- ✅ Módulo de optimización del sistema
- ✅ Validación de dependencias

### 3. **Pruebas de Configuración** (`config`)
- ✅ Archivos YAML personalizados
- ✅ Validación de parámetros
- ✅ Configuraciones específicas

### 4. **Pruebas de Red** (`network`)
- ✅ Conectividad de servicios
- ✅ Configuraciones de red
- ✅ Optimizaciones TCP

## 🔧 **Uso Manual del Contenedor**

### Construir y Ejecutar
```bash
# Construir imagen
docker-compose build

# Ejecutar contenedor interactivo
docker-compose run --rm test-environment

# O ejecutar en segundo plano
docker-compose up -d test-environment
```

### Comandos Útiles
```bash
# Entrar al contenedor
docker exec -it linux-config-test bash

# Ver logs
docker-compose logs test-environment

# Detener contenedores
docker-compose down

# Limpiar todo
docker-compose down --volumes --remove-orphans
docker system prune -f
```

## 📊 **Monitoreo de Pruebas**

### Verificar Estado
```bash
# Estado de contenedores
docker-compose ps

# Uso de recursos
docker stats

# Logs en tiempo real
docker-compose logs -f
```

### Resultados de Pruebas
Los resultados se muestran en la consola con códigos de color:
- 🟢 **Verde**: Éxito
- 🔴 **Rojo**: Error
- 🟡 **Amarillo**: Advertencia
- 🔵 **Azul**: Información

## 🛠️ **Personalización**

### Modificar Configuración de Pruebas
Editar `docker-test/test-config.yaml` para cambiar parámetros de prueba:

```yaml
system:
  distribution: "ubuntu"
  backup_enabled: false
  log_level: "DEBUG"

development:
  python:
    enabled: true
    versions: ["3.9"]
```

### Agregar Nuevas Pruebas
1. Editar `run-tests.sh`
2. Agregar nueva función de prueba
3. Incluir en `run_all_tests()`
4. Agregar caso en el switch de argumentos

## ⚠️ **Consideraciones**

### Seguridad
- ✅ Contenedor aislado del sistema principal
- ✅ Usuario sin privilegios dentro del contenedor
- ✅ Volúmenes de solo lectura para el código

### Rendimiento
- ✅ Limpieza automática de contenedores
- ✅ Optimización de capas Docker
- ✅ Reutilización de imágenes

### Limitaciones
- ⚠️ Algunas optimizaciones de hardware no se pueden probar
- ⚠️ Configuraciones específicas del kernel limitadas
- ⚠️ Drivers de GPU no disponibles

## 🔍 **Solución de Problemas**

### Problemas Comunes

#### Docker no está instalado
```bash
sudo apt update
sudo apt install docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker
```

#### Permisos de Docker
```bash
sudo usermod -aG docker $USER
newgrp docker
```

#### Contenedor no inicia
```bash
# Ver logs detallados
docker-compose logs test-environment

# Reconstruir imagen
docker-compose build --no-cache
```

#### Problemas de red
```bash
# Verificar puertos
netstat -tulpn | grep :3000

# Cambiar puertos en docker-compose.yml
```

## 📚 **Recursos Adicionales**

- 📖 [Documentación de Docker](https://docs.docker.com/)
- 📖 [Docker Compose](https://docs.docker.com/compose/)
- 📖 [Buenas prácticas de Docker](https://docs.docker.com/develop/dev-best-practices/)

---

¡Disfruta probando el sistema de forma segura! 🎉 