program="diffutils"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-diffutils"
pkg_origin="core"
pkg_version="3.10"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GNU Diffutils is a package of several programs related to finding differences \
between files.\
"
pkg_upstream_url="https://www.gnu.org/software/diffutils"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.xz"
pkg_shasum="90e5e93cc724e4ebe12ede80df1634063c7a855692685919bfe60b556c9bd09e"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/build-tools-glibc
)
pkg_build_deps=(
	core/native-cross-gcc
)
pkg_bin_dirs=(bin)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--build="$(build-aux/config.guess)" \
		--host="$native_target" \
		--target="$native_target"
	make
}
