# Fedora Setup Script

Script is inspired by the fedora-install script by tobias (https://git.furworks.de/tobias/fedora-install).

This script is designed for Fedora Silverblue 32.

## Fedora toolbox

To build custom image: 

```
podman build -t fedora-32-dev-toolbox:$(date +"%Y-%m-%dT%H%M%S") images/dev-f32
```

To create toolbox:

```
toolbox create --container fedora-32-dev-toolbox --image localhost/dev-f32:latest
```

## Install Microsoft Fonts

Instruction copied from [ArchWiki](https://wiki.archlinux.org/index.php/Microsoft_fonts).

* First download Windows ISO

* Next unpack it. (On Fedora you need packages `p7zip` and `p7zip-plugins`

```
$ 7z e -y Win10_1909_Russian_x64.iso sources/install.wim 
$ 7z e -y install.wim 1/Windows/{Fonts/"*".{ttf,ttc},System32/Licenses/neutral/"*"/"*"/license.rtf} -o ~/.local/share/fonts/WindowsFonts/
```

* After that run:

```
$ fc-cache ~/.local/share/fonts
```gsettings set org.gnome.Terminal.Legacy.Profile:/:0/ audible-bell false
