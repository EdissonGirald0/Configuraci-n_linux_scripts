#!/bin/bash

echo "🚀 Iniciando configuración del entorno de desarrollo en Pop!_OS..."

# ================================
# 🔧 Herramientas básicas del sistema
# ================================
echo "🔧 Instalando herramientas esenciales del sistema..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential git curl wget unzip zip \
    software-properties-common ca-certificates gnupg lsb-release \
    neofetch htop tmux zsh net-tools

# ================================
# 🎞️ Codecs multimedia y librerías extra
# ================================
echo "🎞️ Instalando codecs multimedia y soporte multimedia extendido..."
sudo apt install -y ubuntu-restricted-extras ffmpeg gstreamer1.0* libavcodec-extra

# ================================
# 💽 Soporte para sistemas de archivos adicionales
# ================================
echo "💽 Instalando soporte para NTFS, exFAT, HFS+ y otros sistemas de archivos..."
sudo apt install -y exfat-fuse exfat-utils ntfs-3g hfsplus hfsutils hfsprogs dosfstools

# ================================
# 🧰 Herramientas de desarrollo (Dev Tools)
# ================================
echo "🧰 Instalando herramientas de desarrollo adicionales..."
sudo apt install -y cmake gdb valgrind pkg-config libssl-dev \
    libffi-dev libxml2-dev libxslt1-dev python3-dev python3-setuptools \
    libjpeg-dev zlib1g-dev libfreetype6-dev

# ================================
# 🐍 Python y Entornos Virtuales
# ================================
echo "🐍 Configurando Python y entornos virtuales..."

# Instalar herramientas base de Python
sudo apt install -y python3 python3-pip python3-venv python3-dev

# Crear directorio para entornos virtuales
mkdir -p ~/virtualenvs

# Entorno para Ciencia de Datos
echo "📊 Creando entorno virtual para Ciencia de Datos..."
python3 -m venv ~/virtualenvs/datascience
source ~/virtualenvs/datascience/bin/activate
pip install --upgrade pip
pip install numpy pandas matplotlib seaborn jupyterlab scipy statsmodels plotly
deactivate

# Entorno para Machine Learning
echo "🤖 Creando entorno virtual para Machine Learning..."
python3 -m venv ~/virtualenvs/ml
source ~/virtualenvs/ml/bin/activate
pip install --upgrade pip
pip install scikit-learn torch torchvision torchaudio tensorflow keras opencv-python
deactivate

# Entorno para Desarrollo Web
echo "🌐 Creando entorno virtual para Desarrollo Web..."
python3 -m venv ~/virtualenvs/webdev
source ~/virtualenvs/webdev/bin/activate
pip install --upgrade pip
pip install fastapi uvicorn sqlalchemy django flask
deactivate

# Crear archivo de aliases para activar entornos virtuales
echo "📝 Configurando aliases para entornos virtuales..."
cat >> ~/.bashrc << EOL

# Aliases para entornos virtuales de Python
alias venv-ds='source ~/virtualenvs/datascience/bin/activate'
alias venv-ml='source ~/virtualenvs/ml/bin/activate'
alias venv-web='source ~/virtualenvs/webdev/bin/activate'
EOL

# Configurar pyenv para manejar múltiples versiones de Python
echo "🔧 Instalando pyenv para gestión de versiones de Python..."
curl https://pyenv.run | bash

echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc

# Crear archivo de requiremients para cada entorno
echo "📋 Generando archivos de requirements..."
source ~/virtualenvs/datascience/bin/activate
pip freeze > ~/virtualenvs/datascience/requirements.txt
deactivate

source ~/virtualenvs/ml/bin/activate
pip freeze > ~/virtualenvs/ml/requirements.txt
deactivate

source ~/virtualenvs/webdev/bin/activate
pip freeze > ~/virtualenvs/webdev/requirements.txt
deactivate

# ================================
# 🤖 Machine Learning / IA
# ================================
echo "🤖 Instalando librerías de Machine Learning e IA..."
pip3 install scikit-learn torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cpu
pip3 install transformers

# ================================
# 🖥️ Desarrollo Backend
# ================================
echo "🖥️ Instalando herramientas backend..."
sudo apt install -y postgresql postgresql-contrib redis
pip3 install fastapi uvicorn sqlalchemy psycopg2-binary

# ================================
# 🌐 Desarrollo Web / Frontend
# ================================
echo "🌐 Instalando NVM y Node.js..."

# Instalar NVM
echo "📥 Instalando NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Configurar NVM en .bashrc
echo "⚙️ Configurando NVM..."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Agregar configuración de NVM al .bashrc
cat >> ~/.bashrc << EOL

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Aliases para Node.js
alias node-lts='nvm use --lts'
alias node-latest='nvm use node'
EOL

# Instalar versiones de Node.js
echo "📦 Instalando versiones de Node.js..."
# Instalar la última versión LTS
nvm install --lts
# Instalar la última versión estable
nvm install node
# Establecer la versión LTS como predeterminada
nvm alias default 'lts/*'

# Instalar paquetes globales comunes
echo "🔧 Instalando paquetes globales de Node.js..."
nvm use default
npm install -g yarn
npm install -g create-react-app
npm install -g @vue/cli
npm install -g typescript
npm install -g nodemon
npm install -g npm-check-updates

# Configurar npm
echo "⚙️ Configurando npm..."
npm config set init-author-name "Tu Nombre"
npm config set init-author-email "tuemail@ejemplo.com"
npm config set init-license "MIT"

# Crear directorios para proyectos
echo "📁 Creando estructura de directorios para proyectos..."
mkdir -p ~/projects/node/{react,vue,angular,express}

# ================================
# 🐳 Docker y contenedores
# ================================
echo "🐳 Instalando Docker..."
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker
sudo usermod -aG docker $USER

# ================================
# 🧠 Visual Studio Code
# ================================
echo "🧠 Instalando Visual Studio Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] \
https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update
sudo apt install -y code

# Configurar extensiones útiles en VSCode
echo "🧠 Configurando extensiones en VSCode..."
code --install-extension ms-python.python
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode

# ================================
# 🔄 Configurar Git
# ================================
echo "🔄 Configurando Git..."
git config --global user.name "Tu Nombre"
git config --global user.email "tuemail@ejemplo.com"
git config --global init.defaultBranch main

# ================================
# ✅ Final
# ================================
echo "✅ Instalación completada. Cierra y vuelve a iniciar sesión para aplicar cambios (especialmente Docker)."
echo "💡 Sugerencia: usa 'neofetch' para verificar la configuración del sistema."
