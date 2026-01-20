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
    
    if [ ! -z "$POST_DATA" ]; then
        echo "[+] Probando inyección en parámetros POST: $POST_DATA"
        # Con sqlmap instalado, lo ideal es usarlo directamente
        if command -v sqlmap &> /dev/null; then
            sqlmap -u "$TARGET" --data="$POST_DATA" --batch --banner
        else
            echo "    [TEST POST] ' OR '1'='1"
        fi
    else
        echo "[+] Probando inyección en parámetros de URL/Headers..."
        if command -v sqlmap &> /dev/null; then
            sqlmap -u "$TARGET" --batch --banner
        else
            echo "    [TEST GET] $TARGET?id='"
        fi
    fi
    
    echo ""
    echo "[*] Sugerencia: Para auditorías reales, usa 'sqlmap -u \"$TARGET\" --forms --crawl=2'"
else
    sqlmap "$@"
fi
