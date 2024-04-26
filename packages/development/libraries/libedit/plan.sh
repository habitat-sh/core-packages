pkg_name="libedit"
pkg_origin="core"
pkg_version="20230828-3.1"
pkg_license=('BSD-3-Clause')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="http://thrysoee.dk/editline/${pkg_name}-${pkg_version}.tar.gz"
pkg_upstream_url="https://thrysoee.dk/editline/"
pkg_description="This is an autotool- and libtoolized port of the NetBSD Editline library (libedit)."
pkg_shasum="4ee8182b6e569290e7d1f44f0f78dac8716b35f656b76528f699c69c98814dad"
pkg_deps=(
	core/glibc
	core/ncurses
)
pkg_build_deps=(
	core/gcc
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
