pkg_name="jsoncpp"
pkg_origin="core"
pkg_version="1.9.5"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('MIT')
pkg_upstream_url="https://github.com/open-source-parsers/jsoncpp"
pkg_description="A C++ library for interacting with JSON"
pkg_source="https://github.com/open-source-parsers/jsoncpp/archive/refs/tags/${pkg_version}.tar.gz"
pkg_shasum="f409856e5920c18d0c2fb85276e24ee607d2a09b5e7d5f0a371368903c275da2"
pkg_deps=(
	core/glibc
	core/gcc-libs
)
pkg_build_deps=(
	core/cmake-stage1
	core/gcc
	core/python
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	mkdir local-build
	pushd local-build || exit 1
	cmake .. \
		--install-prefix="${pkg_prefix}" \
		-DJSONCPP_WITH_CMAKE_PACKAGE=ON \
		-DJSONCPP_WITH_PKGCONFIG_SUPPORT=ON
	cmake --build . --parallel "$(nproc)"
	popd || exit 1
}

do_check() {
	pushd local-build || exit 1
	make test
	popd || exit 1
}

do_install() {
	pushd local-build || exit 1
	cmake --install .
	popd || exit 1
}
