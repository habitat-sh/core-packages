pkg_name="libedit"
pkg_origin="core"
pkg_version="20221030-3.1"
pkg_license=('BSD-3-Clause')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="http://thrysoee.dk/editline/${pkg_name}-${pkg_version}.tar.gz"
pkg_upstream_url="https://thrysoee.dk/editline/"
pkg_description="This is an autotool- and libtoolized port of the NetBSD Editline library (libedit)."
pkg_shasum="f0925a5adf4b1bf116ee19766b7daa766917aec198747943b1c4edf67a4be2bb"
pkg_deps=(
	core/glibc
	core/ncurses
)
pkg_build_deps=(
	core/gcc
	core/make
	core/coreutils
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
