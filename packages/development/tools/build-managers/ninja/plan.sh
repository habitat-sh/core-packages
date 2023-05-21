pkg_name="ninja"
pkg_origin="core"
pkg_version="1.10.2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_upstream_url="https://ninja-build.org/"
pkg_description="A small build system with a focus on speed"
pkg_licenses=('Apache-2.0')
pkg_source="https://github.com/ninja-build/${pkg_name}/archive/v${pkg_version}.tar.gz"
pkg_shasum="ce35865411f0490368a8fc383f29071de6690cbadc27704734978221f25e2bed"
pkg_deps=(
	core/glibc
	core/gcc-libs
)
pkg_build_deps=(
	core/cmake
	core/gcc
	core/re2c
)
pkg_bin_dirs=(bin)

do_build() {
	mkdir build
	pushd build || exit 1
	cmake .. \
		--install-prefix="${pkg_prefix}"
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
