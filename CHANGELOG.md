# Changelog – spacedesk-usb

## 2026-11-24
- Primera versión, a partir del script de HomeLab:
  - Autodetección de ADB, de la tablet y del paquete de spacedesk.
  - Anclaje USB sin root (modo `Settings`: abre Ajustes y toca la opción), con root (`Root`, códigos configurables) o a mano (`Manual`).
  - IP de la tablet leída del dispositivo (rndis/usb/ncm), sin IP fija.
  - Toque de respaldo en spacedesk buscando la conexión en pantalla (uiautomator), sin coordenadas fijas.
  - Vigilancia de la conexión, apagado de la pantalla al bloquear la PC y reinicio de spacedesk al desbloquear.
  - `install.ps1` / `uninstall.ps1` (tarea programada sin permisos de administrador) y `config.example.psd1`.
  - README en español e inglés, licencia MIT.
- Probado en la GT-P5210: modo `Settings` (anclaje apagado → conectado en ~70 s), modo `Root` (~40 s), reconexión al cerrar spacedesk (~55 s), instalador y desinstalador.
