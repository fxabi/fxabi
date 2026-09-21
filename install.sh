#!/bin/bash

REPO="https://raw.githubusercontent.com/fxabi/Day-Script/main/install-daynet-limiter.sh"

echo "===================================="
echo " Daynet Limiter Downloader"
echo "===================================="

read -s -p "Token GitHub: " TOKEN
echo ""

if [ -z "$TOKEN" ]; then
    echo "ERROR: Token vacío"
    exit 1
fi


curl -fsL \
-H "Authorization: Bearer $TOKEN" \
"$REPO" \
-o /tmp/install-daynet-limiter.sh


if [ ! -s /tmp/install-daynet-limiter.sh ]; then
    echo "ERROR: No se pudo descargar el instalador"
    exit 1
fi


chmod +x /tmp/install-daynet-limiter.sh

bash /tmp/install-daynet-limiter.sh
