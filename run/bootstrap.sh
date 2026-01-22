init() {
  echo "bootstrap script loaded!"
}

echo "bootstraping... this could take a while"

echo "checking for linux kernal"
if [ -f boot/bzImage ] ; then
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
