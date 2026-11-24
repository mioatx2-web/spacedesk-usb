# Decisiones – spacedesk-usb

Para cambiar una decisión se edita esta misma entrada y se anota la fecha.

## Alcance (2026-11-24)
- **Repo aparte de HomeLab:** HomeLab tiene datos personales (hostname, planes de red). Aquí solo va lo publicable.
- **Para cualquier Android, sin root por defecto.** Con root es opcional.
- **README en español e inglés; mensajes del script en español.**
- **Licencia MIT.**

## Cómo funciona y por qué
- **Anclaje sin root (modo `Settings`):** abre `com.android.settings/.TetherSettings` (o `Settings$TetherSettingsActivity`), busca con uiautomator la opción por su texto (`TetherLabels`, varios idiomas) y toca el interruptor de esa fila solo si está apagado. No se usan los códigos de `service call` por defecto: cambian entre versiones de Android y un número equivocado llama a otra función del sistema.
- **Modo `Root`:** opcional, con los códigos en la configuración (sin valor por defecto). Probados: LineageOS 14.1 = 33 (setUsbTethering) y 20 (tether).
- **Detección del anclaje y de la IP:** `ip -4 -o addr` en interfaces `rndis*`, `usb*` o `ncm*` (Android nuevo usa ncm). No necesita root. En HomeLab se usaba `dumpsys connectivity` con root y una IP fija.
- **Conexión real:** TCP establecida del servicio spacedesk de la PC (puerto 28252) con la IP de la tablet. Ver la pantalla de video de spacedesk no basta: al quitar el cable se queda parpadeando con la sesión muerta.
- **Abrir spacedesk:** `monkey -p <paquete> -c android.intent.category.LAUNCHER 1`, para no depender del nombre de la actividad. El paquete se detecta con `pm list packages spacedesk`.
- **Toque de respaldo:** busca en pantalla el texto "Connection:" / "Conexión:" o el nombre de la PC, en vez de coordenadas fijas. **Sin probar:** en la tablet de pruebas la conexión automática siempre funcionó.
- **Al desbloquear se reinicia spacedesk siempre:** la sesión que sobrevive al apagado de pantalla queda conectada pero lenta (medido en HomeLab: 0.1–0.2 MB/s contra 4–7 MB/s).
- **Bloqueo de la PC:** se detecta por el proceso `LogonUI.exe`.
- **Tarea programada con `conhost --headless`** (Windows 10 21H2+ / 11) para que no aparezca ninguna ventana; en Windows más viejo usa `powershell.exe -WindowStyle Hidden`.
- **Reinicio del servidor ADB** solo si Windows ve una interfaz ADB y `adb devices` no lista nada. Así un teléfono "unauthorized" conectado no provoca reinicios en bucle.

## Publicación (2026-11-24)
- **Cuenta:** mioatx2-web (la propia, no la de Pensión Legal). El remoto lleva el usuario en la URL (`https://mioatx2-web@github.com/...`) porque Git tiene guardada también la cuenta `pensionlegal-sistemas`; así el gestor de credenciales usa la correcta solo para este repo.
- **Descarga:** el ZIP automático de cada Release, sin las notas internas (`.gitattributes` con `export-ignore`). Versión 0.1.0 con "(beta)" en el título y las notas, pero **no** marcada como Pre-release: GitHub excluye los pre-release de `releases/latest`, que es el enlace del README.

## Notas de desarrollo
- **Log aislado en el entorno de Claude (2026-11-24):** el entorno donde corre Claude ve una copia aislada de `%LOCALAPPDATA%\spacedesk-usb`; lo que escribe la tarea programada no aparece ahí. Se perdió tiempo creyendo que la tarea no funcionaba. Para leer el log real, usar una tarea programada que lo copie a la carpeta del proyecto.
