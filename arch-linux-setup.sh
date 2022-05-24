
# Arch Linux setup following these links:
## https://wiki.archlinux.org/title/installation_guide
## https://youtu.be/chApqIF0jRQ   
## https://ambrovanwyk.com/index.php/installing-arch-linux-on-vmware-workstation-player/

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
# swap  >512 MB 1MiB 1024Mib
# /mnt   1204MiB 100%
# 
parted /dev/sda 

mklabel msdos
mkpart primary linux-swap 1MiB  2GiB
mkpart primary ext4 2GiB  100%
set 1 boot on
quit

# Create file system for /dev/sda1
mkfs.ext4 /dev/sda2
mkswap    /dev/sda1
swapon    /dev/sda1
mount /dev/sda2 /mnt


# Now install linux essential packages
pacstrap -i /mnt base linux linux-firmware

# Generate 	an fstab file 
genfstab -U /mnt >> /mnt/etc/fstab


# Change root to the new system
arch-chroot /mnt

# At this point I realized base package did not bring VIM in. So, needed to install vim package
# to be able to change files
pacman -S vim grub net-tools inetutils dhcpcd

#Select a time zone:
tzselect

# Set the time zone
ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime

# @Run hwclock(8) to generate /etc/adjtime:
#It is recommended to adjust the time skew, and set the time standard to UTC:
hwclock --systohc --utc

# Uncomment en_US.UTF-8 UTF-8 in /etc/locale.gen, as well as other needed localisations. Save the file, and generate the new locales: 
locale-gen

# Setup localization - set LANG variable accordingly
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Install the grub package. (It will replace grub-legacyAUR if that is already installed.) Then do:
# do not use partition number -- this is instant
grub-install --target=i386-pc /dev/sda

grub-mkconfig -o /boot/grub/grub.cfg

# Required for network manager to start networking service
systemctl start dhcpcd
systemctl enable dhcpcd 

## Edit the /etc/pacman.conf file, uncomment the line with [multilib] and the following
## include=/etc/pacman.d/mirrorlist and save and exit
# And sync pacman database
pacman -Syy

## Remember to change hostname	

exit 

reboot
