program=numaactl
pkg_origin=core
pkg_name=numactl
pkg_version=2.0.18
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source=https://github.com/numactl/numactl/archive/v${pkg_version}.tar.gz
pkg_shasum=8cd6c13f3096e9c2293c1d732f56e2aa37a7ada1a98deed3fac7bd6da1aaaaf6
pkg_deps=(
	core/glibc
	core/gcc-base
)
pkg_build_deps=(
	core/make
	core/autoconf
	core/automake
	core/libtool
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_upstream_url=https://github.com/numactl/numactl
pkg_description="NUMA support for Linux http://oss.sgi.com/projects/libnuma/"

do_prepare() {
  ACLOCAL_PATH="$ACLOCAL_PATH:$(pkg_path_for core/libtool)/share/aclocal"
  export ACLOCAL_PATH

  autoreconf -vfi
}
