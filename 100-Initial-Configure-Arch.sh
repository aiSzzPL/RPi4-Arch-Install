#!/bin/bash

########################################################################
# Author	:	John Morris
# Website	:	https://github.com/jtmorris
# Source	:	https://github.com/jtmorris/RPi4-Arch-Install
# Requires:
#	- Arch Raspberry Pi with an untarnished install.
# Preparation:
# Running Instructions:
#		- Run this script from the Arch install as root user.
########################################################################

# If not root, die
if ((${EUID:-0} || "$(id -u)"))
then # Not root user
	echo "[ERR] You must execute this command with root privileges."
	exit 1
fi

# Init pacman
echo "[INFO] Initializing 'pacman' keyring and populating ARM keys."
pacman-key --init
pacman-key --populate archlinuxarm

# Set timezone
echo "[INFO] Setting timezone to 'America/Los_Angeles'."
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc

# Localization
echo "[INFO] Setting localiztion to 'en_US.UTF-8'"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
touch /etc/locale.conf
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Update
echo "[INFO] Updating Arch install."
pacman -Syuu --noconfirm

# Rename the default user
echo "[INFO] Renaming default user from 'alarm' to 'john'"
pkill -9 -u alarm
usermod -l john alarm
usermod -d /home/alarm -m john
usermod -u 2000 john
groupmod -n john alarm
id john

# Set passwords
echo
echo "Change the root password:"
passwd
echo; echo;
echo "Change the default user (john) password:"
passwd john

# Install sudo
echo "[INFO] Installing 'sudo'"
pacman -S --noconfirm --needed sudo

# Add 'john' to wheel
echo "[INFO] Giving 'john' sudo rights."
gpasswd -a john wheel

echo "[INFO] Switching to 'john' and asking for 'sudo' rights."
su john
cd ~
echo; echo;
echo "Please retype your password to give script sudo permissions."
sudo pwd

# Install AUR helper 'trizen'
echo "[INFO] Installing 'git'."
sudo pacman -S --noconfirm --needed git
echo "[INFO] Install 'trizen' AUR helper."
git clone http://aur.archlinux.org/trizen.git
cd trizen
sudo makepkg -si --noconfirm
cd ..
rm -rf trizen

# Install some basic important packages
# powerpill for parallel package downloading
echo "[INFO] Installing 'powerpill'"
git clone https://aur.archlinux.org/powerpill.git
cd powerpill
sudo makepkg -si --noconfirm
cd ..
rm -rf powerpill

# network-manager for wifi
echo "[INFO] Installing 'networkmanager'"
sudo powerpill -S networkmanager --noconfirm