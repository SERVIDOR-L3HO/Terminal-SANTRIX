#!/bin/bash

# ================================================
#   SANTRIX - Instalador Completo para Termux
#   v2.0 | Para uso educativo y pruebas autorizadas
# ================================================

GREEN='\e[1;32m'
CYAN='\e[1;36m'
RED='\e[1;31m'
YELLOW='\e[1;33m'
RESET='\e[0m'

banner() {
  echo -e "${GREEN}"
  echo "#################################################"
  echo "#                                               #"
  echo "#                SANTRIX                        #"
  echo "#       Termux Installer v2.0                   #"
  echo "#                                               #"
  echo "#################################################"
  echo -e "${RESET}"
}

log()    { echo -e "${GREEN}[+]${RESET} $1"; }
info()   { echo -e "${CYAN}[*]${RESET} $1"; }
warn()   { echo -e "${YELLOW}[!]${RESET} $1"; }
error()  { echo -e "${RED}[-]${RESET} $1"; }

banner

# ── URL del servidor SANTRIX ──────────────────────────
if [ -n "$1" ]; then
  BASE_URL="$1"
else
  echo -e "${CYAN}[?]${RESET} Ingresa la URL de tu servidor SANTRIX (sin barra final):"
  echo -e "    Ejemplo: https://tu-repl.replit.app"
  read -r BASE_URL
fi

if [ -z "$BASE_URL" ]; then
  error "URL no proporcionada. Saliendo."
  exit 1
fi

# ── 1. Actualizar repositorios ────────────────────────
log "Actualizando repositorios de Termux..."
pkg update -y && pkg upgrade -y

# ── 2. Instalar dependencias base ─────────────────────
log "Instalando dependencias base..."
pkg install -y \
  curl \
  wget \
  git \
  python \
  python-pip \
  nmap \
  whois \
  netcat-openbsd \
  openssh \
  openssl-tool \
  dnsutils \
  tsu \
  zip \
  unzip

# ── 3. Instalar sqlmap ────────────────────────────────
log "Instalando sqlmap..."
if ! command -v sqlmap &>/dev/null; then
  pip install sqlmap 2>/dev/null || {
    git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git ~/sqlmap
    echo 'alias sqlmap="python ~/sqlmap/sqlmap.py"' >> ~/.bashrc
    log "sqlmap instalado via git."
  }
else
  log "sqlmap ya está instalado."
fi

# ── 4. Metasploit (opcional) ──────────────────────────
echo ""
warn "¿Instalar Metasploit Framework? Requiere ~500MB+ de espacio. (s/N)"
read -r INSTALL_MSF
if [[ "$INSTALL_MSF" =~ ^[sS]$ ]]; then
  log "Descargando instalador de Metasploit para Termux..."
  wget -q https://github.com/gushmazuko/metasploit_in_termux/raw/master/metasploit.sh \
       -O /tmp/metasploit.sh
  chmod +x /tmp/metasploit.sh
  bash /tmp/metasploit.sh
else
  info "Metasploit omitido. Puedes instalarlo luego ejecutando:"
  echo "  wget https://github.com/gushmazuko/metasploit_in_termux/raw/master/metasploit.sh && chmod +x metasploit.sh && ./metasploit.sh"
fi

# ── 5. Crear directorio de trabajo ───────────────────
log "Creando directorio ~/santrix ..."
mkdir -p ~/santrix
cd ~/santrix || exit 1

# ── 6. Descargar scripts de SANTRIX ──────────────────
log "Descargando scripts desde $BASE_URL ..."

SCRIPTS=(
  "sql_scanner.sh"
  "security_audit.sh"
  "payment_bypass.sh"
  "network_scanner.sh"
)

ALL_OK=true
for SCRIPT in "${SCRIPTS[@]}"; do
  info "Descargando $SCRIPT ..."
  HTTP_CODE=$(curl -s -o "$SCRIPT" -w "%{http_code}" "$BASE_URL/scripts/$SCRIPT")
  if [ "$HTTP_CODE" = "200" ]; then
    chmod +x "$SCRIPT"
    log "$SCRIPT descargado OK"
  else
    error "No se pudo descargar $SCRIPT (HTTP $HTTP_CODE)"
    ALL_OK=false
  fi
done

# ── 7. Crear launcher ────────────────────────────────
log "Creando comando 'santrix' ..."
cat > ~/santrix/santrix.sh << 'EOF'
#!/bin/bash
GREEN='\e[1;32m'
CYAN='\e[1;36m'
RESET='\e[0m'
echo -e "${GREEN}#################################################"
echo "#              SANTRIX MENU                     #"
echo "#################################################${RESET}"
echo ""
echo -e "  ${CYAN}1)${RESET} SQL Scanner"
echo -e "  ${CYAN}2)${RESET} Security Audit & Stress"
echo -e "  ${CYAN}3)${RESET} Payment Bypass Tester"
echo -e "  ${CYAN}4)${RESET} Network Scanner"
echo -e "  ${CYAN}0)${RESET} Salir"
echo ""
read -rp "Elige una opción: " OPT
case $OPT in
  1) bash ~/santrix/sql_scanner.sh ;;
  2) bash ~/santrix/security_audit.sh ;;
  3) bash ~/santrix/payment_bypass.sh ;;
  4) bash ~/santrix/network_scanner.sh ;;
  0) exit 0 ;;
  *) echo "Opción inválida." ;;
esac
EOF
chmod +x ~/santrix/santrix.sh

# Agregar alias si no existe
if ! grep -q "alias santrix" ~/.bashrc 2>/dev/null; then
  echo 'alias santrix="bash ~/santrix/santrix.sh"' >> ~/.bashrc
fi

# ── 8. Resumen ────────────────────────────────────────
echo ""
echo -e "${GREEN}#################################################${RESET}"
if $ALL_OK; then
  log "Instalación completada exitosamente."
else
  warn "Instalación completada con algunos errores. Revisa los mensajes anteriores."
fi
echo ""
info "Archivos instalados en: ~/santrix/"
info "Ejecuta ${GREEN}santrix${RESET} para abrir el menú (reinicia Termux primero)."
info "O ejecuta directamente: bash ~/santrix/santrix.sh"
echo -e "${GREEN}#################################################${RESET}"
echo ""
warn "SANTRIX es solo para fines educativos y pruebas de penetración autorizadas."
