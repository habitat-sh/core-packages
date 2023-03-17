program="xxHash"
pkg_name="xxhash"
pkg_origin="core"
pkg_version="0.8.1"
pkg_description="xxHash is an Extremely fast Hash algorithm, running at RAM speed limits. \
It successfully completes the SMHasher test suite which evaluates \
collision, dispersion and randomness qualities of hash functions. Code is \
highly portable, and hashes are identical on all platforms (little / big endian)"
pkg_upstream_url="https://github.com/Cyan4973/xxHash"
pkg_license=('BSD-2-Clause' 'GPL-2.0-only')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://github.com/Cyan4973/xxHash/archive/refs/tags/v${pkg_version}.tar.gz"
pkg_shasum="3bb6b7d6f30c591dd65aaaff1c8b7a5b94d81687998ca9400082c739a690436c"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
	core/make
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	make PREFIX="${pkg_prefix}"
}

do_check() {
	make PREFIX="${pkg_prefix}" check
}

do_install() {
	make PREFIX="${pkg_prefix}" install
	# The make install step seems to put the wrong symlink into
	# the final man pages, we manually fix them here
	ln -sf xxhsum.1 "${pkg_prefix}/share/man/man1/xxh128sum.1"
	ln -sf xxhsum.1 "${pkg_prefix}/share/man/man1/xxh64sum.1"
	ln -sf xxhsum.1 "${pkg_prefix}/share/man/man1/xxh32sum.1"
}
