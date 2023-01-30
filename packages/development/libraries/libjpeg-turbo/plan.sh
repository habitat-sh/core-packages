program="libjpeg-turbo"

pkg_name="libjpeg-turbo"
pkg_origin="core"
pkg_version="2.1.4"
pkg_description="A faster (using SIMD) libjpeg implementation"
pkg_upstream_url="http://libjpeg-turbo.virtualgl.org/"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('IJG' 'BSD-3-Clause' 'Zlib')
pkg_source="https://sourceforge.net/projects/${program}/files/${pkg_version}/${program}-${pkg_version}.tar.gz/download"
pkg_filename=${program}-${pkg_version}.tar.gz
pkg_shasum="d3ed26a1131a13686dfca4935e520eb7c90ae76fbc45d98bb50a8dc86230342b"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/cmake
	core/gcc
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	mkdir build
	pushd build || exit 1
	cmake .. \
		--install-prefix="${pkg_prefix}" \
		-DCMAKE_INSTALL_DEFAULT_LIBDIR="lib"
	cmake --build . --parallel "$(nproc)"
	popd || exit 1
}

do_check() {
	pushd build || exit 1
	make test
	popd || exit 1
}

do_install() {
	pushd build || exit 1
	cmake --install .
	popd || exit 1
}