pkg_name="libuv"
pkg_origin="core"
pkg_version="1.44.2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('MIT')
pkg_upstream_url="http://libuv.org/"
pkg_description="libuv is a multi-platform support library with a focus on asynchronous I/O."
pkg_source="https://github.com/libuv/libuv/archive/v${pkg_version}.tar.gz"
pkg_shasum="e6e2ba8b4c349a4182a33370bb9be5e23c51b32efb9b9e209d0e8556b73a48da"
pkg_deps=(core/glibc)
pkg_build_deps=(
	core/autoconf
	core/automake
	core/coreutils
	core/gcc
	core/libtool
	core/m4
	core/make
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
