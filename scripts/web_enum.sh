#!/bin/bash
# SANTRIX Web Enumeration Tool v1.0
# Para uso educativo en plataformas autorizadas (HackTheBox, TryHackMe, etc.)

GREEN='\e[1;32m'
CYAN='\e[1;36m'
RED='\e[1;31m'
YELLOW='\e[1;33m'
RESET='\e[0m'

echo -e "${GREEN}"
echo "#################################################"
echo "#                                               #"
echo "#      SANTRIX Web Enumerator v1.0              #"
echo "#      HackTheBox / TryHackMe Ready             #"
echo "#                                               #"
echo "#################################################"
echo -e "${RESET}"

RESULT_DIR="public/results"
mkdir -p "$RESULT_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$RESULT_DIR/webenum_${TIMESTAMP}.txt"
WORDLIST_DIR="/tmp/santrix_wordlists"
COMMON_LIST="$WORDLIST_DIR/common.txt"
DIRS_LIST="$WORDLIST_DIR/directories.txt"

# ── Descarga wordlists si no existen ──────────────────
setup_wordlists() {
  if [ ! -d "$WORDLIST_DIR" ]; then
    echo -e "${CYAN}[*]${RESET} Descargando wordlists..."
    mkdir -p "$WORDLIST_DIR"

    curl -s -o "$COMMON_LIST" \
      "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt"

    curl -s -o "$DIRS_LIST" \
      "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/directory-list-2.3-small.txt"

    echo -e "${GREEN}[+]${RESET} Wordlists listas."
  fi
}

# ── Obtener parámetros ────────────────────────────────
if [ -n "$1" ]; then
  TARGET="$1"
  MODE="${2:-all}"
else
  echo -e "${CYAN}[?]${RESET} URL objetivo (ej: http://10.10.10.10):"
  read -r TARGET
  echo ""
  echo -e "${CYAN}[?]${RESET} Modo de enumeración:"
  echo "  1) Directorios (gobuster dir)"
  echo "  2) Subdominios (gobuster dns)"
  echo "  3) Fuzzing avanzado (ffuf)"
  echo "  4) Todo (completo)"
  read -rp "Opción [1-4]: " OPT
  case $OPT in
    1) MODE="dir" ;;
    2) MODE="dns" ;;
    3) MODE="fuzz" ;;
    4) MODE="all" ;;
    *) MODE="all" ;;
  esac
fi

if [ -z "$TARGET" ]; then
  echo -e "${RED}[-]${RESET} Error: no se proporcionó URL."
  exit 1
fi

DOMAIN=$(echo "$TARGET" | sed 's|https\?://||' | cut -d'/' -f1)

echo ""
echo -e "${GREEN}[+]${RESET} Objetivo: $TARGET"
echo -e "${GREEN}[+]${RESET} Dominio: $DOMAIN"
echo -e "${GREEN}[+]${RESET} Modo: $MODE"
echo -e "${GREEN}[+]${RESET} Inicio: $(date)"
echo ""

setup_wordlists

# Iniciar reporte
{
  echo "=== SANTRIX WEB ENUMERATION REPORT ==="
  echo "OBJETIVO : $TARGET"
  echo "FECHA    : $(date)"
  echo "MODO     : $MODE"
  echo "======================================="
  echo ""
} > "$OUTPUT_FILE"

# ── 1. Información básica ─────────────────────────────
echo -e "${CYAN}[*]${RESET} Analizando cabeceras HTTP..."
{
  echo "--- CABECERAS HTTP ---"
  curl -s -I --max-time 10 "$TARGET"
  echo ""
} | tee -a "$OUTPUT_FILE"

# ── 2. Enumeración de directorios ─────────────────────
if [[ "$MODE" == "dir" || "$MODE" == "all" ]]; then
  if command -v gobuster &>/dev/null; then
    echo -e "${CYAN}[*]${RESET} Enumerando directorios con gobuster..."
    {
      echo "--- DIRECTORIOS (gobuster dir) ---"
      gobuster dir \
        -u "$TARGET" \
        -w "$COMMON_LIST" \
        -t 20 \
        --timeout 10s \
        -q \
        2>/dev/null
      echo ""
    } | tee -a "$OUTPUT_FILE"
  else
    echo -e "${YELLOW}[!]${RESET} gobuster no disponible, usando método alternativo..."
    {
      echo "--- DIRECTORIOS (curl brute) ---"
      while IFS= read -r path; do
        CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET/$path")
        if [[ "$CODE" != "404" && "$CODE" != "000" ]]; then
          echo "[$CODE] /$path"
        fi
      done < <(head -200 "$COMMON_LIST")
      echo ""
    } | tee -a "$OUTPUT_FILE"
  fi
fi

# ── 3. Enumeración de subdominios ─────────────────────
if [[ "$MODE" == "dns" || "$MODE" == "all" ]]; then
  if command -v gobuster &>/dev/null; then
    echo -e "${CYAN}[*]${RESET} Enumerando subdominios con gobuster dns..."
    {
      echo "--- SUBDOMINIOS (gobuster dns) ---"
      gobuster dns \
        -d "$DOMAIN" \
        -w "$DIRS_LIST" \
        -t 20 \
        -q \
        2>/dev/null
      echo ""
    } | tee -a "$OUTPUT_FILE"
  fi
fi

# ── 4. Fuzzing con ffuf ───────────────────────────────
if [[ "$MODE" == "fuzz" || "$MODE" == "all" ]]; then
  if command -v ffuf &>/dev/null; then
    echo -e "${CYAN}[*]${RESET} Fuzzing con ffuf..."
    {
      echo "--- FFUF FUZZING ---"
      ffuf \
        -u "$TARGET/FUZZ" \
        -w "$COMMON_LIST" \
        -t 20 \
        -timeout 10 \
        -mc 200,201,204,301,302,307,401,403 \
        -ac \
        -v \
        2>/dev/null | grep -E "^\[Status\]|^http"
      echo ""
    } | tee -a "$OUTPUT_FILE"
  fi
fi

# ── 5. Escaneo de puertos básico ──────────────────────
echo -e "${CYAN}[*]${RESET} Escaneo de puertos comunes con nmap..."
{
  echo "--- PUERTOS ABIERTOS (nmap) ---"
  nmap -T4 -F --open "$DOMAIN" 2>/dev/null
  echo ""
} | tee -a "$OUTPUT_FILE"

# ── Resumen ───────────────────────────────────────────
echo ""
echo -e "${GREEN}#################################################${RESET}"
echo -e "${GREEN}[+]${RESET} Enumeración completada."
echo -e "${GREEN}[+]${RESET} Reporte guardado en: $OUTPUT_FILE"
echo -e "${GREEN}[+]${RESET} Acceso web: /results/$(basename "$OUTPUT_FILE")"
echo -e "${GREEN}#################################################${RESET}"
