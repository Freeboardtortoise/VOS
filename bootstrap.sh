init() {
  echo "bootstrap script loaded!"
}

echo "bootstraping... this could take a while"

echo "checking for linux kernal"
if [ ! -f boot/bzImage ] ; then
  echo "linux kernal not found"
  git clone https://github.com/torvalds/linux --depth=1
  echo " downloaded the linux kernal"
  echo "replacing the config"
  cp configs/linuxconf linux/.config
  export home_dir=$(pwd)
  cd linux
  echo "doing the olddefconfig to fill in new options with defaults"
  make olddefconfig   # Non-interactive; sets defaults for any new options
  echo "making linux :) good luck"
  make
  cd $home_dir
  cp linux/arch/x86/boot/bzImage boot/bzImage

fi
echo "done with linux"

# checking for busybox
echo "checking for busybox"
if [ ! -d busybox/ ]; then
  echo "making busybox"
  git clone https://github.com/mirror/busybox --depth=1
  cp configs/busyboxconfig busybox/.config
  cd busybox
  make
  cp busybox ../bbb
  cd ..
  rm -rf busybox
  mkdir busybox
  cp bbb busybox/busybox
  rm bbb
fi
echo "done with busybox"
