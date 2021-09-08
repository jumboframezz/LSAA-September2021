#!/bin/bash 

## TASK1
# Install zfs
yum -y install yum-utils
yum -y install http://download.zfsonlinux.org/epel/zfs-release.el8_4.noarch.rpm
yum -y install zfs

# Make sure to load kernel module at boot & loading kernel module at system runtime
echo zfs > /etc/modules-load.d/zfs.conf
modprobe zfs
lsmod | grep zfs 

# create 2 partitions on each drive
for drive in b c d e f g;  do
	parted -s  /dev/vd$drive -- mklabel msdos  mkpart primary  0GB 5GB
	parted -s  /dev/vd$drive --   mkpart primary  5GB 10GB
done


# create array
zpool create -f  zfs-arr /dev/vde1 /dev/vdf1 /dev/vdg1 mirror /dev/vdb1 /dev/vdc1 /dev/vdd1
zpool create -f  zfs-arr1 /dev/vde2 /dev/vdf2 mirror /dev/vdg2  /dev/vdb2 mirror /dev/vdc2 /dev/vdd2

#check
zpool list -v

## TASK2 
# Destroy
zpool  destroy zfs-arr
zpool  destroy zfs-arr1


for drive in b c d e f g;  do
	parted -s  /dev/vd$drive -- mklabel msdos  mkpart primary  0GB 5GB
done

lsblk 
zpool create arr_l6 raidz2 /dev/vdb1 /dev/vdc1 /dev/vdd1 /dev/vde1 /dev/vdf1
zpool list -v

## Task 3
cryptsetup  -v luksFormat /dev/vdg1
mkdir /etc/luks-keys
dd if=/dev/urandom of=/etc/luks-keys/disk_key bs=512 count=8
cryptsetup -v luksAddKey /dev/vdg1 /etc/luks-keys/disk_key 
cryptsetup -v luksOpen /dev/vdg1 vdg1_crypt --key-file=/etc/luks-keys/disk_key
mkfs.xfs  /dev/mapper/vdg1_crypt 
mount /dev/mapper/vdg1_crypt  /mnt/

# Other options for automount encrypted volume include:
# Storage of key into server TPM module
# Modifying initrd to setup network and use encrypted communication with HSM system (e.q. Gemalto KeySecure)


