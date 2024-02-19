#!/bin/bash

# Function to terminate the script on error
on_error() {
    echo "The script was terminated due to an error."
    exit 1
}

# Set the error handler
trap 'on_error' ERR





# Update mirrorlist
# Variables
mirrors="5"
protocol="https"
sort="rate"
country="France,Germany"
mirrorlist="/etc/pacman.d/mirrorlist"

# Initial Sequenz
echo "Update the mirrorlist"
echo "Latest $mirrors with $protocol from $country, sort by $sort"

# Commands
reflector --latest 5 --protocol https --sort rate --country France,Germany --verbose --save $mirrorlist
echo
cat $mirrorlist

# Finish sequenz
echo "Update complete. Press any key to continue. (Timeout: 5 seconds)"
if read -t 5 -n 1 -s -r -p ""; then
    :
fi





# Update databases
# Initial Sequenz
echo "Update the repositories"

# Commands
pacman -Sy

# Finish sequenz
echo "Update complete. Press any key to continue. (Timeout: 5 seconds)"
if read -t 5 -n 1 -s -r -p ""; then
    :
fi
echo
echo "Start the Installation"
echo
sleep 2





# Disk Partitioning
# Variables
disk="/dev/sda" # The disk, you want to install Arch
bootsize="+1024M"
rootsize="0"
rootsizeecho=""

if [ $rootsize = "0" ]; then
    rootsizeecho="full"
else
    rootsizeecho="$rootsize"
fi

# Initial Sequenz
echo
echo "Partitioning"
sleep 2
echo

# Commands
echo "Create a new partition Table and delete the old one!"
sgdisk -o $disk

echo "Create a EFI boot partition with $bootsize size"
sgdisk -n 0:0:$bootsize -t 0:ef00 -c 0:BOOT $disk

echo "Create a root partition with $rootsizeecho size"
sgdisk -n 0:0:$rootsize -t 0:8300 -c 0:ROOT $disk

# Finish sequenz
echo "Partition table created. Press any key to continue. (Timeout: 5 seconds)"
if read -t 5 -n 1 -s -r -p ""; then
    :
fi





# Disk Formatting
# Variables
part1=$disk"1"  # Partition 1, the boot partition
part2=$disk"2"  # Partition 2, the root partition

# Initial Sequenz
echo
echo "Formatting"
sleep 2
echo

# Commands
echo "Format the boot partition with FAT32 and Label it with BOOT"
mkfs.fat -F32 -n BOOT $part1

echo "Format the root partition with BTRFS and Label it with ROOT"
mkfs.btrfs -L ROOT $part2

# Finish sequenz
echo "Formatting completed. Press any key to continue. (Timeout: 5 seconds)"
if read -t 5 -n 1 -s -r -p ""; then
    :
fi





# Create subvolumes and Mount the partitions
# Initial Sequenz
echo
echo "Create subvolumes and mount the partitions"
sleep 2
echo

# Commands
echo "Mount the root partition to create the subvolumes"
mount -L ROOT /mnt

echo "Create the subvolumes"
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@spool
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@srv
btrfs subvolume create /mnt/@.snapshots

echo "Unmount the root partition and mount it with the correct settings"
umount /mnt
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@ $part2 /mnt

echo "Create the folders for the subvolumes"
mkdir -p /mnt/{home,root,var/cache,var/log,var/spool,tmp,srv,.snapshots}

echo "Mount the subvolumes"
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@home $part2 /mnt/home
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@root $part2 /mnt/root
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@cache $part2 /mnt/var/cache
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@log $part2 /mnt/var/log
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@spool $part2 /mnt/var/spool
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@tmp $part2 /mnt/tmp
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@srv $part2 /mnt/srv
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@.snapshots $part2 /mnt/.snapshots

echo "Create the folder for the boot partiton and mount it"
mkdir -p /mnt/boot
mount -L BOOT /mnt/boot

echo "Overview of the mounted subvolumes"
lsblk

# Finish sequenz
echo "Subvolumes created and partitions mounted. Press any key to continue. (Timeout: 5 seconds)"
if read -t 5 -n 1 -s -r -p ""; then
    :
fi





# Basic installation of the system
# Variables
base_pkgs="base base-devel"
kernel_pkgs="linux-zen linux-zen-headers linux-lts linux-lts-headers linux-firmware"
network_pkgs="networkmanager iwd"
utilities_pkgs="vim"
bootmgr_pkgs="grub grub-btrfs efibootmgr"
de_pkgs=""

# Inital Sequenz
echo
echo "Install the packages with pacstrap"
sleep 2
echo

# Commands
pacstrap /mnt \
$base_pkgs \
$kernel_pkgs \
$network_pkgs \
$utilities_pkgs

# Finish sequenz
echo "Basic Installation complete. Press any key to continue. (Timeout: 5 seconds)"
if read -t 5 -n 1 -s -r -p ""; then
    :
fi





# Generate the fstab file with labels
# Inital Sequenz
echo
echo "Generate the filesystem table with labels"
sleep 2
echo

# Commands
# Generate the table
genfstab -L /mnt >> /mnt/etc/fstab

# Show the table
cat /mnt/etc/fstab

# Finish sequenz
echo "Filesystem table generated. Press any key to continue. (Timeout: 5 seconds)"
if read -t 5 -n 1 -s -r -p ""; then
    :
fi





# SCRIPT TESTED UNTIL CHROOT. AFTER CHROOT THE SCRIPT STOPS
:<<COMMENT
# Chroot into the new system
arch-chroot /mnt

echo
echo "Inside the new installation, 5 seconds break"
echo "Next: Set timezone"
sleep 5

# Set the system timezone
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc

echo
echo "Timezone set, 5 seconds break"
echo "Next: Set localization"
sleep 5

# Set localization (German and English)
echo "de_DE.UTF-8 UTF-8" > /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=de_DE.UTF-8" > /etc/locale.conf


echo
echo "Localization completed, 5 seconds break"
echo "Next: Set keyboard layout"
sleep 5

# Set the keyboard layout to de-latin1
echo "KEYMAP=de-latin1" > /etc/vconsole.conf

echo
echo "Keyboard layout set, 5 seconds break"
echo "Next: Set hostname"
sleep 5

# network settings
hostname="arch"
domain="pat-web.de"

# Set the hostname
echo $hostname > /etc/hostname

echo
echo "Hostname set, 5 seconds break"
echo "Next: Edit hosts file"
sleep 5

# Edit the hosts file
echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    $hostname.$domain $hostname" >> /etc/hosts

echo
echo "Hosts file configured, 5 seconds break"
echo "Next: Set root password"
sleep 5

# Set the root user password
passwd

echo
echo "Password set, 5 seconds break"
echo "Next: Install and configure bootmanager"
sleep 5

# Install and configure the Bootmanager
pacman -S $bootmgr_pkgs
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg

echo
echo "Boot manager configured, 5 seconds break"
echo "Next: Install additional packages"
sleep 5

# Install additional packages
pacman -S acpid avahi bash-completion bluez bluez-utils cifs-utils cups curl dosfstools fuse2fs git hplip network-manager-applet nfs-utils ntfs-3g reflector samba wget zsh

echo
echo "Package install completed, 5 seconds break"
echo "Next: Start services"
sleep 5

# Enable services
systemctl enable acpid
systemctl enable avahi-daemon
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable NetworkManager
systemctl enable reflector.timer

echo
echo "Services started, 5 seconds break"
echo "Next: Exit chroot and reboot"
sleep 5

# Logout from chroot and reboot the system
exit
umount -R /mnt
reboot
COMMENT
