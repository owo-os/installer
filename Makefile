WIDTH ?= 32
BUSYOPTIONS ?= CPPFLAGS=-m$(WIDTH) LDFLAGS=-m$(WIDTH)

linconfigs := $(wildcard arch/*/configs/*)

small.iso: newroot newroot/boot/vmlinuz
	mkisofs -o small.iso -b isolinux.bin -no-pad -no-emul-boot -boot-load-size 4 -boot-info-table newroot

ramfs.zst: root/bin/busybox
	find root -printf "%P\0" | cpio --create --null --format newc -D root | zstd > ramfs.zst

newroot/boot/vmlinuz: linux/vmlinux
	cd linux && make install INSTALL_PATH=../newroot/boot
	rm -f newroot/boot/System.* newroot/boot/vmlinuz.old

newroot: ramfs.zst isolinux.cfg
	mkdir -p newroot/boot
	ln -f ramfs.zst newroot/boot
	ln -f isolinux.cfg newroot
	cp /usr/lib/syslinux/bios/isolinux.bin newroot
	cp /usr/lib/syslinux/bios/ldlinux.c32 newroot

root/bin/busybox: busybox/busybox busyconfig
	mkdir -p root/bin root/proc root/dev
	ln -f busybox/busybox root/bin
	cd root/bin && ./busybox --list | grep -v busybox | xargs -n1 ln -sf busybox

busybox/.config: busyconfig
	ln -sf ../busyconfig busybox/.config

busybox/busybox: busybox busybox/.config
	cd busybox && ${BUSYOPTIONS} make -j"$(shell nproc)"

linux/.config: $(linconfigs)
	cp -r arch linux
	cd linux && make tinyconfig
	cd linux && make owo$(WIDTH).config

linux/vmlinux: linux linux/.config
	cd linux && make -j"$(shell nproc)"

busybox:
	git clone -b 1_36_stable --depth 1 https://git.busybox.net/busybox/ busybox

linux:
	git clone -b v6.6 --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git linux

clean:
	rm -rf newroot root/bin
	rm -f ramfs.zst small.iso linux/.config linux/vmlinux busybox/.config

distclean:
	cd busybox && make distclean
	cd linux && make distclean
