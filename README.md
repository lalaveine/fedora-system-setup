# Fedora Setup Script

Fork of the fedora-install script by tobias (https://git.furworks.de/tobias/fedora-install).

## Table of Contents

- [Hardware fixes](#hardware-fixes)
   * [Resolve firmware bug in Acer Nitro 5 AN515-42 BIOS](#resolve-firmware-bug-in-acer-nitro-5-AN515-42-BIOS)
   * [Get touchpad working](#get-touchpad-working)
   * [Fix strange wifi behavior](#fix-strange-wifi-behavior)
 - [Software configuration](#software-configuration)
   * [Instructions to enable DOH in Firefox](#instructions-to-enable-DOH-in-Firefox)
   * [Change DNS Server to Cloudflare](#Change-DNS-Server-to-cloudflare)
   * [Symlink home folder files to other location](#Symlink-home-folder-files-to-other-location)
   * [Install Microsoft Fonts](#Install-Microsoft-Fonts)
   * [Timeshift exclude config](#Timeshift-exclude-config)
   * [Run tmux when gnome-terminal starts](#Run-tmux-when-gnome-terminal-starts)

## Hardware fixes

### Resolve firmware bug in Acer Nitro 5 AN515-42 BIOS

After reading [this](https://ubuntuforums.org/showthread.php?t=2254677), I've added `ivrs_ioapic[4]=00:14.0 ivrs_ioapic[5]=00:00.1` to the `/etc/default/grub`

~~EDIT: This made core 6 to drown in hardware interrupts, so I figured it's better to disable apic altogether and added `noapic` to `/etc/default/grub`~~

EDIT: Everything works fine.

To update grub I use this command `sudo grub2-mkconfig -o "$(readlink -e /etc/grub2-efi.conf)"`

### Get touchpad working

Add to `/etc/default/grub` this `i8042.reset i8042.nomux i8042.nopnp i8042.noloop`

~~EDIT: kernel 5.4.8, everything works fine, but I'll leave it here just in case.~~

EDIT 2: It really doesn't.

### Fix strange wifi behavior 

Create file `/etc/NetworkManager/conf.d/wifi-powersave-off.conf` and put those line into it:

```
[connection]
# Values are 0 (use default), 1 (ignore/don't touch), 2 (disable) or 3 (enable).
wifi.powersave = 2
```

## Software configuration

### Instructions to enable DOH in Firefox

[There it is](https://support.mozilla.org/en-US/kb/firefox-dns-over-https).

### Change DNS Server to Cloudflare

To do that in GNOME:

1. Open Wi-Fi Settings

2. Open connection config window

3. Go to IPv4

4. Uncheck Automatic and put `1.1.1.1` in the bar

5. Click Apply

You can check if it's working in [here](https://www.cloudflare.com/ssl/encrypted-sni/)

### Symlink home folder files to other location

Command looks like this `ln -s /data/Desktop $HOME/Desktop`

### Install Microsoft Fonts

Instruction copied from [ArchWiki](https://wiki.archlinux.org/index.php/Microsoft_fonts).

* First download Windows ISO

* Next unpack it. (On Fedora you need packages `p7zip` and `p7zip-plugins`

```
$ 7z e -y Win10_1909_Russian_x64.iso sources/install.wim 
$ 7z e -y install.wim 1/Windows/{Fonts/"*".{ttf,ttc},System32/Licenses/neutral/"*"/"*"/license.rtf} -ofonts/
```

* After that move them to /usr/shared/fonts/WindowsFonts

```
# mv fonts/ /usr/share/fonts/WindowsFonts/
# chmod 755 /usr/share/fonts/WindowsFonts/
# chown root:root /usr/share/fonts/WindowsFonts/
# chmod 644 /usr/share/fonts/WindowsFonts/*
# chown root:root /usr/share/fonts/WindowsFonts/*
# fc-cache -f
```

### Timeshift exclude config

Make sure that file `/etc/timeshift.json` contains this.

```
"exclude" : [
    "/home/not_yet/**",
    "/var/spool/abrt/**",
    "/var/snap/**",
    "/var/lib/flatpak/**",
    "/var/lib/snapd/**",
    "/boot/efi/**",
    "/root/**"
  ]
```

### Run tmux when gnome-terminal starts

To do that you have to:

* Go to `Menu -> Preferences -> Profile -> Unnamed -> Command`.

* There tick the box `Run a custom command instead of my shell`.

* Put there this line `tmux new-session -A -s main`.

Credit where credit is due, I've a solution from [this answer](https://unix.stackexchange.com/a/176885). 
