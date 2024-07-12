program=libaio
pkg_name=libaio
pkg_origin=core
pkg_version=0.3.113
pkg_license=('LGPL-2.1-or-later')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description='The libaio package is an asynchronous I/O facility ("async I/O", or "aio") that has a richer API and capability set than the simple POSIX async I/O facility. This library, libaio, provides the Linux-native API for async I/O. The POSIX async I/O facility requires this library in order to provide kernel-accelerated async I/O capabilities, as do applications which require the Linux-native async I/O API.'
pkg_upstream_url="http://lse.sourceforge.net/io/aio.html"
pkg_source="http://ftp.de.debian.org/debian/pool/main/liba/${pkg_name}/${pkg_name}_${pkg_version}.orig.tar.gz"
pkg_shasum=2c44d1c5fd0d43752287c9ae1eb9c023f04ef848ea8d4aafa46e9aedb678200b
pkg_filename="${pkg_name}-${pkg_version}.tar.gz"
pkg_build_deps=(
  core/coreutils
  core/gcc 
  core/make
)
pkg_deps=(core/glibc)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
  make
}

do_install() {
  make install prefix="${pkg_prefix}"
}
