pkg_name=fribidi
pkg_origin=core
pkg_version="1.0.15"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('LGPL-2.1-only')
pkg_description="A command-line interface to the libfribidi library and can be used to convert a logical string to visual output."
pkg_upstream_url="https://github.com/fribidi/fribidi/"
pkg_source="https://github.com/fribidi/fribidi/archive/refs/tags/v${pkg_version}.tar.gz"
pkg_shasum="0db5f0621b6fbfae5960c30da4f132009fd72bf4687f1b04a87a4cfc2a08ea38"

pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
	core/make
	core/pkg-config
	core/meson
	core/ninja
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	export PYTHONPATH=${PYTHONPATH}:$(pkg_path_for meson)/lib/python3.10/site-packages/

	meson setup builddir -Dprefix="$pkg_prefix" --buildtype=release -Ddocs=false
	ninja -C builddir
}	

do_install() {
	ninja -C builddir install
}

do_check() {
	ninja -C builddir test
}