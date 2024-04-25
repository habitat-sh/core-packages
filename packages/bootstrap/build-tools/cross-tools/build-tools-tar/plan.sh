program="tar"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-tar"
pkg_origin="core"
pkg_version="1.35"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GNU Tar provides the ability to create tar archives, as well as various other \
kinds of manipulation.\
"
pkg_upstream_url="https://www.gnu.org/software/tar/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="14d55e32063ea9526e057fbf35fcabd53378e769787eff7919c3755b02d2b57e"
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
		--host="$native_target"

	make
}

do_check() {
	make check
}

do_install() {
	do_default_install

	# copy license files to package
	install -Dm644 ${CACHE_PATH}/COPYING ${pkg_prefix}
}