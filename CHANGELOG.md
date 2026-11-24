# Changelog – spacedesk-usb

## 2026-11-24 (v0.1.1)
- Corregido: sin `Serial` configurado, el script tomaba el primer dispositivo ADB, aunque fuera un celular. Ahora solo usa un dispositivo con spacedesk instalado; los demás se ignoran (y se anota en el log).
- README (es/en): desactivar "USB Cable Android" en la consola de spacedesk (bloquea la transferencia de archivos de cualquier Android conectado) y su entrada en Problemas comunes.
- Corregido: los commits aparecían en GitHub como `pensionlegal-sistemas` por el correo global de Git. Se reescribió el historial con el correo noreply de mioatx2-web y se forzó la subida (también la etiqueta v0.1.0).
- README (es/en): sección "Reportar si funcionó o falló" (modelo, versión de Android, resultado y el log si falló) y compatibilidad esperada (Android 5 a 9).
- Se decide darla a conocer ya en Facebook como beta, pidiendo pruebas en equipos más nuevos.
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
