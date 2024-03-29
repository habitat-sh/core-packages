program="libsodium"
pkg_name="libsodium"
pkg_origin="core"
pkg_version="1.0.18"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Sodium is a new, easy-to-use software library for encryption, decryption, \
signatures, password hashing and more. It is a portable, cross-compilable, \
installable, packageable fork of NaCl, with a compatible API, and an extended \
API to improve usability even further.\
"
pkg_upstream_url="https://github.com/jedisct1/libsodium"
pkg_license=('ISC')
pkg_source="https://download.libsodium.org/libsodium/releases/${program}-${pkg_version}.tar.gz"
pkg_shasum="6f504490b342a4f8a4c4a02fc9b866cbef8622d5df4e5452b46be121e46636c1"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/autoconf
	core/automake
	core/gcc
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	# We need this flag to stop gcc from spewing a ton of warnings:
	# https://stackoverflow.com/questions/72016582/gcc-11-warning-wstringop-overflow-when-using-parameter-of-type-char-str100-an
	CFLAGS="-O2 ${CFLAGS}"
	build_line "Updating CFLAGS=${CFLAGS}"
}

do_check() {
	make check
}
