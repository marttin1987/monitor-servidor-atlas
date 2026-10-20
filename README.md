# Monitor Servidor ATLAS

Suite modular de monitoreo y auditoría ligera para servidores Linux (Debian/Ubuntu), escrita en Bash.

## Características

- **Almacenamiento:** auditoría de la partición raíz (`/`) con umbrales configurables de advertencia y estado crítico.
- **Servicios systemd:** verificación del estado de los servicios críticos (`ssh`, `cron`, etc.).
- **Conectividad de red:** prueba activa de puertos TCP locales con `netcat` (`nc`).
- **Configuración externa:** parámetros centralizados en `config/monitor.conf`.
- **Registro:** cada ejecución se guarda con fecha y hora, y el script devuelve códigos de salida estándar, listos para `cron` o herramientas de monitoreo.

## Prerrequisitos

Hace falta la herramienta `netcat`:

```bash
sudo apt update && sudo apt install -y netcat-openbsd
```

## Instalación

```bash
git clone https://github.com/marttin1987/monitor-servidor-atlas.git
cd monitor-servidor-atlas
chmod +x monitor.sh
```

## Configuración

Los parámetros están en `config/monitor.conf`:

| Variable | Qué define | Valor por defecto |
| --- | --- | --- |
| `DISCO_UMBRAL_WARN` | Uso de disco (%) desde el cual hay advertencia | `70` |
| `DISCO_UMBRAL_CRITICO` | Uso de disco (%) desde el cual es crítico | `85` |
| `SERVICIOS_A_VIGILAR` | Servicios de systemd a comprobar | `("ssh" "cron")` |
| `PUERTOS_A_VIGILAR` | Puertos TCP locales a probar | `(22)` |
| `LOG_FILE` | Archivo donde se guarda el registro | `$HOME/monitor-servidor-atlas/logs/monitor.log` |

## Uso

```bash
./monitor.sh
```

El script se puede ejecutar desde cualquier carpeta: encuentra su configuración a partir de su propia ubicación.

Ejemplo de salida:

```text
==================================================
    REPORTE MONITOR ATLAS - 2026-10-20 18:40:02
==================================================
[1] Almacenamiento (/): 63% de uso
  🟢 Disco en nivel normal.
[2] Estado de Servicios Críticos:
  🟢 Servicio 'ssh': ACTIVO
  🟢 Servicio 'cron': ACTIVO
```

## Códigos de salida

| Código | Significado |
| --- | --- |
| `0` | Todo correcto |
| `1` | Advertencia (disco sobre el umbral de aviso o un puerto que no responde) |
| `2` | Crítico (disco sobre el umbral crítico, servicio inactivo o error de configuración) |

## Ejecución programada

Ejemplo de entrada de `cron` para ejecutarlo cada 15 minutos:

```cron
*/15 * * * * /home/usuario/monitor-servidor-atlas/monitor.sh > /dev/null 2>&1
```

## Estructura

```text
monitor.sh            script principal
config/monitor.conf   umbrales, servicios y puertos
logs/                 registro de ejecuciones (no se sube al repositorio)
```

## Licencia

Licencia MIT. Ver el archivo `LICENSE`.
