#!/bin/bash

###
# Symlink home folder to hard drive
###

home_folders=("Desktop" "Documents" "Downloads" "Music" "Pictures" "Public" "Templates" "Videos")

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

