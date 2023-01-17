program="zeromq"
pkg_name="zeromq"
pkg_origin="core"
pkg_version="4.3.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="ZeroMQ core engine in C++, implements ZMTP/3.1"
pkg_upstream_url="http://zeromq.org"
pkg_license=('LGPL-3.0-only')
pkg_source="https://github.com/zeromq/libzmq/releases/download/v${pkg_version}/${program}-${pkg_version}.tar.gz"
pkg_shasum="c593001a89f5a85dd2ddf564805deb860e02471171b3f204944857336295c3e5"
pkg_deps=(
	core/glibc
	core/gcc-libs
)
pkg_build_deps=(
	core/coreutils
	core/gawk
	core/gcc
	core/grep
	core/libsodium
	core/make
	core/pkg-config
	core/shadow
	core/valgrind-stage1
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	patch -p0 <"$PLAN_CONTEXT"/tests_fix.patch

	# This flag is required for gcc 12 to be able to compile
	# the source with no warnings which stop compilation
	CXXFLAGS="-std=c++14 ${CXXFLAGS}"
	export CXXFLAGS
	build_line "Updating CXXFLAGS=${CXXFLAGS}"
}

do_build() {
	# We need to enable libsodium explicitly.
	# We also need to disable curve which will prevent
	# the usage of the internal tweetnacl because libsodium
	# already provides the same capability.
	# Enabling both of them leads to test failures
	# https://github.com/zeromq/libzmq/issues/2190
	./configure \
		--prefix="${pkg_prefix}" \
		--with-libsodium \
		--disable-curve
	make
}

do_check() {
	make check
}
