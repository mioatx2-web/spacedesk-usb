# Plan – spacedesk-usb

## En qué nos quedamos
2026-11-24: primera versión lista y probada en la GT-P5210 (modos `Settings` y `Root`, vigilancia, instalador). Aún no está en GitHub.
**Sigue:** que el usuario revise el README y la licencia (lleva su nombre) y publicar en GitHub cuando lo pida. Antes de promoverla en un grupo de Facebook, probarla en otra tablet que va a conseguir el usuario (ideal: Android más nuevo).

## Hecho
- [x] Script generalizado, configuración de ejemplo, instalador y desinstalador (2026-11-24).
- [x] README en español e inglés, licencia MIT, `.gitignore` (2026-11-24).
- [x] Probado en la GT-P5210: modo `Settings`, modo `Root`, reconexión, instalador y desinstalador (2026-11-24).

## Qué falta
- [ ] Publicar en GitHub (crear el repo y subir), cuando el usuario lo pida.
- [ ] Probar bloqueo y desbloqueo de la PC con esta versión (en HomeLab ya funciona; la lógica es la misma).
- [ ] Probar el toque de respaldo (spacedesk sin conexión automática).
- [ ] Probar en otra tablet o teléfono, idealmente Android 10 o más nuevo (interfaz `ncm`, Ajustes distintos).
- [ ] Decidir si HomeLab pasa a usar este script en lugar de `tablet-spacedesk.ps1`.
- [ ] Promoción en un grupo de Facebook, después de la prueba en la otra tablet (2026-11-24). Preparar antes: Release con ZIP en GitHub, GIF de la reconexión, que `install.ps1` ofrezca descargar ADB oficial, y el post (como "beta", pidiendo modelo y versión de Android).
