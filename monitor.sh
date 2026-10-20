#!/bin/bash
# ==============================================================================
# Nombre: monitor.sh
# Proyecto: ATLAS
# Propósito: Suite modular de monitoreo de disco, servicios y puertos en Linux.
# Autor: Martín Coria
# ==============================================================================
set -euo pipefail

# 1. Determinar ruta dinamica del proyecto y cargar configuración
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/monitor.conf"

if [ ! -f "$CONFIG_FILE" ]; then	
    echo "❌ ERROR: Archivo de configuración '$CONFIG_FILE' no encontrado." >&2
    exit 2
fi

# Cargar variables del archivo .conf
# shellcheck source=/dev/null
source "$CONFIG_FILE"

# Validar que LOG_FILE este definido
if [ -z "${LOG_FILE:-}" ]; then
	echo "ERROR: La variable LOG_FILE no esta definida en $CONFIG_FILE." >&2
	exit 2
fi

# Validar que la herramienta 'nc' este instalada
if ! command -v nc >/dev/null 2>&1; then
	echo "ERROR: 'nc' (netcat) no esta instalado. Instalalo con: sudo apt install netcat-openbsd" >&2
	exit 2
fi

# 3. Asegurar existencia de carpeta de logs
mkdir -p "$(dirname "$LOG_FILE")"

FECHA=$(date "+%Y-%m-%d %H:%M:%S")
echo "==================================================" | tee -a "$LOG_FILE"
echo "    REPORTE MONITOR ATLAS - $FECHA" | tee -a "$LOG_FILE"
echo "==================================================" | tee -a "$LOG_FILE"

ESTADO_GENERAL=0

# 4. Monitoreo de Almacenamiento (Partición Raíz)
PORCENTAJE_DISCO=$(df --output=pcent / | tail -1 | tr -dc '0-9')
echo "[1] Almacenamiento (/): ${PORCENTAJE_DISCO}% de uso" | tee -a "$LOG_FILE"

if [ "$PORCENTAJE_DISCO" -gt "$DISCO_UMBRAL_CRITICO" ]; then
    echo "  🚨 CRÍTICO: Uso de disco superó el ${DISCO_UMBRAL_CRITICO}%." | tee -a "$LOG_FILE"
    ESTADO_GENERAL=2
elif [ "$PORCENTAJE_DISCO" -gt "$DISCO_UMBRAL_WARN" ]; then
    echo "  ⚠️ ADVERTENCIA: Uso de disco superó el ${DISCO_UMBRAL_WARN}%." | tee -a "$LOG_FILE"
    [ "$ESTADO_GENERAL" -eq 0 ] && ESTADO_GENERAL=1
else
    echo "  🟢 Disco en nivel normal." | tee -a "$LOG_FILE"
fi

# 5. Monitoreo de Servicios (Systemd)
echo "[2] Estado de Servicios Críticos:" | tee -a "$LOG_FILE"
for SERVICIO in "${SERVICIOS_A_VIGILAR[@]}"; do
    if systemctl is-active --quiet "$SERVICIO"; then
        echo "  🟢 Servicio '$SERVICIO': ACTIVO" | tee -a "$LOG_FILE"
    else
        echo "  🚨 CRÍTICO: Servicio '$SERVICIO': INACTIVO" | tee -a "$LOG_FILE"
        ESTADO_GENERAL=2
    fi
done

# 6. Monitoreo de Puertos TCP con Netcat (nc)
echo "[3] Auditoría de Conectividad a Puertos TCP (Localhost):" | tee -a "$LOG_FILE"
for PUERTO in "${PUERTOS_A_VIGILAR[@]}"; do
    if nc -zv -w 2 127.0.0.1 "$PUERTO" > /dev/null 2>&1; then
        echo "  🟢 Puerto TCP $PUERTO: RESPONDIENDO (Open)" | tee -a "$LOG_FILE"
    else
        echo "  ⚠️ ADVERTENCIA: Puerto TCP $PUERTO: NO RESPONDE (Closed/Filtered)" | tee -a "$LOG_FILE"
        [ "$ESTADO_GENERAL" -eq 0 ] && ESTADO_GENERAL=1
    fi
done

echo "==================================================" | tee -a "$LOG_FILE"
echo "Estado final del chequeo: $ESTADO_GENERAL" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

exit "$ESTADO_GENERAL"
