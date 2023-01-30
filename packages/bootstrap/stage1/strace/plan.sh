program="strace"

pkg_name="strace-stage1"
pkg_origin="core"
pkg_version="6.0"
pkg_license=("LGPL-2.1-or-later")
pkg_description="strace is a system call tracer for Linux"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_upstream_url="https://strace.io/"
pkg_source="https://github.com/strace/strace/releases/download/v${pkg_version}/${program}-${pkg_version}.tar.xz"
pkg_shasum="92d720a666855e9f1c6a11512fd6e99674a82bbfe1442557815f2ce8e1293338"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/glibc-stage0
	core/libunwind-stage1
	core/build-tools-bash-static
)
pkg_build_deps=(
	core/gcc-stage1
	core/build-tools-coreutils
	core/build-tools-gawk
	core/build-tools-grep
	core/build-tools-make
	core/build-tools-sed
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)

do_build() {
	./configure \
		--prefix="${pkg_prefix}" \
		--enable-mpers=check
	make
}

do_check() {
	make check
}

do_install() {
	make install

	# Fix shell scripts
	fix_interpreter "${pkg_prefix}/bin/strace-log-merge" core/build-tools-bash-static bin/sh
}