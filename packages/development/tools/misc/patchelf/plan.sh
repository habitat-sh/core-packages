pkg_name="patchelf"
pkg_origin="core"
pkg_version="0.13"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
A small utility to modify the dynamic linker and RPATH of ELF executables.\
"
pkg_upstream_url="https://nixos.org/patchelf.html"
pkg_license=('GPL-3.0-or-later')
pkg_source="https://github.com/NixOS/patchelf/archive/refs/tags/${pkg_version}.tar.gz"
pkg_shasum="60c6aeadb673de9cc1838b630c81f61e31c501de324ef7f1e8094a2431197d09"

pkg_deps=(
	core/glibc
	core/gcc-libs
)

pkg_build_deps=(
	core/gcc
	core/autoconf
	core/automake
	core/perl
)

pkg_bin_dirs=(bin)

# updating build steps with v0.13
do_build() {
	./bootstrap.sh
	./configure \
		--prefix="$pkg_prefix"
	make
}

do_check() {
	make check
}

do_install() {
	build_line "${HAB_CACHE_SRC_PATH}/${pkg_dirname}/src/${pkg_name}"
	build_line "${pkg_prefix}/bin/"
	cp "${HAB_CACHE_SRC_PATH}/${pkg_dirname}/src/${pkg_name}" "${pkg_prefix}/bin/"
}
