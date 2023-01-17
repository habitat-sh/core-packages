program="xz"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="xz"
pkg_origin="core"
pkg_version="5.2.6"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
XZ Utils is free general-purpose data compression software with a high \
compression ratio. XZ Utils were written for POSIX-like systems, but also \
work on some not-so-POSIX systems. XZ Utils are the successor to LZMA Utils.\
"
pkg_upstream_url="http://tukaani.org/xz/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.0-or-later')
pkg_source="http://tukaani.org/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="a2105abee17bcd2ebd15ced31b4f5eda6e17efd6b10f921a01cda4a44c91b3a0"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/bash-static
)
pkg_build_deps=(
	core/coreutils
	core/gcc
	core/grep
	core/make
	core/sed
	core/build-tools-gettext
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	# XZ uses libtool which adds it's own -rpath param.
	# This causes the LD_RUN_PATH to be ignored.
	# So we add our own rpath via LDFLAGS which libtool respects
	LDFLAGS="${LDFLAGS} -Wl,-rpath=${LD_RUN_PATH}"
	build_line "Updating LDFLAGS=${LDFLAGS}"
	unset LD_RUN_PATH
}

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--docdir="$pkg_prefix"/share/doc/xz-5.2.6

	make
}

do_check() {
	make check
}

do_install() {
	make install
	# Fix scripts
	fix_interpreter "${pkg_prefix}/bin/*" core/bash-static bin/sh
}
