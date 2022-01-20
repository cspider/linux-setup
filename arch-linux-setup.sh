
# Arch Linux setup following two links:
## https://wiki.archlinux.org/title/installation_guide
## https://youtu.be/chApqIF0jRQ   

# if the following ls works w/o error, i.e. EFI boot mode
# ls /sys/firmware/efi/efivars 

# Try to find out if internet is alredy setup
# ip link
# ping -c 2 www.google.com

# Update the system clock on the guest
timedatectl set-ntp true

# Explore storage devices 
lsblk 
# The output is the following: 
# NAME   MAJ:MIN RM  SIZE       RO TYPE MOUNTPOINTS
# loop0  7:0     0   701.3M      1 loop /run/archiso/airootfs
# sda    8:0     0      20G      0 disk 
# sr0   11:0     0   850.3M      0 rom  /run/archiso/bootmnt


# Alternative you can do
fdisk -l

# Ignore everythong loop, rom or airoots

# Start disk partitioning using parted or fdisk
#
# /boot  1 GB 1MiB 1024Mib
# 
parted
mkpart primary ext4 1MiB 1024MiB
set 1 boot on
mkpart primary linux-swap 1024MiB  5GiB
mkpart primary ext4 5GiB  100%
quit

# Create file system for /dev/sda1
mkfs.ext4 /dev/sda1
mkdf.ext4 /dev/sda3
mkswap    /dev/sda2
swapon    /dev/sda2

mount /dev/sda3 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot

# Now install linux essential packages
pacstrap /mnt base linux linux-firmware

# Generate 	an fstab file 
genfstab -U /mnt >> /mnt/etc/fstab


# Change root to the new system
arch-chroot /mnt


# At this point I realized base package did not bring VIM in. So, needed to install vim package
# to be able to change files
pacman -S vim

# Set the time zone
ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime

# @Run hwclock(8) to generate /etc/adjtime:
hwclock --systohc

# Uncomment en_US.UTF-8 UTF-8 in /etc/locale.gen, as well as other needed localisations. Save the file, and generate the new locales: 
locale-gen

# Setup localization - set LANG variable accordingly
echo "LANG=en_US.UTF-8" >> /etc/locale.conf


#Select a time zone:
tzselect

# Setup timezone
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime

#It is recommended to adjust the time skew, and set the time standard to UTC:
hwclock --systohc --utc

# bootloader configuration: install grub
packman -S grub

