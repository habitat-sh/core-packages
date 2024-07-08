program=libpcap
pkg_name=libpcap
pkg_origin=core
pkg_version=1.10.4
pkg_description="A portable C/C++ library for network traffic capture."
pkg_upstream_url="http://www.tcpdump.org/"
pkg_license=('')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="http://www.tcpdump.org/release/libpcap-${pkg_version}.tar.gz"
pkg_shasum=ed19a0383fad72e3ad435fd239d7cd80d64916b87269550159d20e47160ebe5f
pkg_deps=(core/glibc)
pkg_build_deps=(
	core/gcc
	core/make
	core/flex
	core/bison
	core/m4
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
  ./configure --prefix="$pkg_prefix" --with-pcap=linux
  make -j "$(nproc)"
}

do_check() {
  make tests
}
