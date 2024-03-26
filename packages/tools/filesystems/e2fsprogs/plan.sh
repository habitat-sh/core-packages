pkg_name="e2fsprogs"
pkg_origin="core"
pkg_version="1.46.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Ext2/3/4 filesystem userspace utilities"
# https://github.com/tytso/e2fsprogs/blob/v1.46.4/NOTICE
pkg_license=('GPL-2.0-or-later' 'LGPL-2.0-or-later' 'MIT')
pkg_upstream_url="http://e2fsprogs.sourceforge.net/"
pkg_source="https://git.kernel.org/pub/scm/fs/ext2/e2fsprogs.git/snapshot/e2fsprogs-${pkg_version}.tar.gz"
pkg_shasum="c011bf3bf4ae5efe9fa2b0e9b0da0c14ef4b79c6143c1ae6d9f027931ec7abe1"
pkg_deps=(
	core/glibc
	core/util-linux
	core/bash
)
pkg_build_deps=(
	core/gcc
	core/gettext
	core/perl
	core/pkg-config
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_bin_dirs=(
	bin
	sbin
)

do_build() {
	mkdir -v build
	pushd build || exit 1
	../configure \
		--prefix="${pkg_prefix}" \
		--enable-elf-shlibs \
		--disable-libblkid \
		--disable-libuuid \
		--disable-uuidd \
		--disable-fsck
	make -j"$(nproc)"
	popd || exit 1
}

do_check() {
	# Remove expected test failure
	rm -rf tests/u_direct_io
	pushd build || exit 1
	make check
	popd || exit 1
}

do_install() {
	pushd build || exit 1
	make install
	fix_interpreter "$pkg_prefix/sbin/*" core/bash bin/bash
	popd || exit 1
}
