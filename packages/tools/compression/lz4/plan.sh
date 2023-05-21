pkg_name="lz4"
pkg_origin="core"
pkg_version="1.9.3"
# https://github.com/lz4/lz4/blob/v1.9.4/LICENSE
pkg_license=('BSD-2-Clause' 'GPL-2.0-or-later')
pkg_source="https://github.com/lz4/lz4/archive/refs/tags/v${pkg_version}.tar.gz"
pkg_upstream_url="https://lz4.github.io/lz4/"
pkg_description=" Very fast lossless compression algorithm, providing compression speed \
at 400 MB/s per core, with near-linear scalability for multi-threaded \
applications. It also features an extremely fast decoder, with speed in \
multiple GB/s per core, typically reaching RAM speed limits on \
multi-core systems."
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_shasum="030644df4611007ff7dc962d981f390361e6c97a34e5cbc393ddfbe019ffe2c1"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
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
