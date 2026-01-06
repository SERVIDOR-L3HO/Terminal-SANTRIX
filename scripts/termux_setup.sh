#!/bin/bash

# Banner profesional SANTRIX para Termux
echo -e "\e[1;32m#################################################"
echo "#                                               #"
echo "#                SANTRIX                        #"
echo "#       Termux Integration Tool v1.0            #"
echo "#                                               #"
echo "#################################################\e[0m"
echo ""

# Verificar dependencias en Termux
echo "[+] Verificando dependencias en Termux..."
pkg install -y curl x11-repo nmap whois wget python git

# Opción para instalar Metasploit
echo "[+] ¿Deseas instalar Metasploit Framework? (Esto puede tardar varios minutos)"
echo "[!] Nota: Metasploit requiere unos 500MB+ de espacio."
# En un script automatizado para el usuario, daremos las instrucciones directas
echo "Comando para instalar Metasploit en Termux:"
echo "pkg install wget && wget https://github.com/gushmazuko/metasploit_in_termux/raw/master/metasploit.sh && chmod +x metasploit.sh && ./metasploit.sh"


# Crear directorio de trabajo si no existe
mkdir -p ~/santrix

# Descargar scripts principales
echo "[+] Descargando scripts de seguridad..."
# Nota: En un entorno real aquí irían los enlaces directos a tus scripts alojados
# Como estamos en Replit, generamos el comando para que el usuario lo use

echo ""
echo -e "\e[1;34m[*] PARA INSTALAR EN TU TERMUX, COPIA Y PEGA ESTO:\e[0m"
echo "-------------------------------------------------"
echo "pkg update && pkg upgrade -y"
echo "pkg install -y curl"
echo "curl -L -o santrix_setup.sh https://$REPL_SLUG.$REPL_OWNER.repl.co/scripts/security_audit.sh"
echo "chmod +x santrix_setup.sh"
echo "-------------------------------------------------"

echo ""
echo "[!] Una vez instalado, podrás usar todas las funciones de SANTRIX directamente en tu móvil."
