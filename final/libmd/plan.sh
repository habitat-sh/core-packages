pkg_name="libmd"
pkg_origin="core"
pkg_version="1.0.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="BSD Mesage Digest library"
pkg_upstream_url="https://www.hadrons.org/software/libmd"
pkg_license=('BSD-3-clause' 'BSD-2-clause' 'ISC' 'Beerware' 'public-domain-md4' 'public-domain-md5' 'public-domain-sha1')
pkg_source="https://archive.hadrons.org/software/libmd/libmd-${pkg_version}.tar.xz"
pkg_shasum="f51c921042e34beddeded4b75557656559cf5b1f2448033b4c1eec11c07e530f"

pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)
