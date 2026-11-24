# spacedesk-usb

[English](README.en.md)

Usa una tablet Android como monitor extra de Windows con [spacedesk](https://www.spacedesk.net/) **por cable USB**, sin tocar la tablet. Un script de PowerShell corre escondido en la PC y, por ADB:

- **Al conectar el cable:** activa el anclaje USB, abre spacedesk y se conecta.
- **Si spacedesk pierde la conexión** con el cable puesto, lo cierra y lo vuelve a abrir.
- **Al bloquear la PC (Win+L):** apaga la pantalla de la tablet. **Al desbloquear:** la enciende y reinicia spacedesk.

### Por qué existe
- spacedesk por USB funciona a través del **anclaje USB** de Android, y ese anclaje se apaga cada vez que se desconecta el cable.
- Al quitar y poner el cable, spacedesk se queda en su pantalla de video, parpadeando, y nunca reconecta. Hay que cerrarlo a mano.
- Después de apagar y encender la pantalla de la tablet, la sesión sigue conectada pero queda **muy lenta**. En la tablet donde se desarrolló, mandaba 0.1 MB/s en vez de 4–7 MB/s. Reiniciar spacedesk lo arregla.

## Requisitos
- Windows 10 o 11 con el **driver de spacedesk** instalado.
- Tablet o teléfono Android con **spacedesk Viewer** instalado.
- **ADB** (Android SDK Platform-Tools), oficial de Google: <https://developer.android.com/tools/releases/platform-tools>
- En la tablet: **Opciones de desarrollador → Depuración USB** activada, y esta PC autorizada ("Permitir siempre").
- **No necesita root** ni permisos de administrador en Windows.
- **spacedesk es gratis para uso personal; para uso comercial revisa [su licencia](https://www.spacedesk.net/licensing/).** Este proyecto no incluye spacedesk: cada quien lo instala desde su página o tienda oficial.

## Instalación
1. Descarga la última versión desde [**Releases**](https://github.com/mioatx2-web/spacedesk-usb/releases/latest) (**Source code (zip)**) y descomprímela en una carpeta fija, por ejemplo `C:\spacedesk-usb`.
2. Descomprime Platform-Tools dentro de esa carpeta, de modo que quede `C:\spacedesk-usb\platform-tools\adb.exe`. Si ya tienes ADB en otro lugar, ver [Configuración](#configuración).
3. Conecta la tablet por USB y acepta el aviso de depuración USB ("Permitir siempre desde esta computadora").
4. En **spacedesk Viewer** de la tablet, activa la conexión automática a tu PC si tu versión lo tiene. Si no, el script toca la conexión en la lista.
5. Recomendado: en la tablet, **Ajustes → Seguridad → Bloqueo de pantalla → Ninguno**. Así, al desbloquear la PC, la tablet no se queda en su pantalla de bloqueo.
6. Abre PowerShell en la carpeta y ejecuta:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1
   ```
   Esto crea la tarea programada **spacedesk-usb**, que arranca al iniciar sesión, y la inicia en ese momento.

Para quitarlo:
```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

## Uso
- Conecta la tablet: en 15 a 70 segundos aparece el escritorio. La primera vez tarda más porque activa el anclaje.
- Log: `%LOCALAPPDATA%\spacedesk-usb\spacedesk-usb.log`
- **Pausa:** si existe el archivo `%LOCALAPPDATA%\spacedesk-usb\pausa`, el script no vigila la conexión. Sirve, por ejemplo, para cerrar spacedesk y pasar archivos por MTP, porque spacedesk y MTP no funcionan juntos. Bórralo para reanudar.

## Configuración
Copia `config.example.psd1` como `config.psd1` y cambia solo lo que necesites. Todas las opciones están explicadas en el archivo. Las principales:

| Opción | Para qué |
|---|---|
| `AdbPath` | Ruta de `adb.exe` si no está en `platform-tools\` ni en el PATH. |
| `Serial` | Número de serie de la tablet (`adb devices`) si conectas más de un dispositivo. |
| `TetherMode` | Cómo se activa el anclaje USB (ver abajo). |
| `TetherLabels` | Nombre de la opción "Anclaje USB" en tu idioma, si no se detecta. |
| `SleepOnLock` / `RestartOnUnlock` | Comportamiento al bloquear y desbloquear la PC. |

### Modos de anclaje (`TetherMode`)
- **`Settings`** (por defecto, sin root): abre Ajustes → Anclaje a red, busca la opción de anclaje USB por su nombre y la enciende si está apagada. Incluye los nombres en español, inglés, portugués, francés y alemán. Si tu tablet usa otro, agrégalo en `TetherLabels`.
- **`Manual`**: el script no toca el anclaje; lo activas tú en la tablet cada vez que conectas el cable.
- **`Root`**: activa el anclaje con `service call connectivity`. Es más rápido y no abre Ajustes, pero los números de transacción **cambian según la versión de Android**. Configúralos en `RootSetUsbTetheringCode` y `RootTetherCode` **solo si sabes cuáles son para tu versión**: un número equivocado llama a otra función del sistema. Probado: LineageOS 14.1 (Android 7.1) = `33` y `20`.

## Probado en
- Samsung Galaxy Tab 3 10.1 (GT-P5210), LineageOS 14.1 (Android 7.1), spacedesk Viewer `ph.spacedesk.beta`, Windows 11, modo `Settings` y modo `Root`.

Otros equipos **no están probados**. Debería funcionar en Android 5 a 9. Android 10 o más nuevo aún no está probado.

## Reportar si funcionó o falló
Es una versión **beta**: tus pruebas ayudan a que funcione en más equipos. Abre un [issue](https://github.com/mioatx2-web/spacedesk-usb/issues) con:
1. Marca y modelo de tu tablet o teléfono.
2. Versión de Android.
3. Si funcionó, o en qué paso falló.
4. **Si falló, el archivo de log:** `%LOCALAPPDATA%\spacedesk-usb\spacedesk-usb.log`. Pega su contenido o adjúntalo; ahí se ve en qué paso se atoró.

Con esos reportes se hacen los ajustes para las siguientes versiones.

## Problemas comunes
- **No pasa nada al conectar:** revisa el log. Si dice que no encontró `adb.exe`, configura `AdbPath`. Si `adb devices` muestra `unauthorized`, acepta el aviso en la tablet.
- **"No encontré la opción de anclaje USB":** agrega el texto exacto de esa opción a `TetherLabels`, o usa `TetherMode = 'Manual'`.
- **La tablet se queda en su pantalla de bloqueo al desbloquear la PC:** pon el bloqueo de pantalla de la tablet en "Ninguno".
- **Se ve lento:** baja la calidad o los FPS en los ajustes de spacedesk Viewer.

## Licencia
[MIT](LICENSE). spacedesk es un producto de datronicsoft; este proyecto no está afiliado a ellos. spacedesk es gratis para uso personal; para uso comercial revisa [su licencia](https://www.spacedesk.net/licensing/).
