CURRENTDIR="$PWD/build"

mkdir -p $CURRENTDIR/initramfs
rm -rf $CURRENTDIR/initramfs
mkdir $CURRENTDIR/initramfs
cp mnt/* $CURRENTDIR/initramfs -ra
chmod +x $CURRENTDIR/initramfs/sbin/init

cd $CURRENTDIR/initramfs/

find . | cpio -H newc -o | gzip >$CURRENTDIR/boot/initramfs-tortoise.img
rm -rf initramfs
