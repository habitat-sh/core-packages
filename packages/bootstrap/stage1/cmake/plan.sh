program="cmake"

pkg_name="cmake-stage1"
pkg_origin="core"
pkg_version="3.25.1"
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'
pkg_license=('BSD-3-Clause')
pkg_description="CMake is an open-source, cross-platform family of tools designed to build, test and package software"
pkg_upstream_url="https://cmake.org/"
pkg_source="https://github.com/Kitware/CMake/releases/download/v${pkg_version}/cmake-${pkg_version}.tar.gz"
pkg_shasum="1c511d09516af493694ed9baf13c55947a36389674d657a2d5e0ccedc6b291d8"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/glibc
	core/gcc-libs
	core/openssl
	core/coreutils
)
pkg_build_deps=(
	core/gcc
	core/bzip2
)

pkg_bin_dirs=(bin)

do_prepare() {
	# Prevents applications using cmake from attempting to install files in /usr/lib64
	sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake
}

do_build() {
	./bootstrap \
		--prefix="${pkg_prefix}" \
		--parallel="$(nproc)" \
		-- \
		-DOPENSSL_ROOT_DIR:PATH="$(pkg_path_for openssl)"
	make -j "$(nproc)"
}

do_install() {
	make install
	fix_interpreter "$pkg_prefix/share/cmake-3.25/Modules/Compiler/XL-Fortran/cpp" core/coreutils bin/env
}
