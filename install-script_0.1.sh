#!/bin/bash
##########################################################################################
# I N T R O D U C T I O N
#
# Arch Linux Installation Script for automate most of the Install Process.
# Read the Preparation in the Readme.md before!
#
# You need to customize various settings of the script (partitioning, locale, keyboard
# layout, hostname, installation packages, etc.) to suit your needs. Read the whole script
# and edit the settings before the installation! To avoid errors, all command blocks are
# commented out with ":<<COMMENT" at the beginning and "COMMENT" at the end. To enable
# the needed blocks, comment out the lines with an Hashtag.
##########################################################################################


##########################################################################################
# I N S T R U C T I O N
#
# 1. If you didn*t read the Readme.md, read it first!
# 2. Edit the variables for your system
# 3. Comment in/out, what you want to install. Details in the sections
#
# 4. Mount your target system at /mnt, e.g., mount /dev/sdX /mnt.
# 5. Copy this script to your target system (e.g., using wget).
# 6. Give execute permissions to the script: chmod +x install_script.sh
# 7. Run the script: ./install_script_0.1.sh
##########################################################################################


##########################################################################################
# S E T   V A R I A B L E S
# Hard Disk and Partitions
disk="/dev/sda" # The disk, you want to install Arch
part1=$disk"1"  # Partition 1, usually the boot partition
part2=$disk"2"  # Partition 2, usually the root partition
part3=$disk"3"  # Partition 3, usually the home partition, if you want to separate
part4=$disk"4"  # Partition 4, another partition, if you want to separate different parts
##########################################################################################


##########################################################################################
# P A R T I O N S   T H E   D I S K ( S )
# Partition the disk with gdisk and label partitions (customize to your needs)
# Multiple variations listed below. All variations without Swap-Partition.
##########################################################################################
# OPTION 1
# Delete existing partitions and create a new partition Table.
# ATTENTION: DATA LOSS! Existing data will be deleted!

:<<COMMENT
gdisk $disk <<EOF
o      # Create a new GPT partition table (and deleting existing one)
Y      # Confirm the operation
n      # Create a new partition (boot), use default start sector
+512M  # Size of the boot partition
EF00   # EF00 Hex code for EFI System Partition
c      # Set label for the boot partition
boot   # Label for the boot partition
n      # Create a new partition (root), use default start sector
       # Use the rest of the available space for the root partition
8300   # 8300 Hex code for Linux filesystem
c      # Set label for the root partition
root   # Label for the root partition
w      # Write changes to disk
Y      # Confirm the operation
EOF
COMMENT
##########################################################################################

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
