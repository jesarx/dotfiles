#!/bin/sh
# ===================================================
#  Network menu for waybar  ·  NetworkManager + wofi
# ===================================================
# Clic en el modulo de red abre este menu.
# Requiere: NetworkManager (nmcli) y wofi.
#   - Selecciona una red para conectarte (pide clave si hace falta)
#   - "Apagar/Encender WiFi" para el toggle del radio

WIFI=""     # fa-wifi
LOCK=""     # fa-lock
POWER=""   # fa-power-off

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send -a "Red" "$1" "$2"
}

menu() {
    wofi --dmenu --prompt "Red" --width 360 --height 420 --lines 10 --location center
}

# --- Sin nmcli no hay nada que hacer ---
if ! command -v nmcli >/dev/null 2>&1; then
    printf '%s\n' "NetworkManager (nmcli) no esta instalado" | \
        wofi --dmenu --prompt "Red" --width 360 --lines 1 --location center >/dev/null
    exit 1
fi

radio=$(nmcli radio wifi 2>/dev/null | tr -d '[:space:]')

# --- WiFi apagado: solo ofrecer encender ---
if [ "$radio" != "enabled" ]; then
    choice=$(printf '%s\n' "$WIFI  Encender WiFi" | menu)
    case "$choice" in
        *"Encender WiFi") nmcli radio wifi on ;;
    esac
    exit 0
fi

# --- WiFi encendido ---
current=$(nmcli -t -e no -f active,ssid dev wifi 2>/dev/null \
    | awk -F: '$1=="yes"{sub(/^[^:]*:/,""); print; exit}')

# Redes disponibles: SIGNAL:SECURITY:SSID  (sin escapes, SSID al final)
networks=$(nmcli -t -e no -f SIGNAL,SECURITY,SSID device wifi list 2>/dev/null \
    | sort -t: -k1,1 -rn \
    | awk -F: '{
        signal=$1; sec=$2; ssid=$3;
        for (i=4; i<=NF; i++) ssid=ssid":"$i;
        if (ssid=="" || seen[ssid]++) next;
        printf "%s\t%s\t%s\n", ssid, signal, sec;
    }')

list="$POWER  Apagar WiFi"

OLDIFS=$IFS
IFS='
'
for row in $networks; do
    ssid=$(printf '%s' "$row" | cut -f1)
    signal=$(printf '%s' "$row" | cut -f2)
    sec=$(printf '%s' "$row" | cut -f3)
    lock=""; [ -n "$sec" ] && lock=" $LOCK"
    mark="";  [ "$ssid" = "$current" ] && mark="  *"
    list="$list
$WIFI $ssid  ($signal%)$lock$mark"
done
IFS=$OLDIFS

choice=$(printf '%s\n' "$list" | menu)
[ -z "$choice" ] && exit 0

# --- Toggle apagar ---
case "$choice" in
    *"Apagar WiFi") nmcli radio wifi off; exit 0 ;;
esac

# --- Extraer SSID: quita sufijo "  (..." , prefijo "icono " y espacios ---
ssid="${choice%%  (*}"
ssid="${ssid#* }"
ssid=$(printf '%s' "$ssid" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
[ -z "$ssid" ] && exit 0

# --- Conexion ya guardada ---
if nmcli -t -f NAME connection show 2>/dev/null | grep -Fxq "$ssid"; then
    if nmcli connection up id "$ssid" >/dev/null 2>&1; then
        notify "Conectado" "$ssid"
    else
        notify "No se pudo conectar" "$ssid"
    fi
    exit 0
fi

# --- Red nueva: intentar sin clave; si falla, pedir contrasena ---
if nmcli device wifi connect "$ssid" >/dev/null 2>&1; then
    notify "Conectado" "$ssid"
    exit 0
fi

pass=$(printf '' | wofi --dmenu --password --prompt "Clave de $ssid" \
        --width 340 --height 90 --lines 0 --location center)
[ -z "$pass" ] && exit 0

if nmcli device wifi connect "$ssid" password "$pass" >/dev/null 2>&1; then
    notify "Conectado" "$ssid"
else
    notify "Clave incorrecta o fallo" "$ssid"
fi
