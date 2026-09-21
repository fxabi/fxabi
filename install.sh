#!/bin/bash

DIR="/etc/adm-lite/userDIR"
SCRIPT="/usr/local/bin/daynet-limiter.sh"
SERVICE="/etc/systemd/system/daynet-limiter.service"


echo "===================================="
echo " Daynet SSH Limiter Installer"
echo "===================================="


# Detectar userDIR

if [ ! -d "$DIR" ]; then
    echo ""
    echo "ERROR: No se encontró Chumo/adm-lite userDIR"
    echo "Ruta buscada: $DIR"
    exit 1
fi

echo ""
echo "OK: Encontrado $DIR"


# Pedir intervalo

read -p "Intervalo de revisión en segundos [10]: " INTERVALO

if [ -z "$INTERVALO" ]; then
    INTERVALO=10
fi


echo ""
echo "Instalando con intervalo: ${INTERVALO}s"
echo ""


# Crear script limiter

cat > "$SCRIPT" <<EOF
#!/bin/bash

DIR="/etc/adm-lite/userDIR"

while true; do

for file in "\$DIR"/*; do

    [ -f "\$file" ] || continue

    user=\$(basename "\$file")

    limit=\$(grep "limite:" "\$file" | awk '{print \$2}')
    [ -n "\$limit" ] || limit=1


    mapfile -t sessions < <(
        ps -u "\$user" -o pid=,etimes=,cmd= 2>/dev/null |
        grep "sshd: \$user" |
        sort -k2 -n
    )


    total=\${#sessions[@]}


    if [ "\$total" -gt "\$limit" ]; then

        exceso=\$((total-limit))

        for ((i=0;i<exceso;i++)); do

            pid=\$(echo "\${sessions[\$i]}" | awk '{print \$1}')

            if [ -n "\$pid" ]; then
                kill -9 "\$pid" 2>/dev/null
            fi

        done

    fi

done

sleep $INTERVALO

done
EOF


chmod +x "$SCRIPT"


echo "OK: Script creado"


# Crear servicio systemd

cat > "$SERVICE" <<EOF
[Unit]
Description=Daynet SSH Connection Limiter
After=network.target

[Service]
Type=simple
ExecStart=$SCRIPT
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


echo "OK: Servicio creado"


# Activar servicio

systemctl daemon-reload
systemctl enable daynet-limiter.service
systemctl restart daynet-limiter.service


echo ""
echo "===================================="
echo " Instalación completada"
echo "===================================="
echo ""
echo "Estado:"
systemctl status daynet-limiter.service --no-pager
