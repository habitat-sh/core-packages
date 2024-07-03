program=iptables
pkg_name=iptables
pkg_origin=core
pkg_version=1.8.10
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('GPL-2.0-or-later')
pkg_source="http://netfilter.org/projects/iptables/files/${pkg_name}-${pkg_version}.tar.xz"
pkg_upstream_url="http://netfilter.org/projects/iptables"
pkg_description="iptables is the userspace command line program used to configure the \
  Linux 2.4.x and later packet filtering ruleset"
pkg_shasum=5cc255c189356e317d070755ce9371eb63a1b783c34498fb8c30264f3cc59c9c
pkg_deps=(core/glibc)
pkg_build_deps=(
  core/make
  core/gcc
  core/bison
  core/flex
)
pkg_bin_dirs=(bin sbin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)

do_build() {
  ./configure \
    --prefix="${pkg_prefix}" \
    --enable-devel \
    --disable-static \
    --enable-shared \
    --enable-libipq \
    --disable-nftables \
    --with-xtlibdir="${pkg_prefix}/lib/xtlibs"
  make
}
