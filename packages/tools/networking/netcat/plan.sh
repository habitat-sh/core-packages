program=netcat
pkg_name=netcat
pkg_origin=core
pkg_version=0.7.1
pkg_description="GNU rewrite of the OpenBSD netcat/nc package"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_upstream_url=http://netcat.sourceforge.net/
pkg_license=('GPL-2.0')
pkg_source=http://downloads.sourceforge.net/sourceforge/$pkg_name/${pkg_name}-${pkg_version}.tar.gz
pkg_shasum=30719c9a4ffbcf15676b8f528233ccc54ee6cba96cb4590975f5fd60c68a066f
pkg_deps=(core/glibc)
pkg_build_deps=(
  core/gcc
  core/make
)
pkg_bin_dirs=(bin)
