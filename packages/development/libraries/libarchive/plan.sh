program="libarchive"
pkg_name="libarchive"
pkg_origin="core"
pkg_version="3.6.2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Multi-format archive and compression library"
pkg_upstream_url="https://www.libarchive.org"
pkg_license=('BSD-2-Clause')
pkg_source="http://www.libarchive.org/downloads/${program}-${pkg_version}.tar.gz"
pkg_shasum="ba6d02f15ba04aba9c23fd5f236bb234eab9d5209e95d1c4df85c44d5f19b9b3"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/acl
	core/attr
	core/bzip2
	core/glibc
	core/gcc-libs
	core/libb2
	core/libxml2
	core/lz4
	core/openssl
	core/xz
	core/zlib
	core/zstd
)
pkg_build_deps=(
	core/e2fsprogs
	core/gcc
	core/pkg-config
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	# We need to remove all references to linux/fs.h because it has
	# been included within glibc since 2.36
	# https://sourceware.org/glibc/wiki/Release/2.36#Usage_of_.3Clinux.2Fmount.h.3E_and_.3Csys.2Fmount.h.3E
	sed '/linux\/fs\.h/d' -i libarchive/archive_read_disk_posix.c
}

do_build() {
	./configure \
		--prefix="$pkg_prefix"
	make
}

do_check() {
	for prog in "$(pkg_path_for coreutils)"/bin/*; do
		ln -s "$prog" /bin/"$(basename "$prog")"
	done
	make check
}
