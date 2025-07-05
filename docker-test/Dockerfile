# Dockerfile para pruebas del sistema de configuración Linux
FROM ubuntu:22.04

# Evitar interacciones durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Actualizar sistema base
RUN apt update && apt upgrade -y

# Instalar dependencias básicas
RUN apt install -y \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    zip \
    python3 \
    python3-pip \
    python3-venv \
    sudo \
    vim \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario de prueba
RUN useradd -m -s /bin/bash tester && \
    echo "tester ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Crear directorio de trabajo
WORKDIR /home/tester/project

# Cambiar al usuario de prueba
USER tester

# Configurar Git
RUN git config --global user.name "Test User" && \
    git config --global user.email "test@example.com"

# Exponer puerto para servicios (opcional)
EXPOSE 3000

# Comando por defecto
CMD ["/bin/bash"] 