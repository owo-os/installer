
ramfs.zst: busybox linux iso.sh
	./iso.sh

newroot: ramfs.zst
	mkdir -p newroot/boot
	cd linux && make install INSTALL_PATH=../newroot/boot
	ln -f ramfs.zst newroot/boot
	#ln -f linux/vmlinux newroot/boot
	ln -f isolinux.cfg newroot
	cp /usr/lib/syslinux/bios/isolinux.bin newroot
	cp /usr/lib/syslinux/bios/ldlinux.c32 newroot

small.iso: newroot isolinux.cfg
	mkisofs -o small.iso -b isolinux.bin -no-pad -no-emul-boot -boot-load-size 4 -boot-info-table newroot

busybox:
	git clone -b 1_36_stable --depth 1 https://git.busybox.net/busybox/ busybox

linux:
	git clone -b v6.6 --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git linux
