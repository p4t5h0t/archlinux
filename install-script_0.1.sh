#!/bin/bash
###########################################################################################
# I N T R O D U C T I O N
#
# Arch Linux Installation Script for automate most of the Install Process.
# Read the Preparation in the Readme.md before!
#
# You need to customize various settings of the script (partitioning, locale, keyboard
# layout, hostname, installation packages, etc.) to suit your needs. Read the whole script
# and edit the settings before the installation! To avoid errors, all command blocks in
# sections with multiple options are commented out with ":<<COMMENT" at the beginning and
# "COMMENT" at the end. To enable the needed blocks, comment out the lines with an Hashtag.
###########################################################################################


###########################################################################################
# I N S T R U C T I O N
#
# 1. If you didn*t read the Readme.md, read it first!
# 2. Read the script and customize the variables in the sections.
# 3. Comment in/out, what you want to install. Details in the sections.
#
# 4. Mount your target system at /mnt, e.g., mount /dev/sdX /mnt.
# 5. Copy this script to your target system (e.g., using wget).
# 6. Give execute permissions to the script: chmod +x install_script.sh
# 7. Run the script: ./install_script_0.1.sh
###########################################################################################


###########################################################################################
# P A R T I O N S   T H E   D I S K ( S )
# Partition the disk with gdisk and label partitions (customize to your needs). If you
# have a existing partition table with partitions what you don't want to delete and only
# reinstall the system on an existing partition, skip this part.
#
# Delete existing partitions and create a new partition Table. Two options listed below.
# ATTENTION: DATA LOSS! Existing data will be deleted!
###########################################################################################
# Variables
disk="/dev/sda" # The disk, you want to install Arch
part1=$disk"1"  # Partition 1, usually the boot partition
part2=$disk"2"  # Partition 2, usually the root partition
part3=$disk"3"  # Partition 3, usually the home partition, if you want to separate
part4=$disk"4"  # Partition 4, another partition, if you want to separate different parts
###########################################################################################
# Variation with ONE partition for the whole system (no separate home partition)
:<<COMMENT
gdisk $disk <<EOF
o      # Create a new GPT partition table (and deleting existing one)
Y      # Confirm the operation
n      # Create a new partition (boot), use default start sector
       # Default partition number

       # Default start sector
+1024M  # Size of the boot partition
EF00   # EF00 Hex code for EFI System Partition
c      # Set label for the boot partition
boot   # Label for the boot partition
n      # Create a new partition (root), use default start sector
       # Default partition number
       
       # Default start sector
       # Use the rest of the available space for the root partition
8300   # 8300 Hex code for Linux filesystem
c      # Set label for the root partition
root   # Label for the root partition
w      # Write changes to disk
Y      # Confirm the operation
EOF
COMMENT
###########################################################################################
# Variation with TWO partitions (root and home partition). Set the partition size for
# your needs.
:<<COMMENT
gdisk $disk <<EOF
o      # Create a new GPT partition table (and deleting existing one)
Y      # Confirm the operation
n      # Create a new partition (boot), use default start sector
+1024M  # Size of the boot partition
EF00   # EF00 Hex code for EFI System Partition
c      # Set label for the boot partition
boot   # Label for the boot partition
n      # Create a new partition (root), use default start sector
+20G   # Set the size for your needs
8300   # 8300 Hex code for Linux filesystem
c      # Set label for the root partition
root   # Label for the root partition
n      # Create a new partition (home), use default start sector
       # Use the rest of the available space for the home partition or set a size
8300   # 8300 Hex code for Linux filesystem
c      # Set label for the home partition
home   # Label for the home partition
w      # Write changes to disk
Y      # Confirm the operation
EOF
COMMENT
###########################################################################################


###########################################################################################
# F O R M A T   A N D   M O U N T   T H E   D I S K
# Format the partitions, mount and create the needed folders. Three options listed below.
###########################################################################################
# One partition (root) formatted with BTRFS.
:<<COMMENT
# Format the boot partition with FAT32 and label
mkfs.fat -F32 -n boot $part1

# Format the root partition with btrfs and label
mkfs.btrfs -L root $part2

# Mount the root partition using its label and create the subvolumes
mount -L root /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@spool
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@srv
btrfs subvolume create /mnt/@snapshots

# Unmount the root partition and mount it with the correct settings
umount /mnt
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@ $part2 /mnt

# Create the folders for the subvolumes and mount them
mkdir -p /mnt/{home,root,var/cache,var/log,var/spool,tmp,srv,snapshots}
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@home $part2 /mnt/home
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@root $part2 /mnt/root
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@cache $part2 /mnt/var/cache
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@log $part2 /mnt/var/log
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@spool $part2 /mnt/var/spool
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@tmp $part2 /mnt/tmp
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@srv $part2 /mnt/srv
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@snapshots $part2 /mnt/snapshots

# Create the boot directory and mount the boot partition using its label
mkdir -p /mnt/boot
mount -L boot /mnt/boot
COMMENT
###########################################################################################
# One partition (root) formatted with EXT4.
:<<COMMENT
# Format the boot partition with FAT32 and label
mkfs.fat -F32 -n boot $part1

# Format the root partition with ext4 and label
mkfs.ext4 -L root $part2

# Mount the root partition using its label
mount -L root /mnt

# Create the boot directory and mount the boot partition using its label
mkdir -p /mnt/boot
mount -L boot /mnt/boot
COMMENT
###########################################################################################
# Two partitions (root and home) formatted with EXT4.
:<<COMMENT
# Format the boot partition with FAT32 and label
mkfs.fat -F32 -n boot $part1

# Format the root partition with ext4 and label
mkfs.ext4 -L root $part2

# Format the home partition with ext4 and label
mkfs.ext4 -L home $part3

# Mount the root partition using its label
mount -L root /mnt

# Create the boot directory and mount the boot partition using its label
mkdir -p /mnt/boot
mount -L boot /mnt/boot

# Create the home directory and mount the home partition using its label
mkdir -p /mnt/home
mount -L home /mnt/home
COMMENT
###########################################################################################


###########################################################################################
# B A S I C   I N S T A L L A T I O N
# Basic installation process of Arch Linux
###########################################################################################
# Package Variables
base_pkgs="base base-devel"
kernel_pkgs="linux-zen linux-zen-headers linux-lts linux-lts-headers linux-firmware"
network_pkgs="networkmanager"
utilities_pkgs="vim"
bootmgr_pkgs="grub efibootmgr"
de_pkgs=""

# Configuration Variables
hostname="arch"
domain="pat-web.de"
###########################################################################################
# Basic Arch Linux Installation with - in my opinion - the basic needed packages. That
# contains the base and kernel packages, network packages and utilitiy packages like an
# texteditor. The packages are defined in the variables above.
pacstrap /mnt \
$base_pkgs \
$kernel_pkgs \ 
$network_pkgs \
$utilities_pkgs

:<< COMMENT
# Generate the fstab file with Labels
genfstab -L /mnt >> /mnt/etc/fstab

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
echo $hostname > /etc/hostname

# Edit the hosts file
echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    $hostname.$domain $hostname" >> /etc/hosts

# Set the root user password
passwd

# Install and configure the Bootmanager (here 
pacman -S $bootmgr_pkgs
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
COMMENT
