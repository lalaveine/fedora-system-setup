# Fedora Setup Script

Fork of the fedora-install script by tobias (https://git.furworks.de/tobias/fedora-install).

### Post-install:

- Firefox 

To enable DNS over HTTPS and Encrypted SNI in `about.config` change

```
network.trr.mode 0 -> 2
network.security.esni.enabled false -> true
```

### Optional

#### You can change DNS Server to cloudflare. To do that in GNOME:

1. Open Wi-Fi Settings

2. Open connection config window

3. Go to IPv4

4. Uncheck Automatic and put `1.1.1.1` in the bar

5. Click Apply

You can check if it's working in [here](https://www.cloudflare.com/ssl/encrypted-sni/)

#### There seems to be a firmware bug in Acer Nitro 5 AN515-42

To stop soft lockups of cpu I added `ivrs_ioapic[4]=00:14.0 ivrs_ioapic[5]=00:00.2` before `quiet` to `/etc/default/grub`

To update grub I use this command `sudo grub2-mkconfig -o "$(readlink -e /etc/grub2-efi.conf)"`

#### You can symlink home folder files to other location

Command looks like this `ln -s /data/Desktop $HOME/Desktop`
