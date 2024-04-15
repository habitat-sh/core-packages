program="coreutils"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-coreutils"
pkg_origin="core"
pkg_version="9.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU Core Utilities are the basic file, shell and text manipulation \
utilities of the GNU operating system. These are the core utilities which are \
expected to exist on every operating system.\
"
pkg_upstream_url="https://www.gnu.org/software/coreutils/"
pkg_license=("GPL-3.0-or-later")
pkg_source="http://ftp.gnu.org/gnu/$program/${program}-${pkg_version}.tar.xz"
pkg_shasum="ea613a4cf44612326e917201bbbcdfbd301de21ffc3b59b6e5c07e040b275e52"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/build-tools-glibc
)
pkg_build_deps=(
	core/native-cross-gcc
)
pkg_bin_dirs=(bin)
pkg_interpreters=(bin/env)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--build="$(build-aux/config.guess)" \
		--host="$native_target" \
		--enable-install-program=hostname \
		--enable-no-install-program=kill,uptime
	make
}

do_install() {
	do_default_install

	install -Dm644 ${CACHE_PATH}/COPYING ${pkg_prefix}
}