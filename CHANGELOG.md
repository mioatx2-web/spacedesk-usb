# Changelog – spacedesk-usb

## 2026-11-24 (después de v0.1.0)
- README (es/en): nota de que spacedesk es gratis para uso personal y que para uso comercial hay que revisar su licencia; el proyecto no incluye spacedesk.

## 2026-11-24 (v0.1.0)
- Publicado en GitHub: https://github.com/mioatx2-web/spacedesk-usb (público). Release v0.1.0 (beta): https://github.com/mioatx2-web/spacedesk-usb/releases/tag/v0.1.0
- `.gitattributes`: el ZIP de descarga deja fuera `CLAUDE.md` y `docs/`. El README indica descargar desde Releases.

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
