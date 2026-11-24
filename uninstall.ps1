# Quita la tarea programada de spacedesk-usb y detiene el script.
# Removes the spacedesk-usb scheduled task and stops the script.
# Uso / Usage:  powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
$TaskName = 'spacedesk-usb'

if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "Tarea '$TaskName' eliminada."
} else {
    Write-Host "La tarea '$TaskName' no estaba instalada."
}

# Detener el script si sigue corriendo.
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" |
    Where-Object { $_.CommandLine -match 'spacedesk-usb\.ps1' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -Confirm:$false }

Write-Host 'El log queda en %LOCALAPPDATA%\spacedesk-usb (puedes borrarlo).'
