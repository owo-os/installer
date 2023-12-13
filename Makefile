
ramfs.zst: busybox linux iso.sh busyconfig linconfig
	./iso.sh

newroot: ramfs.zst isolinux.cfg
	mkdir -p newroot/boot
	cd linux && make install INSTALL_PATH=../newroot/boot
	rm -f newroot/boot/System.* newroot/boot/vmlinuz.old
	ln -f ramfs.zst newroot/boot
	ln -f isolinux.cfg newroot
	cp /usr/lib/syslinux/bios/isolinux.bin newroot
	cp /usr/lib/syslinux/bios/ldlinux.c32 newroot

small.iso: newroot
	mkisofs -o small.iso -b isolinux.bin -no-pad -no-emul-boot -boot-load-size 4 -boot-info-table newroot

busybox:
	git clone -b 1_36_stable --depth 1 https://git.busybox.net/busybox/ busybox

linux:
	git clone -b v6.6 --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git linux

clean:
	rm -rf newroot root/bin
	rm -f ramfs.zst small.iso

distclean:
	cd busybox && make distclean
	cd linux && make distclean
