#!/data/data/com.termux/files/usr/bin/bash

# SANTRIX Termux Installer & Launcher
# Este script instala las dependencias necesarias y conecta tu Termux con SANTRIX

echo -e "\033[1;32m[+] Iniciando instalador de SANTRIX para Termux...\033[0m"

# Actualizar paquetes
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y

# Instalar dependencias básicas
echo "[*] Instalando dependencias (NodeJS, Python, Metasploit, etc)..."
pkg install -y nodejs python git curl nmap

# Intentar instalar Metasploit en Termux (esto puede tardar)
echo "[*] Configurando Metasploit..."
pkg install -y unstable-repo
pkg install -y metasploit

# Crear alias para acceso rápido
echo "alias santrix='node ~/santrix-client/server.js'" >> ~/.bashrc

echo -e "\033[1;32m[+] Instalación completada.\033[0m"
echo -e "\033[1;33m[*] Para conectar con el servidor de SANTRIX, usa:\033[0m"
echo -e "\033[1;36m      curl -s $(curl -s ifconfig.me) | bash\033[0m"
