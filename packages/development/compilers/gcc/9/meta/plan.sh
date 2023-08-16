program="gcc"

pkg_name="gcc"
pkg_origin="core"
pkg_version="9.4.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU Compiler Collection (GCC) is a compiler system produced by the GNU \
Project supporting various programming languages. GCC is a key component of \
the GNU toolchain and the standard compiler for most Unix-like operating \
systems. This package is a wrapper around the build-tools-gcc package with
additional configuration to link against core/glibc instead of core/build-tools-glibc.\
"
pkg_upstream_url="https://gcc.gnu.org/"
pkg_license=('GPL-3.0-or-later WITH GCC-exception-3.1' 'LGPL-3.0-or-later')

pkg_deps=(
	core/binutils
	core/iana-etc
	core/gcc-base
	core/tzdata
)

do_prepare() {
	# Set gcc to use the newly built binutils
	set_runtime_env "HAB_GCC_LD_BIN" "$(pkg_path_for binutils)/bin"
}

do_build() {
	return 0
}

do_install() {
	return 0
}
