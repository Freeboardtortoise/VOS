WHERE=$1
./compile.sh y
./mkinitramfs.sh
sudo dd if=tortoiseLinux.iso of=$WHERE bs=4M status=progress conv=fsync
sudo chmod 666 $WHERE
qemu-system-x86_64 -enable-kvm -m 2G -hda $WHERE
