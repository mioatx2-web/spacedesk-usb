# Copia este archivo como config.psd1 (en la misma carpeta) y cambia solo lo que necesites.
# Lo que no aparezca en config.psd1 usa el valor por defecto.
# Copy this file to config.psd1 (same folder) and change only what you need.
@{
    # Ruta de adb.exe. Vacío = busca platform-tools\adb.exe junto al script o adb.exe en el PATH.
    # Path to adb.exe. Empty = platform-tools\adb.exe next to the script, or adb.exe on PATH.
    AdbPath = ''

    # Número de serie de la tablet (adb devices). Vacío = el primer dispositivo con spacedesk instalado
    # (los demás, como un celular conectado para pasar fotos, se ignoran).
    # Tablet serial (adb devices). Empty = first device with spacedesk installed (others are ignored).
    Serial = ''

    # Paquete de spacedesk. Vacío = se detecta solo (ph.spacedesk.beta, etc.).
    # spacedesk package. Empty = auto-detect.
    Package = ''

    # Cómo activar el anclaje USB / How to turn on USB tethering:
    #   'Settings' = sin root: abre Ajustes y toca "Anclaje USB" / no root: opens Settings and taps it
    #   'Root'     = con root, por service call (requiere los códigos de abajo) / root, needs codes below
    #   'Manual'   = lo activas tú en la tablet / you turn it on yourself
    TetherMode = 'Settings'

    # Si en tu idioma la opción se llama distinto, agrega su texto exacto (es una expresión regular).
    # If the option has another name in your language, add its exact text (regular expression).
    # TetherLabels = @('USB tethering', 'Anclaje a red USB')

    # Solo para TetherMode = 'Root'. Números de transacción de IConnectivityManager para tu versión
    # de Android (ver README). Probado: LineageOS 14.1 (Android 7.1) = 33 y 20.
    # Only for TetherMode = 'Root'. Transaction codes for your Android version (see README).
    RootSetUsbTetheringCode = 0
    RootTetherCode          = 0

    # Apagar la pantalla de la tablet al bloquear la PC (Win+L).
    # Turn the tablet screen off when the PC is locked.
    SleepOnLock = $true

    # Reiniciar spacedesk al desbloquear (la sesión que sobrevive al bloqueo queda lenta).
    # Restart spacedesk on unlock (the session that survives the lock becomes slow).
    RestartOnUnlock = $true

    # Mantener la pantalla encendida mientras está conectada (stay_on_while_plugged_in).
    # Keep the screen on while plugged in.
    KeepScreenOn = $true
}
