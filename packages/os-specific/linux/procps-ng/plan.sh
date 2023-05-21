pkg_name="procps-ng"
pkg_origin="core"
pkg_version="3.3.17"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Command line and full screen utilities for browsing procfs, a pseudo file \
system dynamically generated by the kernel to provide information about the \
status of entries in its process table.\
"
pkg_upstream_url="https://gitlab.com/procps-ng/procps"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.0-or-later')
pkg_source="https://downloads.sourceforge.net/project/${pkg_name}/Production/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="4518b3e7aafd34ec07d0063d250fd474999b20b200218c3ae56f5d2113f141b4"
pkg_dirname="${pkg_name}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/ncurses
)
pkg_build_deps=(
	core/gcc
	core/pkg-config
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_unpack() {
	mkdir -p "$HAB_CACHE_SRC_PATH/$pkg_dirname"
	pushd "$HAB_CACHE_SRC_PATH/$pkg_dirname" >/dev/null
	tar xf "$HAB_CACHE_SRC_PATH/$pkg_filename" --strip-components=1
	popd >/dev/null
}

do_build() {
	# The Util-linux package will provide the `kill` command
	./configure \
		--prefix="$pkg_prefix" \
		--sbindir="$pkg_prefix/bin" \
		--disable-kill
	make
}

do_check() {
	make check
}
