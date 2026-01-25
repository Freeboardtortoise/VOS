#!/bin/bash
ROOT=$(pwd)

echo "loading external modules"
chmod +x run/cache.sh
source run/cache.sh
#    the compile script for this OS
#    Copyright (C) 2025  Freeboardtortoise
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

C_COMPILER="gcc"   # "/home/darion/Code/tortoiseLinux/musl/bin/x86_64-linux-musl-gcc"
CPP_COMPILER="g++" # "/home/darion/Code/tortoiseLinux/musl/bin/x86_64-linux-musl-g++"
SYSROOT=""        # "/home/darion/Code/tortoiseLinux/sysroot/"

mkdir -p build/output
set -e

# adding the options for the command line args


if mountpoint -q "mnt"; then
	echo " thing is mounted"
	if sudo umount mnt; then
		echo "delete successfull"
	else
		echo "using dangorourer umounting method"
		sudo umount mnt -l
	fi
fi
if [ -d build/working ] ; then
	rm -rf build/working/
	mkdir build/working
else
	mkdir build/working
fi
	
echo "checking if there is an existing image..."
if [ -f rootfs.img ]; then
	echo "image exists, deleting it..."
	if mountpoint -q mnt; then
		sudo umount mnt
	fi
	sudo rm -rf mnt
	mkdir -p mnt
	sudo rm rootfs.img
fi

echo "creating a new disk image with partition table..."
qemu-img create -f raw rootfs.img 10G

# partitions
parted rootfs.img --script mklabel gpt
parted rootfs.img --script mkpart BIOS_BIOS_GRUB 1MiB 2MiB
parted rootfs.img --script mkpart ESP fat32 2MiB 202MiB
parted rootfs.img --script mkpart primary ext4 202MiB 100%
parted rootfs.img --script set 2 boot on # ESP boot flag
parted rootfs.img --script set 1 boot on
parted rootfs.img --script set 1 bios_grub on

# Associate the image with a loop device so partitions are visible
# mounting and stuff

LOOPDEV=$(sudo losetup --show -fP rootfs.img)
EFI_PART="${LOOPDEV}p2"
ROOT_PART="${LOOPDEV}p3"

sudo mkfs.vfat $EFI_PART
sudo mkfs.ext4 $ROOT_PART
# mount
mkdir -p mnt
sudo mount $ROOT_PART mnt
sudo mkdir -p mnt/boot/efi
sudo mount $EFI_PART mnt/boot/efi
#
echo "moving the files and compining into the image"
mkdir -p build/working
echo "compile files in src"
# Directory with source files
SRC_DIR="./src/gcc"
# Output directory for binaries
BIN_DIR="./build/working"

# Create output dir if it doesn't exist
mkdir -p "$BIN_DIR"

# Loop over all .c files in the source directory
for src_file in "$SRC_DIR"/*.c; do
	# Extract just the filename without extension
	filename=$(basename "$src_file" .c)
	# Compile statically
	$C_COMPILER --sysroot=$SYSROOT -m64 "$src_file" -o "$BIN_DIR/$filename" -static

	# Check if compilation succeeded
	if [ $? -eq 0 ]; then
		echo "Compiled $src_file -> $BIN_DIR/$filename"
	else
		echo "Failed to compile $src_file"
	fi
done

## Directory with source files
#SRC_DIR="./src/g++"
## Output directory for binaries
#BIN_DIR="./build/working"
#
## Create output dir if it doesn't exist
#mkdir -p "$BIN_DIR"
#
## Loop over all .c files in the source directory
#for src_file in "$SRC_DIR"/*.cpp; do
#	filename=$(basename "$src_file" .cpp)
#
#	# Decide libraries needed
#	LIBS=""
#	if grep -q "#include <sodium.h>" "$src_file"; then
#		LIBS="-lsodium"
#	fi
#
#	$CPP_COMPILER --sysroot=$SYSROOT -static -m64 "$src_file" -o "$BIN_DIR/$filename" $LIBS
#
#	if [ $? -eq 0 ]; then
#		echo "Compiled $src_file -> $BIN_DIR/$filename"
#	else
#		echo "Failed to compile $src_file"
#	fi
#done


# Directory with source files
SRC_DIR="./src/V"
# Output directory for binaries
BIN_DIR="./build/working"

# Create output dir if it doesn't exist
mkdir -p "$BIN_DIR"

# Loop over all .c files in the source directory
for src_file in "$SRC_DIR"/*.v; do
	filename=$(basename "$src_file" .v)

	# Decide libraries needed
	v -prod "$SRC_DIR/$filename".v -cc gcc -cflags '-static -static-libgcc' -o $BIN_DIR/$filename
		if [ $? -eq 0 ]; then
		echo "Compiled $src_file -> $BIN_DIR/$filename"
	else
		echo "Failed to compile $src_file"
	fi
done


echo "moving binaries filesystem"

sudo mkdir -p mnt/bin
sudo mkdir -p mnt/lib
sudo mkdir -p mnt/sbin
sudo mkdir -p mnt/sys
sudo mkdir -p mnt/dev
sudo mkdir -p mnt/proc
sudo mkdir -p mnt/usr
sudo mkdir -p mnt/home
sudo mkdir -p mnt/etc
sudo mkdir -p mnt/tmp

sudo cp -a src/passwd mnt/etc/passwd

echo "installing busybox"
if [ -f /bin/busybox ]; then
	echo "busybox exists"
else
	echo "install busybox from your package manager to continue"
	exit 1
fi
sudo cp -a -r busybox/busybox mnt/bin/busybox
sudo cp -a -r busybox/busybox mnt/bin/mount
sudo cp -a -r busybox/busybox mnt/bin/sh # (needed anyway for /bin/sh!)
sudo cp -a -r busybox/busybox mnt/sbin/mdev
sudo cp -a -r busybox/busybox mnt/bin/ls



sudo chmod +x mnt/bin/busybox

echo "installing vinit into the OS"
sudo cp build/working/vinit mnt/sbin/vinit
sudo cp src/otherFiles/* mnt/ -r -a

sudo chmod +x mnt/sbin/vinit
echo "istalling vshell into the os"
sudo cp build/working/vshell mnt/bin/vshell
sudo chmod +x mnt/bin/vshell


# sudo chmod +x mnt/bin/g++

gcc --sysroot=/ -m64 src/gcc/init.c -o build/working/init -static -v
sudo cp -a build/working/init mnt/sbin/
sudo chmod +x mnt/sbin/init

#sudo cp build/working/packageManager mnt/bin/pkgmgr
#sudo cp build/working/shell mnt/bin/
#sudo cp build/working/login mnt/bin/
#sudo cp build/working/login_init mnt/bin/
#sudo cp build/working/test mnt/bin/test

echo "install grub"

sudo mkdir -p mnt/boot/grub
sudo mkdir -p mnt/boot/efi
if  get_cached_boot ; then
	echo "loaded cached boot data"
else 
	echo "installing grub because couldnt install cached version"
	
fi
sudo grub-install \
  	--target=i386-pc \
  	--boot-directory=mnt/boot \
  	--modules="normal part_msdos ext2 multiboot" \
  	"$LOOPDEV"

echo "caching boot stuff"
cache_boot
if [ $1 = "serial" ]; then
	sudo cp boot/grub.cfg mnt/boot/grub/grub.cfg
else 
	sudo cp boot/dirboot.cfg mnt/boot/grub/grub.cfg
fi

sudo cp boot/bzImage mnt/boot/



echo "BIOS Boot"

if [ $1 = "serial" ]; then
	qemu-system-x86_64 \
  	-m 1024 \
  	-drive file=rootfs.img,format=raw \
  	-serial stdio
else
	qemu-system-x86_64 \
  	-m 1024 \
  	-drive file=rootfs.img,format=raw
fi

echo "a nother boot option"
qemu-system-x86_64 \
	-m 1024 -smp 2 \
	-drive file=rootfs.img,format=raw,if=virtio \
	-boot c \
	-nic none
