# Installation Script for Arch Linux
*This repository contains different Installation Scripts to install Arch Linux.*

Before run the Scripts you need to prepare the installation. At first, you need do download the Arch Linux ISO from [Arch Linux](https://archlinux.org/download/)
Create a bootable device (for example with [Ventoy](https://www.ventoy.net/en/index.html)) (memory stick) with the ISO and boot the computer from the stick. The following preparations are inherited from the 
[Arch Wiki Installation Guide](https://wiki.archlinux.org/title/installation_guide) and were slightly edited.

## Set the console keyboard layout and font to your liking with the following commands
The default [console keymap](https://wiki.archlinux.org/title/Linux_console/Keyboard_configuration) is US. To set the keyboard layout, for example, to German, 
you can set it with [loadkeys](https://man.archlinux.org/man/loadkeys.1). Use the following command:
```
loadkeys de-latin1
```

> [!IMPORTANT]
> You need to press `z` for the `y` and `ß` for the `-`

> [!NOTE]
> If you dont now the keymap name, you can search with `localectl list-keymaps`

Console fonts are located in `/usr/share/kbd/consolefonts/` an can be set with [setfonts](https://man.archlinux.org/man/setfont.8), ommitting the path and
file extension. For example, to use one of the largest fonts suitable for [HiDPI screens](https://wiki.archlinux.org/title/HiDPI), run:
```
setfont ter-132b
```

## Verify boot mode
To verify the boot mode, check the UEFI bitness:
```
cat /sys/firmware/efi/fw_platform_size
```

If the command returns `64`, then system is booted in UEFI mode 64-bit. If the command returns `32`, then system is booted in UEFI mode 32-bit (only systemd-boot als bootloader possible).
If the file does not exist, the system may be booted in BIOS (or CSM) mode.

## Check internet connection
The internet connection with cable should be working out of the box. For Wi-Fi, use the [iwctl](https://wiki.archlinux.org/title/Iwd#iwctl) command to establish a connection.
After that, check the connection with
```
ping archlinux.org
```

## Install `git` and download the repo
```
pacman -Sy
pacman -S git
git XXX
```

## Run the script
....
