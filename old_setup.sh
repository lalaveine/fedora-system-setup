#!/bin/bash

# Interrupt handler
trap '{ echo "Hey, you pressed Ctrl-C.  Time to quit." ; kill "$infiloop"; exit 1; }' INT

if [ $(id -u) = 0 ]; then
   echo 'This script changes your users gsettings and should thus not be run as root!'
   echo 'You need to enter your password only one time'
   exit 1
fi


while test $# -gt 0
do
    case '$1' in
	--virtual-machine) 
		echo 'Hardware specific settings will be exluded.'
		VM=true
            ;;
	--help) 
		echo -e "Options:  
	--virtual-machine - Exclude any hardware specific settings and packages."
		exit 0
            ;;
    esac
    shift
done


###
# Make infinite loop for sudo, so I don't have to enter password again
###
sudo echo "Enter the password to start the script!"
while :; do sudo -v; sleep 1; done &
infiloop=$!

###
# DNF
###

# Clean all dnf temporary files
sudo dnf clean all


# Add RPM-Fusion FREE repo
#sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 

# Enable OpenH264 from Cisco
#sudo dnf config-manager --set-enabled fedora-cisco-openh264

# Add official Docker repo
#sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

# Add mesa repo from gloriouseggroll
#sudo dnf config-manager --add-repo configs/etc/yum/mesa-aco.repo

# Add VS Code repo
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

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
tmux `#Terminal multiplexer` \
lm_sensors `#Show your systems Temparature` \
pv `#pipe viewer - see what happens between the | with output | pv | receiver ` \
tuned `#Tuned can optimize your performance according to metrics. tuned-adm profile powersave can help you on laptops, alot` \
#unar `#free rar decompression` \
#w3m `#the best browser` \
#p7zip `#Very high compression ratio file archiver` \
#p7zip-plugins `#Additional plugins for p7zip` \
#moreutils `#A Collection Of More Useful Unix Utilities`
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

#sudo dnf install \
#-y \
#exfat-utils `#Allows managing exfat (android sd cards and co)` \
#ffmpeg `#Adds Codec Support to Firefox, and in general` \
#fuse-exfat `#Allows mounting exfat` \
#fuse-sshfs `#Allows mounting servers via sshfs` \
#gvfs-fuse `#gnome<>fuse` \
#gvfs-mtp `#gnome<>android` \
#gvfs-nfs `#gnome<>ntfs` \
#gvfs-smb `#gnome<>samba` \
#dnf-plugins-core `#Provides the commands to manage your DNF repositories from the command line.` \
#xorg-x11-drv-amdgpu `#AMDGPU driver for X11` 

# Install OpenH264 from Cisco

#sudo dnf install \
#-y \
#gstreamer1-plugin-openh264 \
#gstreamer1-vaapi

###
# Install themes 
###

#sudo dnf install \
#-y \
#arc-theme `#A more comfortable GTK/Gnome-Shell Theme` \
#papirus-icon-theme `#A quite nice icon theme` 

###
# Install fonts 
###

#sudo dnf install \
#-y \
#'mozilla-fira-*' `#A nice font family` \
#adobe-source-code-pro-fonts `#The most beautiful monospace font around`

###
# Install plugins 
###

#sudo dnf install \
#-y \
#`# NetworkManager`\
#NetworkManager-openvpn-gnome `#To enforce that its possible to import .ovpn files in the settings` \
#`# Nautilus` \
#nautilus-extensions `#What it says on the tin` \
#file-roller-nautilus `#More Archives supported in nautilus` 


###
# GNOME Extentions 
###
#sudo dnf install \
#-y \
#gnome-shell-extension-dash-to-dock `#dash for gnome` \
#gnome-shell-extension-user-theme `#Enables theming the gnome shell` \
#gnome-shell-extension-drive-menu `#Enables nice menu with incerted drives`

# Download script to install extension from extensions.gnome.org
#wget -O gnome-shell-extension-installer "https://github.com/brunelli/gnome-shell-extension-installer/raw/master/gnome-shell-extension-installer"
#chmod 755 gnome-shell-extension-installer
#sudo cp gnome-shell-extension-installer /usr/bin/
#rm gnome-shell-extension-installer

# LockKeys extension - Num/Caps indicators on the top bar
#gnome-shell-extension-installer 36


###
# Virtualization 
###

sudo dnf install \
-y \
virt-manager `#A gui to manage virtual machines` \
libvirt \
libguestfs-tools `#Resize Vm Images and convert them` \
#docker-ce

###
# Useful applications 
###
 
sudo dnf install \
-y \
gnome-tweak-tool `#Your central place to make gnome like you want` \
dconf-editor `#GUI GSettings editor` \
#timeshift `#Backup tool` \
#cockpit `#Web-based monitoring tool`


###
# Flatpak
###

# Configure flathub
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install flatpaks

flatpak install -y --user flathub \
	org.telegram.desktop `#Pavel Durov's messenger` \
	com.valvesoftware.Steam 

flatpak update --user

#flatpak override --env=FLATPAK_GL_DRIVERS=mesa-git --user

flatpak override --user --device=all com.valvesoftware.Steam

###
# System configuration
###

# only run this commands on real hardware
#if [ -z "$VM" ]; then
	# Force X11 to use AMDGPU driver
#	sudo cp configs/etc/X11/20-amdgpu.conf /etc/X11/xorg.conf.d/

	# Disable wifi powersafe
#	sudo cp configs/etc/NetworkManager/wifi-powersave-off.conf /etc/NetworkManager/conf.d/

	# Edit grub options
#	sudo cp /etc/default/grub /etc/default/grub.backup
#	sudo sed -i 's/\<quiet\>/& i8042.reset i8042.nomux i8042.nopnp i8042.noloop ivrs_ioapic[4]=00:14.0 ivrs_ioapic[5]=00:00.1/' /etc/default/grub
#	sudo grub2-mkconfig -o "$(readlink -e /etc/grub2-efi.conf)"
#fi

# Choose tuned-adm profile
if [ -z "$VM" ]; then
	sudo tuned-adm profile desktop
fi

if [ ! -z "$VM" ]; then
	sudo tuned-adm profile virtual-guest
fi

# Detect hardware sensors
#sudo sensors-detect --auto


###
# Enable services
### 

# Enable tuned-adm
#sudo systemctl enable --now tuned

# Enable system monitoring tool
#sudo systemctl enable --now cockpit.socket

# Virtual Machines
#sudo systemctl enable --now libvirtd

# Set default firewall zone to drop
#sudo firewall-cmd --set-default-zone=drop

# Disable CUPS
#sudo systemctl disable cups

###
# Symlink home folder to hard drive
###

# Allow write to /data/ for everyone
#sudo chmod 777 /data/

#bash scripts/syslink-home-folder.sh

###
# User configuration
###

# Configure GNOME
#bash scripts/gnome-config.sh

# Firefox
#bash -c 'cat > $HOME/.mozilla/firefox/$(ls $HOME/.mozilla/firefox/ | grep default-release)/user.js << EOL
#user_pref("browser.startup.homepage", "about:home");
#EOL'

# Vim-like navigation in bash
#if !(grep -q "set -o vi" "$HOME/.bashrc"); then
#	echo "set -o vi" >> $HOME/.bashrc
#fi

# Copy tmux config file
#cp configs/user/.tmux.conf $HOME/

# Configure git
#git config --global user.name "Evgenii Matveev"
#git config --global user.email "mfb.eugene@gmail.com"
#git config --global core.autocrlf input

# Kill infinite sudo loop
kill "$infiloop"

#The user needs to reboot to apply all changes.
echo 'Please Reboot' && exit 0

