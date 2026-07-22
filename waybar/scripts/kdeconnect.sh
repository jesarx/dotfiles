#!/bin/sh
# ===================================================
#  KDE Connect status for waybar  (return-type: json)
# ===================================================
# Requires: kdeconnect-cli  (paquete kdeconnect)
# Optional: dbus-send  -> muestra el nivel de bateria del telefono
# Uso:
#   kdeconnect.sh          -> imprime el estado en JSON (para waybar)
#   kdeconnect.sh ring     -> hace sonar el telefono (find my device)

PHONE=""

# Primer dispositivo emparejado y disponible (reachable)
first_device() {
    kdeconnect-cli -a --id-only 2>/dev/null | head -n1
}

# Accion: hacer sonar el telefono
if [ "$1" = "ring" ]; then
    id=$(first_device)
    [ -n "$id" ] && kdeconnect-cli -d "$id" --ring
    exit 0
fi

id=$(first_device)

if [ -z "$id" ]; then
    printf '{"text":"%s","tooltip":"KDE Connect: desconectado","class":"disconnected"}\n' "$PHONE"
    exit 0
fi

name=$(kdeconnect-cli -a --name-only 2>/dev/null | head -n1)
[ -z "$name" ] && name="Dispositivo"

# Bateria via DBus (best-effort; si falla, simplemente no se muestra)
obj="/modules/kdeconnect/devices/$(printf '%s' "$id" | tr -c 'A-Za-z0-9' '_')/battery"
charge=$(dbus-send --session --print-reply=literal --dest=org.kde.kdeconnect \
        "$obj" org.freedesktop.DBus.Properties.Get \
        string:org.kde.kdeconnect.device.battery string:charge 2>/dev/null \
        | grep -oE '[0-9]+' | tail -n1)

# Escapar comillas dobles del nombre para un JSON valido
name=$(printf '%s' "$name" | sed 's/"/\\"/g')

if [ -n "$charge" ]; then
    printf '{"text":"%s %s%%","tooltip":"%s  ·  bateria %s%%","class":"connected"}\n' "$PHONE" "$charge" "$name" "$charge"
else
    printf '{"text":"%s","tooltip":"%s  ·  conectado","class":"connected"}\n' "$PHONE" "$name"
fi
