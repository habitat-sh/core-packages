pkg_name="btrfs-progs"
pkg_origin="core"
pkg_version="6.11"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('GPL-2.0-only' 'LGPL-2.1-or-later')
pkg_description="Btrfs is a modern copy on write (CoW) filesystem for Linux aimed at implementing advanced features while also focusing on fault tolerance, repair and easy administration."
#https://github.com/kdave/btrfs-progs
pkg_upstream_url="https://git.kernel.org/pub/scm/linux/kernel/git/kdave/btrfs-progs.git"
pkg_source="https://git.kernel.org/pub/scm/linux/kernel/git/kdave/btrfs-progs.git/snapshot/btrfs-progs-${pkg_version}.tar.gz"
pkg_shasum="ba1b8017b82e22f874fb3b09805ac4f45e3265888dc56eaf4449f38f896f6fc4"

pkg_deps=(core/glibc
	core/util-linux
	# NOTE(ssd) 2020-05-11: This dependency must be listed
	# _after_ core/util-linux in the runtime deps even though it
	# only ships static libraries.
	#
	# Both core/util-linux and core/e2fsprogs ship the blkid.h
	# header file, but with incompatible
	# definitions. btrfs-progs requires the one in
	# core/util-linux.
	#
	# When generating CFLAGS hab-plan-build puts all build-time
	# dependencies before any runtime dependencies.
	core/e2fsprogs
	core/lzo
	core/zlib
	core/zstd
	core/systemd
	core/libcap
)
pkg_build_deps=(
	core/make
	core/gcc
	core/autoconf
	core/automake
	core/pkg-config
	core/python
)

pkg_lib_dirs=(lib)
pkg_include_dirs=(
	include
	include/btrfs
)
pkg_bin_dirs=(bin)

do_build() {
	AL_OPTS="-I $(pkg_path_for core/pkg-config)/share/aclocal -I$(pkg_path_for core/automake)/share/aclocal-1.16"
	export AL_OPTS
	./autogen.sh
	./configure --disable-documentation --disable-zoned --prefix="${pkg_prefix}"
	make
}

do_install() {
	make install

	find "${pkg_prefix}/bin" -type f -executable \
		-exec sh -c 'file -i "$1" | grep -q "x-executable; charset=binary"' _ {} \; \
		-exec patchelf --shrink-rpath {} \;

	for lib in "${pkg_lib_dirs[@]}"; do
		find "${pkg_prefix}/${lib}" -type f -executable \
			-exec sh -c 'file -i "$1" | grep -q "x-pie-executable; charset=binary"' _ {} \; \
			-exec patchelf --shrink-rpath {} \;
	done
}
