#!/bin/sh

set -ev

cd busybox

ln -sf ../busyconfig .config
make -j"$(nproc)"

cd ../linux

make tinyconfig
patch -p1 <../linconfig

make -j"$(nproc)"

cd ..

mkdir -p root/{bin,proc,dev,sys}
ln -f busybox/busybox root/bin

cd root/bin
./busybox --list | grep -v busybox | xargs -n1 ln -sf busybox
cd ../..

find root -printf "%P\0" | cpio --create --null --format newc -D root | zstd > ramfs.zst
