# spacedesk-usb: usa una tablet Android como monitor extra con spacedesk por cable USB,
# sin tocar la tablet. Corre en Windows, escondido, y por ADB:
#   - al conectar el cable: activa el anclaje USB, abre spacedesk y se conecta;
#   - si spacedesk pierde la conexión con el cable puesto, lo reinicia;
#   - al bloquear la PC apaga la pantalla de la tablet; al desbloquear la enciende y
#     reinicia spacedesk (la sesión vieja queda lenta).
# Configuración: config.psd1 junto a este archivo (copiar de config.example.psd1).
# Log: %LOCALAPPDATA%\spacedesk-usb\spacedesk-usb.log
# Ver README.md.

$ErrorActionPreference = 'Continue'

# ---------- Configuración ----------
$Defaults = @{
    AdbPath          = ''            # vacío = buscar adb.exe en el PATH o junto al script
    Serial           = ''            # vacío = el primer dispositivo que vea ADB
    Package          = ''            # vacío = detectar el paquete de spacedesk instalado
    TetherMode       = 'Settings'    # Settings (sin root) | Root | Manual
    TetherLabels     = @('USB tethering', 'Anclaje a red USB', 'Anclaje de USB', 'Anclaje USB',
                         'Compartir conexi.n por USB', 'Compartir Internet por USB', 'Ancoragem USB',
                         'Ancoragem via USB', 'Partage de connexion via USB', 'Partage de connexion par USB',
                         'USB-Tethering', 'Tethering USB', 'Router USB')
    RootSetUsbTetheringCode = 0      # solo TetherMode = Root (ver README)
    RootTetherCode          = 0      # solo TetherMode = Root (ver README)
    SpacedeskPort    = 28252         # puerto del servicio spacedesk en la PC
    SleepOnLock      = $true         # apagar la pantalla de la tablet al bloquear la PC
    RestartOnUnlock  = $true         # reiniciar spacedesk al desbloquear
    KeepScreenOn     = $true         # stay_on_while_plugged_in = 3 al conectar
}

$Config = $Defaults.Clone()
$ConfigFile = Join-Path $PSScriptRoot 'config.psd1'
if (Test-Path $ConfigFile) {
    $user = Import-PowerShellDataFile $ConfigFile
    foreach ($k in $user.Keys) { $Config[$k] = $user[$k] }
}

$DataDir = Join-Path $env:LOCALAPPDATA 'spacedesk-usb'
$Log     = Join-Path $DataDir 'spacedesk-usb.log'
$Pause   = Join-Path $DataDir 'pausa'   # si existe, no se vigila la conexión (p. ej. para usar MTP)
New-Item -ItemType Directory -Force $DataDir | Out-Null

function Write-Log($msg) {
    $line = '{0:yyyy-MM-dd HH:mm:ss}  {1}' -f (Get-Date), $msg
    Add-Content -Path $Log -Value $line -Encoding utf8
    $all = Get-Content $Log -ErrorAction SilentlyContinue
    if ($all.Count -gt 600) { $all | Select-Object -Last 500 | Set-Content $Log -Encoding utf8 }
}

# ---------- ADB ----------
$Adb = $Config.AdbPath
if (-not $Adb) {
    $local = Join-Path $PSScriptRoot 'platform-tools\adb.exe'
    if (Test-Path $local) { $Adb = $local }
    else { $cmd = Get-Command adb.exe -ErrorAction SilentlyContinue; if ($cmd) { $Adb = $cmd.Source } }
}
if (-not $Adb -or -not (Test-Path $Adb)) {
    Write-Log 'ERROR: no se encontró adb.exe. Configura AdbPath en config.psd1 (ver README).'
    exit 1
}

$Serial = $Config.Serial

function Get-Devices {
    # Serial de los dispositivos listos ("device", no "unauthorized"/"offline").
    @(& $Adb devices 2>$null | Where-Object { $_ -match '^(\S+)\s+device$' } | ForEach-Object { ($_ -split '\s+')[0] })
}

$script:Ignored = @{}   # dispositivos sin spacedesk ya revisados (p. ej. un celular para pasar fotos)

function Test-Present {
    if ($Serial) { return ((Get-Devices) -contains $Serial) }
    # Sin Serial configurado: usar solo un dispositivo que tenga spacedesk instalado.
    # Los demás (un celular conectado para pasar fotos, etc.) no se tocan.
    foreach ($d in @(Get-Devices)) {
        if ($script:Ignored.ContainsKey($d)) { continue }
        $pk = (& $Adb -s $d shell 'pm list packages spacedesk' 2>$null) -join ''
        if ($pk -match 'package:') { $script:Serial = $d; return $true }
        $script:Ignored[$d] = $true
        Write-Log "Dispositivo $d sin spacedesk: se ignora."
    }
    return $false
}

function Invoke-Adb([string[]]$a) {
    $out = & $Adb -s $Serial @a 2>$null
    return ($out -join "`n")
}

function Invoke-Shell([string]$cmd) { Invoke-Adb @('shell', $cmd) }

function Wait-Device([int]$Seconds = 25) {
    # Al cambiar el USB a anclaje, Windows vuelve a enumerar el dispositivo y a veces el
    # servidor ADB lo pierde: en ese caso se reinicia el servidor.
    for ($try = 1; $try -le 2; $try++) {
        for ($i = 0; $i -lt $Seconds; $i++) {
            if (Test-Present) { return $true }
            Start-Sleep 1
        }
        Write-Log 'ADB no ve la tablet; reiniciando el servidor ADB.'
        & $Adb kill-server 2>$null | Out-Null
        Start-Sleep 2
        & $Adb start-server 2>$null | Out-Null
    }
    return (Test-Present)
}

function Test-AdbInterfacePlugged {
    # ¿Windows ve una interfaz ADB conectada (aunque el servidor ADB no la vea)?
    [bool](Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue |
        Where-Object { $_.FriendlyName -match 'ADB' -and $_.Status -eq 'OK' })
}

# ---------- spacedesk en la tablet ----------
$Pkg = $Config.Package
function Resolve-Package {
    if ($script:Pkg) { return $true }
    $p = (Invoke-Shell 'pm list packages spacedesk') -split "`n" |
        Where-Object { $_ -match '^package:' } | ForEach-Object { $_.Substring(8).Trim() } | Select-Object -First 1
    if ($p) { $script:Pkg = $p; Write-Log "Paquete de spacedesk: $p"; return $true }
    Write-Log 'ERROR: spacedesk no está instalado en la tablet.'
    return $false
}

function Get-UiNodes {
    # Lee la pantalla actual con uiautomator (no necesita root).
    Invoke-Shell 'uiautomator dump /sdcard/spacedesk-usb-ui.xml' | Out-Null
    $xml = Invoke-Shell 'cat /sdcard/spacedesk-usb-ui.xml'
    Invoke-Shell 'rm /sdcard/spacedesk-usb-ui.xml' | Out-Null
    foreach ($m in [regex]::Matches($xml, '<node [^>]*>')) {
        $n = $m.Value
        $get = { param($attr) if ($n -match " $attr=""([^""]*)""") { $Matches[1] } else { '' } }
        $b = & $get 'bounds'
        if ($b -notmatch '\[(\d+),(\d+)\]\[(\d+),(\d+)\]') { continue }
        [pscustomobject]@{
            Text    = [System.Net.WebUtility]::HtmlDecode((& $get 'text'))
            Class   = & $get 'class'
            Checked = (& $get 'checked') -eq 'true'
            X1 = [int]$Matches[1]; Y1 = [int]$Matches[2]; X2 = [int]$Matches[3]; Y2 = [int]$Matches[4]
        }
    }
}

function Invoke-TapNode($node) {
    $x = [int](($node.X1 + $node.X2) / 2); $y = [int](($node.Y1 + $node.Y2) / 2)
    Invoke-Shell "input tap $x $y" | Out-Null
}

# ---------- Anclaje USB ----------
function Get-TabletIp {
    # IP de la tablet en la interfaz del anclaje USB (rndis0, usb0, ncm0...).
    $lines = (Invoke-Shell 'ip -4 -o addr') -split "`n"
    foreach ($l in $lines) {
        if ($l -match '\d+:\s+(rndis\d*|usb\d*|ncm\d*)\s+inet\s+(\d+\.\d+\.\d+\.\d+)') { return $Matches[2] }
    }
    return $null
}

function Test-Tethered { [bool](Get-TabletIp) }

function Enable-TetherSettings {
    # Sin root: abre Ajustes > Anclaje y toca el interruptor de "Anclaje USB" si está apagado.
    Invoke-Shell 'input keyevent 224' | Out-Null
    $r = Invoke-Shell 'am start -n com.android.settings/.TetherSettings'
    if ($r -match 'Error') { Invoke-Shell 'am start -n com.android.settings/.Settings\$TetherSettingsActivity' | Out-Null }
    Start-Sleep 3
    $nodes = @(Get-UiNodes)
    $pattern = '^(' + (($Config.TetherLabels | ForEach-Object { $_ }) -join '|') + ')$'
    $title = $nodes | Where-Object { $_.Text -match $pattern } | Select-Object -First 1
    if (-not $title) {
        Write-Log 'ERROR: no encontré la opción de anclaje USB en Ajustes. Agrega su nombre exacto a TetherLabels en config.psd1.'
        return
    }
    # Interruptor en la misma fila que el título.
    $mid = ($title.Y1 + $title.Y2) / 2
    $switch = $nodes | Where-Object { $_.Class -match 'Switch|CheckBox' -and $_.Y1 -le $mid + 30 -and $_.Y2 -ge $mid - 30 } | Select-Object -First 1
    if ($switch -and $switch.Checked) { return }   # ya está encendido
    Invoke-TapNode $(if ($switch) { $switch } else { $title })
    Start-Sleep 4
    Wait-Device | Out-Null
    Start-Sleep 2
    Invoke-Shell 'input keyevent 3' | Out-Null   # volver al inicio
}

function Enable-TetherRoot {
    # Con root: llama directo a IConnectivityManager. Los números cambian según la versión de
    # Android; hay que configurarlos (ver README). Primera llamada: USB a rndis; segunda: anclaje.
    $set = [int]$Config.RootSetUsbTetheringCode; $tether = [int]$Config.RootTetherCode
    if ($set -le 0) { Write-Log 'ERROR: TetherMode = Root sin RootSetUsbTetheringCode en config.psd1.'; return }
    if ($tether -gt 0 -and (Invoke-Shell 'getprop sys.usb.config') -match 'rndis') {
        Invoke-Shell "su -c 'service call connectivity $tether s16 rndis0'" | Out-Null
        Start-Sleep 3
        if (Test-Tethered) { return }
    }
    Invoke-Shell "su -c 'service call connectivity $set i32 1'" | Out-Null
    Start-Sleep 4
    Wait-Device | Out-Null
    Start-Sleep 3
}

function Enable-Tethering {
    for ($i = 1; $i -le 4; $i++) {
        if (Test-Tethered) { return $true }
        switch ($Config.TetherMode) {
            'Root'     { Enable-TetherRoot }
            'Manual'   { if ($i -eq 1) { Write-Log 'Esperando a que actives el anclaje USB en la tablet.' }; Start-Sleep 10 }
            default    { Enable-TetherSettings }
        }
    }
    return (Test-Tethered)
}

# ---------- Conexión de spacedesk ----------
function Test-SpacedeskConnected {
    # Conexión real: TCP establecida del servicio spacedesk de la PC con la IP de la tablet.
    # Ver la pantalla de video de spacedesk no basta: al quitar el cable se queda parpadeando
    # con la sesión vieja.
    if (-not $script:TabletIp) { return $false }
    [bool](Get-NetTCPConnection -LocalPort $Config.SpacedeskPort -State Established -ErrorAction SilentlyContinue |
        Where-Object { $_.RemoteAddress -eq $script:TabletIp })
}

function Wait-SpacedeskConnected([int]$Seconds) {
    for ($i = 0; $i -lt $Seconds; $i += 2) {
        Start-Sleep 2
        if (Test-SpacedeskConnected) { return $true }
    }
    return $false
}

function Test-Locked {
    # Con la PC bloqueada corre LogonUI.exe (pantalla de bloqueo de Windows).
    [bool](Get-Process LogonUI -ErrorAction SilentlyContinue)
}

function Start-Spacedesk([switch]$Restart) {
    # -Restart: cerrar y abrir spacedesk aunque siga conectado (sesión limpia).
    $script:TabletIp = Get-TabletIp
    Invoke-Shell 'input keyevent 224' | Out-Null   # despertar pantalla
    if (-not $Restart -and (Wait-SpacedeskConnected 6)) { return $true }
    Invoke-Shell "am force-stop $Pkg" | Out-Null
    # Esperar a que la PC suelte la conexión vieja (si no, se confunde con la nueva).
    for ($i = 0; $i -lt 10 -and (Test-SpacedeskConnected); $i++) { Start-Sleep 1 }
    Invoke-Shell "monkey -p $Pkg -c android.intent.category.LAUNCHER 1" | Out-Null
    # Con la conexión automática de spacedesk activada, se conecta sola.
    if (Wait-SpacedeskConnected 20) { return $true }
    # Si no, tocar la conexión a esta PC en la lista de spacedesk.
    $nodes = @(Get-UiNodes)
    $target = $nodes | Where-Object { $_.Text -match '^(Connection|Conexi.n)\s*:' } | Select-Object -First 1
    if (-not $target) { $target = $nodes | Where-Object { $_.Text -match [regex]::Escape($env:COMPUTERNAME) } | Select-Object -First 1 }
    if ($target) { Invoke-TapNode $target }
    return (Wait-SpacedeskConnected 16)
}

function Connect-All([switch]$Restart) {
    if (-not (Enable-Tethering)) { Write-Log 'ERROR: no se pudo activar el anclaje USB.'; return $false }
    if (Start-Spacedesk -Restart:$Restart) { return $true }
    Write-Log 'ERROR: spacedesk no se conectó.'
    return $false
}

# ---------- Ciclo principal ----------
Write-Log "Iniciado (ADB: $Adb, anclaje: $($Config.TetherMode))."
& $Adb start-server 2>$null | Out-Null

while ($true) {
    while (-not (Test-Present)) {
        Start-Sleep 5
        # Windows ve una interfaz ADB pero el servidor no lista nada (ni "unauthorized"): reiniciarlo.
        $listed = @(& $Adb devices 2>$null | Where-Object { $_ -match '^\S+\s+\S+$' -and $_ -notmatch '^List' })
        if ($listed.Count -eq 0 -and (Test-AdbInterfacePlugged)) { Wait-Device 15 | Out-Null }
    }
    Write-Log "Tablet conectada ($Serial)."

    # Si la tablet se acaba de encender, esperar a que termine de arrancar (máx. 3 min).
    for ($i = 0; $i -lt 36; $i++) {
        if ((Invoke-Shell 'getprop sys.boot_completed').Trim() -eq '1') { break }
        Start-Sleep 5
    }
    Start-Sleep 5

    if (Resolve-Package) {
        if ($Config.KeepScreenOn) { Invoke-Shell 'settings put global stay_on_while_plugged_in 3' | Out-Null }
        for ($intento = 1; $intento -le 3; $intento++) {
            if (Connect-All) { Write-Log 'spacedesk conectado.'; break }
            Start-Sleep 15
            Wait-Device | Out-Null
        }
    }

    # Vigilar mientras siga conectada (cada 5 s).
    $noConn = 0; $locked = $false
    while (Test-Present) {
        Start-Sleep 5
        if ((Test-Path $Pause) -or -not $Pkg) { $noConn = 0; continue }
        $lock = Test-Locked
        if ($lock -and -not $locked) {
            $locked = $true
            if ($Config.SleepOnLock) {
                Write-Log 'PC bloqueada: apagando la pantalla de la tablet.'
                Invoke-Shell 'input keyevent 223' | Out-Null   # KEYCODE_SLEEP
            }
            continue
        }
        if ($lock) { continue }
        if ($locked) {
            $locked = $false; $noConn = 0
            Write-Log 'PC desbloqueada.'
            Invoke-Shell 'input keyevent 224' | Out-Null   # KEYCODE_WAKEUP
            Start-Sleep 1
            Invoke-Shell 'input keyevent 82' | Out-Null    # quita el bloqueo de deslizar, si hay
            if ($Config.RestartOnUnlock -or -not (Test-SpacedeskConnected)) {
                if (Connect-All -Restart:$Config.RestartOnUnlock) { Write-Log 'spacedesk conectado.' }
            }
            continue
        }
        if (Test-SpacedeskConnected) { $noConn = 0; continue }
        $noConn++
        if ($noConn -lt 6) { continue }   # ~30 s sin conexión
        Write-Log 'spacedesk perdió la conexión; reconectando.'
        if (Connect-All) { Write-Log 'spacedesk reconectado.'; $noConn = 0 }
        else { Write-Log 'Se reintenta en ~1 min.'; $noConn = -6 }
    }
    Write-Log 'Tablet desconectada.'
    $script:TabletIp = $null
    if (-not $Config.Serial) { $Serial = ''; $script:Ignored = @{} }
    Start-Sleep 2
}
