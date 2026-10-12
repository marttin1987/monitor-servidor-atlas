# Monitor Servidor ATLAS

Suite modular de monitoreo y auditoria ligera para servidores Linux (Debian/Ubuntu).

## Caracteristicas
- **Almacenamiento**: Auditoria de la particion raiz (`/`) con umbrales configurables de advertencia y estado critico.
- **Servicios Systemd**: Verificacion en tiempo real del estado de servicios criticos (`ssh`, `cron`, etc.).
- **Conectividad de Red**: Prueba activa de puertos TCP locales mediante *TCP Handshake* utlizando `netcat` (`nc`).
- **Configuracion Externa**: Parametros centralizados en `config/monitor.conf`.
- **Registro Centralizado**: Logs rotatorios con timestamp y codigos de salida estandar (`0`OK, `1` WARN, `2` CRITICAL) listos para integraciones con cron o herramientas de monitoreo

## Prerrequisitos

Asegurate de contar con la herramienta `netcat` instalada:

```bash
sudo apt update && sudo apt install -y netcat-openbsd 
