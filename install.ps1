# Instala spacedesk-usb como tarea programada: arranca escondido al iniciar sesión.
# No necesita permisos de administrador.
# Installs spacedesk-usb as a scheduled task that starts hidden at logon. No admin needed.
# Uso / Usage:  powershell -ExecutionPolicy Bypass -File .\install.ps1 [-NoStart]
param([switch]$NoStart)

$TaskName = 'spacedesk-usb'
$Script   = Join-Path $PSScriptRoot 'spacedesk-usb.ps1'
if (-not (Test-Path $Script)) { Write-Error "No se encontró $Script"; exit 1 }

$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
# conhost --headless evita que se vea la ventana de PowerShell (Windows 10 21H2+ / Windows 11).
$psArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Script`""
$action = if ([Environment]::OSVersion.Version.Build -ge 19044) {
    New-ScheduledTaskAction -Execute 'conhost.exe' -Argument "--headless powershell.exe $psArgs"
} else {
    New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $psArgs
}
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $user
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew `
    -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal `
    -Settings $settings -Description 'Tablet Android como monitor con spacedesk por USB (spacedesk-usb).' -Force | Out-Null
Write-Host "Tarea '$TaskName' instalada para $user."

if (-not $NoStart) {
    Start-ScheduledTask -TaskName $TaskName
    Write-Host 'Iniciada. Log: %LOCALAPPDATA%\spacedesk-usb\spacedesk-usb.log'
}
