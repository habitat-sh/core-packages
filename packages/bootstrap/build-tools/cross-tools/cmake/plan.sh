program="cmake"

pkg_name="build-tools-cmake"
pkg_origin="core"
pkg_version="3.29.2"
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'
pkg_license=('Apache-2.0')
pkg_description="CMake is an open-source, cross-platform family of tools designed to build, test and package software"
pkg_upstream_url="https://cmake.org/"
pkg_source="https://github.com/Kitware/CMake/releases/download/v${pkg_version}/cmake-${pkg_version}.tar.gz"
pkg_shasum="36db4b6926aab741ba6e4b2ea2d99c9193222132308b4dc824d4123cb730352e"
pkg_dirname="${program}-${pkg_version}"

pkg_bin_dirs=(bin)

do_build() {
	./bootstrap \
		--prefix="${pkg_prefix}" \
		--parallel="$(nproc)"
	make -j "$(nproc)"
}
