#!/bin/bash

###
# Theming and GNOME Options
###

#Better Font Smoothing
#gsettings set org.gnome.settings-daemon.plugins.xsettings antialiasing 'rgba'

#Usability Improvements
#gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'adaptive'
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
#gsettings set org.gnome.shell.overrides workspaces-only-on-primary false

#This indexer is nice, but can be detrimental for laptop users battery life
gsettings set org.freedesktop.Tracker.Miner.Files index-on-battery false
gsettings set org.freedesktop.Tracker.Miner.Files index-on-battery-first-time false
gsettings set org.freedesktop.Tracker.Miner.Files throttle 15

#Nautilus (File Manager) Usability
#gsettings set org.gnome.nautilus.icon-view default-zoom-level 'standard'
#gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'
#gsettings set org.gnome.nautilus.list-view use-tree-view true

#Touchpad tap to click
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

# Disable terminal bell
gsettings set org.gnome.desktop.wm.preferences audible-bell false

# Open gnome-terminal with Alt+Ctrl+T
#gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
#gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Open Terminal'
#gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-terminal'
#gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Alt><Primary>T'
