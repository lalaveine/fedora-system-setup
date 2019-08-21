#!/bin/bash

# Interrupt handler
trap '{ echo "Hey, you pressed Ctrl-C.  Time to quit." ; exit 1; }' INT

if [ $(id -u) = 0 ]; then
   echo "This script changes your users gsettings and should thus not be run as root!"
   echo "You may need to enter your password multiple times!"
   exit 1
fi


while test $# -gt 0
do
    case "$1" in
        --nonfree) 
		echo "Nonfree Additions will be added"
		NONFREE=true
            ;;
	--no-flatpack) 
		echo "Flatpacks will not be installed"
		FLATPACK=false
            ;;
	--help) 
		echo -e "Options:  
	--nonfree - Install non-free version of RMPFusion repo
	--no-flatpack - Flatpacks installation will be skiped"
		exit 0
            ;;
    esac
    shift
done


###
# Optionally clean all dnf temporary files
###

sudo dnf clean all

###
# RpmFusion Free Repo
# This is holding only open source, vetted applications - fedora just cant legally distribute them themselves thanks to 
# Software patents
###

sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 


###
# RpmFusion NonFree Repo
# This includes Nvidia Drivers and more
###

if [ ! -z "$NONFREE" ]; then
	sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
fi


###
# Force update the whole system to the latest and greatest
###

sudo dnf upgrade --allowerasing --refresh -y
# And also remove any packages without a source backing them
# If you come from the Fedora 31 Future i'll check if this is still optimal before F31 comes out.
sudo dnf distro-sync -y


###
# Install CLI tools 
###

sudo dnf install \
-y \
vim `#The best text editor` \
htop `#A more visual top` \
tmux `#Terminal multiplexer` \
lm_sensors `#Show your systems Temparature` \
pv `#pipe viewer - see what happens between the | with output | pv | receiver ` \
tuned `#Tuned can optimize your performance according to metrics. tuned-adm profile powersave can help you on laptops, alot` \
unar `#free rar decompression` \
wavemon `#a cli wifi status tool` \
youtube-dl `#Allows you to download and save youtube videos but also to open their links by dragging them into mpv!` \
borgbackup `#If you need backups, this is your tool for it` \
iotop  `#disk usage cli monitor` \
nload `#Network Load Monitor` \
# ncdu `#Directory listing CLI tool. For a gui version take a look at "baobab"` \
# fortune-mod `#Inspiring Quotes` \
# meld `#Quick Diff Tool` \
# nethogs `#Whats using all your traffic? Now you know!` \


###
# Install system utils 
###

sudo dnf install \
-y \
exfat-utils `#Allows managing exfat (android sd cards and co)` \
ffmpeg `#Adds Codec Support to Firefox, and in general` \
fuse-exfat `#Allows mounting exfat` \
fuse-sshfs `#Allows mounting servers via sshfs` \
gvfs-fuse `#gnome<>fuse` \
gvfs-mtp `#gnome<>android` \
gvfs-nfs `#gnome<>ntfs` \
gvfs-smb `#gnome<>samba` \
dnf-plugins-core `#Provides the commands to manage your DNF repositories from the command line.` \
xorg-x11-drv-amdgpu `#AMDGPU driver for X11` \

# Install OpenH264 from Cisco
sudo dnf config-manager --set-enabled fedora-cisco-openh264
sudo dnf install \
-y \
gstreamer1-plugin-openh264 \
mozilla-openh264 \
libva-vdpau-driver \
libvdpau-va-gl \
gstreamer1-vaapi \
libva-utils

###
# Install themes 
###

sudo dnf install \
-y \
arc-theme `#A more comfortable GTK/Gnome-Shell Theme` \
breeze-cursor-theme `#A more comfortable Cursor Theme from KDE` \
papirus-icon-theme `#A quite nice icon theme` 


###
# Install fonts 
###

sudo dnf install \
-y \
'mozilla-fira-*' `#A nice font family` \
adobe-source-code-pro-fonts `#The most beautiful monospace font around`

###
# Install plugins 
###

sudo dnf install \
-y \
`# NetworkManager`\
NetworkManager-openvpn-gnome `#To enforce that its possible to import .ovpn files in the settings` \
`# Evolution` \
evolution-spamassassin `#Helps you deal with spam in Evolution` \
`# Nautilus` \
nautilus-extensions `#What it says on the tin` \
nautilus-image-converter \
nautilus-search-tool \
file-roller-nautilus `#More Archives supported in nautilus` \
gtkhash-nautilus `#To get a file hash via gui` \


###
# GNOME Extentions 
###
sudo dnf install \
-y \
gnome-shell-extension-dash-to-dock `#dash for gnome` \
gnome-shell-extension-topicons-plus `#Notification Icons for gnome` \
gnome-shell-extension-user-theme `#Enables theming the gnome shell`


###
# Virtualization 
###

sudo dnf install \
-y \
virt-manager `#A gui to manage virtual machines` \
libvirt \
libguestfs-tools `#Resize Vm Images and convert them` \

# Docker
# Add repo
sudo dnf config-manager \
--add-repo \
https://download.docker.com/linux/fedora/docker-ce.repo
# Install docker
sudo dnf -y install docker-ce

###
# Useful applications 
###
 
sudo dnf install \
-y \
calibre `#Ebook management` \
git `#VCS done right` \
gnome-tweak-tool `#Your central place to make gnome like you want` \
spamassassin `#Dep to make sure it is locally installed for Evolution` \
transmission `#Torrent client` \
dconf-editor `#GUI GSettings editor` \
cherrytree `#Note taking app`

# Install Bitwarden (wget will try infinitely)
wget -c --tries=0 --read-timeout=20 https://github.com/bitwarden/desktop/releases/download/v1.15.2/Bitwarden-1.15.2-x86_64.rpm -P /tmp
sudo dnf install -y /tmp/Bitwarden-1.15.2-x86_64.rpm
rm /tmp/Bitwarden-1.15.2-x86_64.rpm


###
# Flatpak
###

# Configure flathub
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install flatpaks
if [ -z "$FLATPAK" ]; then
	flatpak install -y flathub \
	org.libreoffice.LibreOffice `#Open-source office suite` \
	org.telegram.desktop `#Pavel Durov's messenger` \
	org.videolan.VLC \
	tv.kodi.Kodi
fi



###
# Remove useless stuff
###

sudo dnf -y remove \
fedora-chromium-config `#I guess there is some obscure dependency that pulled this from repos"`


###
# Enable some of the goodies, but not all
# Its the users responsibility to choose and enable zsh, with oh-my-zsh for example
# or set a more specific tuned profile
###

# Vim-like navigation in bash and tmux
if !(grep -q "set -o vi" "$HOME/.bashrc"); then
	echo "set -o vi" >> $HOME/.bashrc
fi

# Configure sensors (defaults)
sudo sensors-detect --auto

# Configure powermode
sudo systemctl enable --now tuned
sudo tuned-adm profile balanced

#Performance:
#sudo tuned-adm profile desktop

#Virtual Machine Host:
#sudo tuned-adm profile virtual-host

#Virtual Machine Guest:
#sudo tuned-adm profile virtual-guest

#Battery Saving:
#sudo tuned-adm profile powersave

# Virtual Machines
sudo systemctl enable --now libvirtd

# Set default firewall zone to drop
sudo firewall-cmd --set-default-zone=drop

###
# Theming and GNOME Options
###

#Gnome Shell Theming
gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Breeze_Snow'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.shell.extensions.user-theme name 'Arc-Dark-solid'

#Set SCP as Monospace (Code) Font
gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro Semi-Bold 12'

#Set Extensions for gnome
gsettings set org.gnome.shell enabled-extensions "['user-theme@gnome-shell-extensions.gcampax.github.com', 'TopIcons@phocean.net', 'dash-to-dock@micxgx.gmail.com']"

#Better Font Smoothing
gsettings set org.gnome.settings-daemon.plugins.xsettings antialiasing 'rgba'

#Usability Improvements
gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'adaptive'
gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true
gsettings set org.gnome.desktop.calendar show-weekdate true
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.shell.overrides workspaces-only-on-primary false

#Dash to Dock Theme
gsettings set org.gnome.shell.extensions.dash-to-dock apply-custom-theme false
gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color false
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-customize-running-dots true
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-color '#729fcf'
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
gsettings set org.gnome.shell.extensions.dash-to-dock force-straight-corner false
gsettings set org.gnome.shell.extensions.dash-to-dock icon-size-fixed true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode 'ALL_WINDOWS'
gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces true
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items false
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'SEGMENTED'
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.70000000000000000

#This indexer is nice, but can be detrimental for laptop users battery life
gsettings set org.freedesktop.Tracker.Miner.Files index-on-battery false
gsettings set org.freedesktop.Tracker.Miner.Files index-on-battery-first-time false
gsettings set org.freedesktop.Tracker.Miner.Files throttle 15

#Nautilus (File Manager) Usability
gsettings set org.gnome.nautilus.icon-view default-zoom-level 'standard'
gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'
gsettings set org.gtk.Settings.FileChooser sort-directories-first true
gsettings set org.gnome.nautilus.list-view use-tree-view true

#Touchpad tap to click
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

# Configure git
git config --global user.name "Evgeniy Matveev"
git config --global user.email "mfb.eugene@gmail.com"
git config --global core.autocrlf input

#The user needs to reboot to apply all changes.
echo "Please Reboot" && exit 0
