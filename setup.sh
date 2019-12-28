#!/bin/bash

# Interrupt handler
trap '{ echo "Hey, you pressed Ctrl-C.  Time to quit." ; kill "$infiloop"; exit 1; }' INT

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
# Make infinite loop for sudo, so I don't have to enter password again
###
sudo echo "Starting the script"
while :; do sudo -v; sleep 1; done &
infiloop=$!


###
# Symlink home folder to hard drive
###

home_folders=("Desktop" "Documents" "Downloads" "Music" "Pictures" "Public" "Templates" "Videos")

# Change owner of /data
sudo chown $USER:$USER /data

# Remove folders from the home folder
for folder_name in ${home_folders[@]}; do
        rmdir $HOME/$folder_name
done

# Create folders in the data folder
for folder_name in ${home_folders[@]}; do
        mkdir /data/$folder_name
done

# Create system links from new location to the home folder
for folder_name in ${home_folders[@]}; do
        ln -s /data/$folder_name $HOME/$folder_name
done


###
# System configuration
###


# Firefox
bash -c 'cat > $HOME/.mozilla/firefox/$(ls $HOME/.mozilla/firefox/ | grep default-release)/user.js << EOL
user_pref("browser.startup.homepage", "about:home");
EOL'

# Vim-like navigation in bash
if !(grep -q "set -o vi" "$HOME/.bashrc"); then
	echo "set -o vi" >> $HOME/.bashrc
fi

# and tmux
bash -c 'cat > $HOME/.tmux.conf << EOL
set-window-option -g mode-keys vi
EOL'

# Force X11 to use AMDGPU driver
sudo bash -c 'cat > /etc/X11/xorg.conf.d/20-amdgpu.conf << EOL
Section "Device"
        Identifier "card0"
        Driver "amdgpu"
        Option "TearFree" "true"
EndSection
EOL'

# Disable wifi powersafe
sudo bash -c 'cat > /etc/NetworkManager/conf.d/wifi-powersave-off.conf << EOL
[connection]
wifi.powersave = 2
EOL'

# Restart network services
sudo systemctl restart NetworkManager

# Wait till the system reconnects to the internet (hopefully)
sleep 180

# Enable touchpad
sudo sed -i 's/\<quiet\>/& i8042.reset i8042.nomux i8042.nopnp i8042.noloop/' /etc/default/grub
sudo grub2-mkconfig -o "$(readlink -e /etc/grub2-efi.conf)"


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
w3m `#the best browser` \
p7zip `#Very high compression ratio file archiver` \
p7zip-plugins `#Additional plugins for p7zip`
# iotop  `#disk usage cli monitor` \
# nload `#Network Load Monitor` \
# ncdu `#Directory listing CLI tool. For a gui version take a look at "baobab"` \
# fortune-mod `#Inspiring Quotes` \
# meld `#Quick Diff Tool` \
# borgbackup `#If you need backups, this is your tool for it` \
# nethogs `#Whats using all your traffic? Now you know!` \
# wavemon `#a cli wifi status tool` \
# youtube-dl `#Allows you to download and save youtube videos but also to open their links by dragging them into mpv!` \


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
xorg-x11-drv-amdgpu `#AMDGPU driver for X11` 

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
`# Nautilus` \
nautilus-extensions `#What it says on the tin` \
nautilus-image-converter \
nautilus-search-tool \
file-roller-nautilus `#More Archives supported in nautilus` \
gtkhash-nautilus `#To get a file hash via gui` 


###
# GNOME Extentions 
###
sudo dnf install \
-y \
gnome-shell-extension-dash-to-dock `#dash for gnome` \
gnome-shell-extension-user-theme `#Enables theming the gnome shell` \
gnome-shell-extension-drive-menu `#Enables nice menu with incerted drives`

# Download script to install extension from extensions.gnome.org
wget -c --tries=0 --read-timeout=20 https://raw.githubusercontent.com/brunelli/gnome-shell-extension-installer/master/gnome-shell-extension-installer -P /tmp
chmod 744 /tmp/gnome-shell-extension-installer

# LockKeys extension - Num/Caps indicators on the top bar
/tmp/gnome-shell-extension-installer 36
/tmp/gnome-shell-extension-installer 906

# Remove script
rm /tmp/gnome-shell-extension-installer
 
###
# Virtualization 
###

sudo dnf install \
-y \
virt-manager `#A gui to manage virtual machines` \
libvirt \
libguestfs-tools `#Resize Vm Images and convert them` 

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
transmission `#Torrent client` \
dconf-editor `#GUI GSettings editor` \
timeshift `#Backup tool` \
cellloid `#So far the best video player`
# spamassassin `#Dep to make sure it is locally installed for Evolution` \

###
# Snap
###
sudo dnf install snapd
sudo systemctl enable snapd
sudo systemctl start snapd

sudo ln -s /var/lib/snapd/snap /snap

sudo snap install snap-store


###
# Flatpak
###

# Configure flathub
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install flatpaks
if [ -z "$FLATPACK" ]; then
	flatpak install -y flathub \
	org.telegram.desktop `#Pavel Durov's messenger` \
fi


###
# Enable some of the goodies, but not all
# Its the users responsibility to choose and enable zsh, with oh-my-zsh for example
# or set a more specific tuned profile
###

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
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.shell.extensions.user-theme name 'Arc-Dark-solid'

#Set SCP as Monospace (Code) Font
gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro Semi-Bold 12'

#Set Extensions for gnome
gsettings set org.gnome.shell enabled-extensions "['user-theme@gnome-shell-extensions.gcampax.github.com', 'TopIcons@phocean.net', 'dash-to-dock@micxgx.gmail.com', 'drive-menu@gnome-shell-extensions.gcampax.github.com', 'lockkeys@vaina.lt','sound-output-device-chooser@kgshank.net']"

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

# Open gnome-terminal with Alt+Ctrl+T
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Open Terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Alt><Primary>T'

# Start tmux session when gnome-terminal is opened (all terminals will be attached to one session)
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')/ use-custom-command true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')/ custom-command 'tmux new-session -A -s main'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')/ exit-action 'close'

# Configure git
git config --global user.name "Evgeniy Matveev"
git config --global user.email "mfb.eugene@gmail.com"
git config --global core.autocrlf input

# Kill infinite sudo loop
kill "$infiloop"

#The user needs to reboot to apply all changes.
echo "Please Reboot" && exit 0
