#!/bin/bash

# Arch Linux Installation Script
# This script automates the installation of Arch Linux.
# Please make sure to customize the settings at the beginning of the script
# (partitioning, locale, keyboard layout, hostname, etc.) to suit your needs.

# How to run this script:
# 1. Boot your computer from a bootable Arch Linux installation medium.
# 2. Ensure an internet connection is available (e.g., Ethernet).
# 3. Set the keyboard layout to de-latin1 (loadkeys de-latin1)
# 4. Mount your target system at /mnt, e.g., mount /dev/sdX /mnt.
# 5. Copy this script to your target system (e.g., using wget).
# 6. Give execute permissions to the script: chmod +x install_script.sh
# 7. Run the script: ./install_script_0.1.sh

# Partition the disk with gdisk and label partitions (customize to your needs)
# !!! Delete Existing partition table !!! Set an BTRFS Partition Layout !!!
gdisk /dev/sda <<EOF
o     # Create a new GPT partition table
Y     # Confirm the operation
n     # Create a new partition (boot), use default start sector
+512M # Size of the boot partition
EF00  # EF00 Hex code for EFI System Partition
c     # Set label for the boot partition
boot  # Label for the boot partition
n     # Create a new partition (root), use default start sector
      # Use the rest of the available space for the root partition
8300  # 8300 Hex code for Linux filesystem
c     # Set label for the root partition
root  # Label for the root partition
w     # Write changes to disk
Y     # Confirm the operation
EOF

# Format the boot partition with FAT32 and label
mkfs.fat -F32 -n boot /dev/sda1

# Format the root partition with ext4 and label
mkfs.ext4 -L root /dev/sda2

# Mount the root partition using its label
mount -L root /mnt

# Create the boot directory and mount the boot partition using its label
mkdir /mnt/boot
mount -L boot /mnt/boot

# Install Arch Linux with additional packages (linux, linux-firmware, networkmanager, vim)
pacstrap /mnt base base-devel linux linux-firmware linux-headers networkmanager vim

# Generate the fstab file with UUIDs
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system
arch-chroot /mnt

# Set the system timezone
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc

# Set localization (German and English)
echo "de_DE.UTF-8 UTF-8" > /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=de_DE.UTF-8" > /etc/locale.conf

# Set the keyboard layout to de-latin1
echo "KEYMAP=de-latin1" > /etc/vconsole.conf

# Set the hostname
echo "vmarch" > /etc/hostname

# Edit the hosts file
echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    vmarch.localdomain vmarch" >> /etc/hosts

# Set the root user password
passwd

# Install and configure GRUB
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg

# Install additional packages
pacman -S acpid avahi bash-completion bluez bluez-utils cifs-utils cups curl dosfstools fuse2fs git hplip network-manager-applet nfs-utils ntfs-3g reflector samba wget zsh

# Enable services
systemctl enable acpid
systemctl enable avahi-daemon
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable NetworkManager
systemctl enable reflector.timer

# Logout from chroot and reboot the system
exit
umount -R /mnt
reboot
