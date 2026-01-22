echo "running the cache program"
echo "defining functions"

get_cached_boot() {
  if [ -d ./cache/boot/ ]; then
    sudo cp cache/boot/* mnt/boot -ra
    return 0
  else
    return 1
  fi
}
cache_boot() {
  if [ -f ./mnt/boot/grub/grub.cfg ]; then
    mkdir cache/boot/ -p
    sudo cp mnt/boot/* cache/boot/ -ra
  fi
}
clear_cache() {
  rm -rf cache
}
