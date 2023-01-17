pkg_name="lz4"
pkg_origin="core"
pkg_version="1.9.4"
pkg_license=('BSD-2-Clause' 'GPL-2.0-or-later')
pkg_source="https://github.com/lz4/lz4/archive/refs/tags/v${pkg_version}.tar.gz"
pkg_upstream_url="https://lz4.github.io/lz4/"
pkg_description=" Very fast lossless compression algorithm, providing compression speed \
at 400 MB/s per core, with near-linear scalability for multi-threaded \
applications. It also features an extremely fast decoder, with speed in \
multiple GB/s per core, typically reaching RAM speed limits on \
multi-core systems."
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_shasum="0b0e3aa07c8c063ddf40b082bdf7e37a1562bda40a0ff5272957f3e987e0e54b"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/coreutils
	core/gcc
	core/grep
	core/make
	core/sed
	core/python
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_check() {
	build_line "Running tests, this may take a while"
	make check &>lz4-check.log
	make test &>lz4-test.log
	build_line "Tests completed successfully!"
}

do_build() {
	make \
		PREFIX="${pkg_prefix}" \
		-j"$(nproc)"
}

do_install() {
	make \
		PREFIX="${pkg_prefix}" \
		install
}
