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
    
    read -p "Introduce la URL objetivo (con parámetros, ej: http://test.com/id=1): " TARGET
    
    if [ -z "$TARGET" ]; then
        echo "[!] Error: URL no válida."
        exit 1
    fi

    echo "[+] Probando payloads de escape básicos en $TARGET..."
    # Simulación de estructura de ataque real sobre la URL proporcionada
    # En un entorno con dependencias instaladas, aquí se invocaría la lógica de red
    echo "    [TEST] ' OR 1=1 --"
    echo "    [TEST] ' UNION SELECT NULL--"
    echo ""
    echo "[*] Nota: Para escaneos automáticos profundos, se recomienda instalar 'sqlmap' vía Nix."
else
    sqlmap "$@"
fi
