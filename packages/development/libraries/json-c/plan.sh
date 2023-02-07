pkg_name="json-c"
pkg_origin="core"
pkg_version="0.16"
pkg_description="A JSON implementation in C"
pkg_upstream_url="https://github.com/json-c/json-c"
pkg_license=('MIT')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://s3.amazonaws.com/json-c_releases/releases/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="8e45ac8f96ec7791eaf3bb7ee50e9c2100bbbc87b8d0f1d030c5ba8a0288d96b"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
	core/cmake
	core/make
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	mkdir build
	pushd build || exit 1
	cmake .. \
		-DCMAKE_INSTALL_PREFIX="${pkg_prefix}" \
		-DCMAKE_BUILD_TYPE=Release
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
