pkg_name="libuv"
pkg_origin="core"
pkg_version="1.42.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('MIT')
pkg_upstream_url="http://libuv.org/"
pkg_description="libuv is a multi-platform support library with a focus on asynchronous I/O."
pkg_source="https://github.com/libuv/libuv/archive/v${pkg_version}.tar.gz"
pkg_shasum="371e5419708f6aaeb8656671f89400b92a9bba6443369af1bb70bcd6e4b3c764"
pkg_deps=(core/glibc)
pkg_build_deps=(
	core/autoconf
	core/automake
	core/gcc
	core/libtool
	core/shadow
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./autogen.sh
	./configure \
		--prefix="${pkg_prefix}"
	make -j"$(nproc)"
}

do_check() {
	# Change ownership of the folder to the hab user so that tests can compile
	chown -R hab .

	# Compile and run tests as the hab user
	su hab -c "PATH=$PATH make check"

}
