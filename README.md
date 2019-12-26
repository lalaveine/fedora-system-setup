# Fedora Setup Script

Fork of the fedora-install script by tobias (https://git.furworks.de/tobias/fedora-install).

### Post-install:

- Firefox 

~~To enable DNS over HTTPS and Encrypted SNI in `about.config` change~~

```
network.trr.mode 0 -> 2
network.security.esni.enabled false -> true
```

Seems like it's not needed anymore. Here is the [instruction](https://support.mozilla.org/en-US/kb/firefox-dns-over-https).

### Optional

#### You can change DNS Server to cloudflare. To do that in GNOME:

1. Open Wi-Fi Settings

2. Open connection config window

3. Go to IPv4

4. Uncheck Automatic and put `1.1.1.1` in the bar

5. Click Apply

You can check if it's working in [here](https://www.cloudflare.com/ssl/encrypted-sni/)

#### There seems to be a firmware bug in Acer Nitro 5 AN515-42

After reading [this](https://ubuntuforums.org/showthread.php?t=2254677), I've added `ivrs_ioapic[4]=00:14.0 ivrs_ioapic[5]=00:00.1` to the `/etc/default/grub`

~~EDIT: This made core 6 to drown in hardware interrupts, so I figured it's better to disable apic altogether and added `noapic` to `/etc/default/grub`~~

Everything works fine

To update grub I use this command `sudo grub2-mkconfig -o "$(readlink -e /etc/grub2-efi.conf)"`

#### You can symlink home folder files to other location

Command looks like this `ln -s /data/Desktop $HOME/Desktop`

#### To get touchpad working on fedora 30

Add to `/etc/default/grub` this `i8042.reset i8042.nomux i8042.nopnp i8042.noloop`

#### Wifi sometimes stops working, this should fix it
Create file `/etc/NetworkManager/conf.d/wifi-powersave-off.conf` and put those line into it:

```
[connection]
# Values are 0 (use default), 1 (ignore/don't touch), 2 (disable) or 3 (enable).
wifi.powersave = 2
```

#### Install Microsoft Fonts

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

#### Timeshift exclude config

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

#### Run tmux when gnome-terminal starts

To do that you have to:

* Go to `Menu -> Preferences -> Profile -> Unnamed -> Command`.

* There tick the box `Run a custom command instead of my shell`.

* Put there this line `tmux new-session -A -s main`.

Credit where credit is due, I've a solution from [this answer](https://unix.stackexchange.com/a/176885). 