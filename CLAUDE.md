# spacedesk-usb

Script público (GitHub) para usar una tablet Android como monitor con spacedesk por USB, sin tocar la tablet. Nació del proyecto HomeLab (`C:\Proyectos\HomeLab\scripts\tablet-spacedesk.ps1`), pero es independiente.

## Documentación
- `docs/plan.md`: qué está hecho, qué falta y en qué nos quedamos. Leerlo primero.
- `docs/decisiones.md`: decisiones técnicas y su porqué.
- `CHANGELOG.md`: registro de cambios, el más reciente arriba.
- `README.md` (español) y `README.en.md` (inglés): mantener los dos iguales.

## Reglas
- **Es público:** nada de datos personales ni del equipo propio (serial de la tablet, hostname, rutas personales, IPs de la casa). `config.psd1` está en `.gitignore`.
- No subir a GitHub sin que el usuario lo pida.
- Todo lo que dependa del dispositivo va en la configuración, con un valor por defecto que funcione sin root.
- Marcar como "sin probar" lo que no se haya probado en un equipo real. Equipo de pruebas: Galaxy Tab 3 10.1 (GT-P5210), LineageOS 14.1 (Android 7.1), Windows 11.
- Archivos `.ps1` y `.psd1` en UTF-8 **con BOM** (PowerShell 5.1 los lee mal sin BOM).
- Al probar, detener antes la tarea "HomeLab - Tablet spacedesk" y volver a iniciarla al terminar.
- El entorno de Claude ve una copia aislada de `%LOCALAPPDATA%\spacedesk-usb`: para leer el log que escribe la tarea programada, leerlo desde otra tarea (ver `docs/decisiones.md`).
