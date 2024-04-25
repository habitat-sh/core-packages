program="sed"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-sed"
pkg_origin="core"
pkg_version="4.9"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
sed (stream editor) is a non-interactive command-line text editor. sed is \
commonly used to filter text, i.e., it takes text input, performs some \
operation (or set of operations) on it, and outputs the modified text. sed is \
typically used for extracting part of a file using pattern matching or \
substituting multiple occurrences of a string within a file.\
"
pkg_upstream_url="https://www.gnu.org/software/sed/"
pkg_license=('GPL-3.0-only')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.xz"
pkg_shasum="6e226b732e1cd739464ad6862bd1a1aba42d7982922da7a53519631d24975181"
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