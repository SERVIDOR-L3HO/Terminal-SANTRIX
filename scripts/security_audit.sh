#!/bin/bash

TARGET_URL=$1

if [ -z "$TARGET_URL" ]; then
    echo "Error: Debes proporcionar una URL. Uso: ./scripts/security_audit.sh https://tuweb.com"
    exit 1
fi

echo "#################################################"
echo "#          SANTRIX SECURITY AUDIT REPORT        #"
echo "#################################################"
echo "Target: $TARGET_URL"
echo "Fecha: $(date)"
echo "-------------------------------------------------"

# 1. Prueba de estrés real (Intensiva)
echo "[+] Iniciando prueba de estrés real (Ataque de inundación HTTP)..."
echo "[!] ADVERTENCIA: Esta prueba puede afectar la disponibilidad de tu servidor."

# Usamos xargs para ejecutar múltiples hilos de curl en paralelo de forma mucho más agresiva
# -n 500: total de peticiones, -P 50: hilos simultáneos
seq 500 | xargs -n 1 -P 50 curl -s -o /dev/null -w "%{http_code}\n" "$TARGET_URL" > /tmp/stress_results.txt &
STRESS_PID=$!

echo "[*] Ejecutando ataque en segundo plano (PID: $STRESS_PID)..."
sleep 5 # Dejamos que corra unos segundos para ver el impacto inmediato
echo "[*] Analizando impacto inicial..."

# Contar cuántas peticiones fallaron o tardaron
FAIL_COUNT=$(grep -c -v "200" /tmp/stress_results.txt)
echo "[*] Peticiones bloqueadas/fallidas detectadas: $FAIL_COUNT"

kill $STRESS_PID 2>/dev/null
echo ""
echo "[*] Prueba de carga real finalizada."

# 2. Análisis de fallos comunes
echo "-------------------------------------------------"
echo "[+] ANALIZANDO VULNERABILIDADES:"

# Verificar si el servidor responde
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL")

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "[!] RESULTADO: El servidor NO bloqueó el ataque simulado."
    echo "[!] FALLO DETECTADO: Falta de Rate Limiting o WAF activo."
    echo "[i] RECOMENDACIÓN: Implementar Cloudflare o configurar mod_evasive/fail2ban."
else
    echo "[✓] RESULTADO: El servidor respondió con estado $HTTP_STATUS o no respondió."
    echo "[✓] ÉXITO: El servidor parece tener mecanismos de protección activos."
fi

# 3. Verificación de Cabeceras de Seguridad
echo "-------------------------------------------------"
echo "[+] REVISIÓN DE CABECERAS:"
HEADERS=$(curl -sI "$TARGET_URL")

if echo "$HEADERS" | grep -q "Strict-Transport-Security"; then
    echo "[✓] HSTS: Protegido"
else
    echo "[X] HSTS: Faltante (Riesgo de Man-in-the-Middle)"
fi

if echo "$HEADERS" | grep -q "X-Frame-Options"; then
    echo "[✓] Clickjacking: Protegido"
else
    echo "[X] X-Frame-Options: Faltante (Riesgo de Clickjacking)"
fi

echo "-------------------------------------------------"
echo "#           FIN DEL REPORTE SANTRIX             #"
echo "#################################################"
