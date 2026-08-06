<div align="center">

<a href="https://github.com/JDKamalakar/DMS-Niri_Display_Settings">
    <img src="https://raw.githubusercontent.com/google/material-design-icons/master/png/hardware/computer/materialicons/48dp/1x/baseline_computer_white_48dp.png" alt="Niri Display Settings logo" title="Niri Display Settings logo" width="80"/>
</a>

# [DMS-Niri_Display_Settings](#)

### Advanced Display & Output Management for Niri Wayland Compositor

Quickly toggle, manage, and configure display outputs, profiles, and arrangements directly in the Dank Material Shell for Niri.

[![DMS Compatible](https://img.shields.io/badge/DMS-Compatible-purple.svg?labelColor=27303D)](https://github.com/Dank-Material-Shell)
[![License](https://img.shields.io/badge/License-DMS-blue.svg?labelColor=27303D&color=0877d2)](https://github.com/DankMaterialShell)
[![Maintenance Status](https://img.shields.io/badge/Status-Maintained-green.svg?labelColor=27303D&color=946300)](https://github.com/JDKamalakar/DMS-Niri_Display_Settings/graphs/commit-activity)

## Requirements

<div align="left">

- **Dank Material Shell (DMS)** environment installed and active (`>= 1.5`).
- **Niri Wayland Compositor** running as your desktop window manager.
- `wl-mirror` utility for display mirroring features.

</div>

## Download

[![DMS Plugin Gallery](https://img.shields.io/badge/DMS-Plugin%20Gallery-06599d?style=flat-square&logo=linux&logoColor=white)](https://danklinux.com/plugins)

```bash
# Install via DMS CLI
dms plugins install niriDSA
```

## Features

<div align="left">

- **Display Profiles**: Quick profile switching for *Internal Only*, *External Only*, *Extend*, and *Mirror*.
- **Hotplug Management**: Auto-show settings modal or auto-apply profiles when external monitors are connected or disconnected.
- **Laptop Screen Protection**: Automatically enables laptop display when external screens are unplugged.
- **Material UI Aesthetics**: Seamless glassmorphic modal and control center widget tailored for Dank Material Shell.
- **IPC Remote Control**: Full IPC support to bind keys directly in `niri` config.

</div>

## Interface

<div align="center">
  <img src="screenshot.png" width="80%" alt="Niri Display Settings Interface" />
</div>

## Keybindings & IPC

<div align="left">

Use `dms ipc call niriDSA <command>` to control display profiles and modals directly.

| Command | Description |
|---|---|
| `open` | Open the display settings modal |
| `close` | Close the display settings modal |
| `toggle` | Toggle the display settings modal |
| `apply <profile>` | Apply a profile: `internal_only`, `external_only`, `extend`, `mirror` |

### Niri Keybinding Example (`config.kdl`)

```kdl
binds {
    Mod+P { spawn "dms" "ipc" "call" "niriDSA" "toggle"; }
}
```

</div>

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Before reporting a new issue, take a look at the [changelog](https://github.com/JDKamalakar/DMS-Niri_Display_Settings/releases) and the already opened [issues](https://github.com/JDKamalakar/DMS-Niri_Display_Settings/issues).

### Credits

Built with ❤️ for the [Dank Material Shell](https://github.com/DankMaterialShell) community.

<a href="https://github.com/JDKamalakar/DMS-Niri_Display_Settings/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=JDKamalakar/DMS-Niri_Display_Settings" alt="Niri Display Settings contributors" title="Niri Display Settings contributors" width="100"/>
</a>

### Disclaimer

This plugin is part of the Dank Material Shell suite for display management in Niri.

### 📜 License

Part of DankMaterialShell. Check the main repository for license information.

</div>