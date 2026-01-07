#!/data/data/com.termux/files/usr/bin/bash

echo -e "\033[1;32m[+] SANTRIX - Iniciando Instalador para Termux...\033[0m"

# 1. Actualizar sistema
echo "[*] Actualizando paquetes..."
pkg update -y && pkg upgrade -y

# 2. Instalar dependencias
echo "[*] Instalando NodeJS, Git y herramientas básicas..."
pkg install -y nodejs git curl nmap python

# 3. Instalar Metasploit (tarda unos minutos)
echo "[*] Instalando Metasploit Framework..."
pkg install -y unstable-repo
pkg install -y metasploit

# 4. Instalar dependencias del servidor de SANTRIX
echo "[*] Instalando dependencias de la terminal web..."
npm install express socket.io node-pty xterm xterm-addon-fit

# 5. Configurar inicio automático
echo "alias santrix='node server.js'" >> ~/.bashrc

echo -e "\033[1;32m[+] ¡Todo listo!\033[0m"
echo -e "\033[1;33m[*] Para iniciar el servidor web en tu red local, ejecuta:\033[0m"
echo -e "\033[1;36m      node server.js\033[0m"
echo ""
echo -e "\033[1;37mLuego abre en tu navegador: http://localhost:5000\033[0m"
