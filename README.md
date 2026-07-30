# OneOS - ComputerCraft OS [Fixed for 1.21.1 Java]

> A fixed and working fork of OneOS for CC:Tweaked 1.21.1 (NeoForge / Fabric / Forge) - Java Edition

OneOS is the most famous all-in-one operating system for ComputerCraft. Desktop, file browser, App Store, Sketch, games, multitasking and much more. The original version from 2014 is incompatible with modern versions, this fork fixes everything.

**Original repo:** [oeed/OneOS](https://github.com/oeed/OneOS)

---

### Features

- Desktop with icons and wallpapers
- File Browser with custom icons
- App Store
- Sketch (Photoshop-style image editor)
- AirDrop for file transfer between computers
- Tabbed multitasking
- Games, LuaIDE, calculator
- Auto-update, one-click .zip packages
- Animations and sounds

### Requirements

- Minecraft Java 1.20 / 1.21 / 1.21.1
- CC:Tweaked (NeoForge / Forge / Fabric)
- Normal or Advanced Computer

### Installation (30 seconds)

On your ComputerCraft computer, type:

```lua
https://raw.githubusercontent.com/smazzara0000-hue/OneOS/main/install.lua
```
To install OneOS, open an Advanced Computer (or a CraftOS terminal) in Minecraft and enter the following command:

```lua
wget run https://raw.githubusercontent.com/smazzara0000-hue/OneOS/main/install.lua
```

The computer will automatically reboot into OneOS.

> If you are coming from the beta with `loop in gettable`, run `rm -r System` first and then run the command again.

### Fixes in this fork

- Fixed `http.get` with 2 parameters (incompatible with CC:Tweaked 1.106+)
- Fixed `No .version file` - installer now correctly downloads `System/.version`
- Stable pre-Bedrock version 1.1.1 (no `loop in gettable` on Bedrock.lua)
- Installer rewritten for GitHub API

### FAQ

**Why `loop in gettable`?**
You were using the 1.2 beta. This repo uses the 1.1.1 stable version which doesn't have that bug.

**Why `No .version file`?**
The old installer skipped dotfiles. Now it's fixed.

**How to uninstall?**
Hold CTRL+R on boot or run `rm startup` and `reboot`.

### Credits

- Original OS created by **oeed**
- Fix and porting for 1.21.1 Java by **smazzara0000-hue**

---
Made for CC:Tweaked
