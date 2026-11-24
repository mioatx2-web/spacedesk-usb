# spacedesk-usb

[Español](README.md)

Use an Android tablet as an extra Windows monitor with [spacedesk](https://www.spacedesk.net/) **over a USB cable**, without touching the tablet. A PowerShell script runs hidden on the PC and, through ADB:

- **When the cable is plugged in:** turns on USB tethering, opens spacedesk and connects.
- **If spacedesk loses the connection** while the cable is still plugged in, it closes and reopens it.
- **When the PC is locked (Win+L):** turns the tablet screen off. **When unlocked:** turns it back on and restarts spacedesk.

### Why
- spacedesk over USB works through Android **USB tethering**, which turns off every time the cable is unplugged.
- After unplugging and replugging, spacedesk stays on its video screen, blinking, and never reconnects. You have to close it by hand.
- After the tablet screen goes off and on, the session stays connected but becomes **very slow**. On the tablet this was built on, it sent 0.1 MB/s instead of 4–7 MB/s. Restarting spacedesk fixes it.

## Requirements
- Windows 10 or 11 with the **spacedesk driver** installed.
- Android tablet or phone with **spacedesk Viewer** installed.
- **ADB** (Android SDK Platform-Tools), official from Google: <https://developer.android.com/tools/releases/platform-tools>
- On the tablet: **Developer options → USB debugging** turned on, and this PC authorized ("Always allow").
- **No root** and no Windows admin rights needed.

## Install
1. Download this repository (**Code → Download ZIP**) and extract it to a permanent folder, e.g. `C:\spacedesk-usb`.
2. Extract Platform-Tools inside that folder so that you have `C:\spacedesk-usb\platform-tools\adb.exe`. If you already have ADB somewhere else, see [Configuration](#configuration).
3. Plug in the tablet and accept the USB debugging prompt ("Always allow from this computer").
4. In **spacedesk Viewer** on the tablet, turn on automatic connection to your PC if your version has it. If it doesn't, the script taps the connection in the list.
5. Recommended: on the tablet, **Settings → Security → Screen lock → None**. That way the tablet doesn't stay on its lock screen when you unlock the PC.
6. Open PowerShell in the folder and run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1
   ```
   This creates the **spacedesk-usb** scheduled task, which runs at logon, and starts it right away.

To remove it:
```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

## Usage
- Plug in the tablet: the desktop shows up within 15 to 70 seconds. The first time takes longer because it turns on tethering.
- Log: `%LOCALAPPDATA%\spacedesk-usb\spacedesk-usb.log`
- **Pause:** while the file `%LOCALAPPDATA%\spacedesk-usb\pausa` exists, the script doesn't watch the connection. Use it, for example, to close spacedesk and transfer files over MTP, because spacedesk and MTP don't work together. Delete it to resume.

## Configuration
Copy `config.example.psd1` to `config.psd1` and change only what you need. Every option is explained in the file. The main ones:

| Option | What for |
|---|---|
| `AdbPath` | Path to `adb.exe` if it's not in `platform-tools\` or on PATH. |
| `Serial` | Tablet serial number (`adb devices`) if you connect more than one device. |
| `TetherMode` | How USB tethering is turned on (see below). |
| `TetherLabels` | Name of the "USB tethering" option in your language, if it isn't found. |
| `SleepOnLock` / `RestartOnUnlock` | What happens when the PC is locked and unlocked. |

### Tethering modes (`TetherMode`)
- **`Settings`** (default, no root): opens Settings → Tethering, finds the USB tethering option by name and turns it on if it's off. Includes names in Spanish, English, Portuguese, French and German. If your tablet uses another one, add it to `TetherLabels`.
- **`Manual`**: the script doesn't touch tethering; you turn it on yourself on the tablet each time you plug in the cable.
- **`Root`**: turns tethering on with `service call connectivity`. It's faster and doesn't open Settings, but the transaction numbers **change between Android versions**. Set `RootSetUsbTetheringCode` and `RootTetherCode` **only if you know the right ones for your version**: a wrong number calls a different system function. Tested: LineageOS 14.1 (Android 7.1) = `33` and `20`.

## Tested on
- Samsung Galaxy Tab 3 10.1 (GT-P5210), LineageOS 14.1 (Android 7.1), spacedesk Viewer `ph.spacedesk.beta`, Windows 11, `Settings` and `Root` modes.

Other devices are **untested**. If you try it on another one, please open an issue with the model, Android version and result.

## Troubleshooting
- **Nothing happens when plugging in:** check the log. If it says `adb.exe` wasn't found, set `AdbPath`. If `adb devices` shows `unauthorized`, accept the prompt on the tablet.
- **"Couldn't find the USB tethering option":** add the exact text of that option to `TetherLabels`, or use `TetherMode = 'Manual'`.
- **The tablet stays on its lock screen when the PC is unlocked:** set the tablet's screen lock to "None".
- **It feels slow:** lower the quality or FPS in spacedesk Viewer's settings.

## License
[MIT](LICENSE). spacedesk is a product of datronicsoft; this project is not affiliated with them.
