pkg_origin=core
pkg_name="userspace-rcu"
pkg_version="0.14.0"
pkg_description="liburcu is a LGPLv2.1 userspace RCU (read-copy-update) library.
  This data synchronization library provides read-side access which scales
  linearly with the number of cores."
pkg_upstream_url=http://liburcu.org/
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('LGPL-2.1-or-later' 'GPL-2.0-only')
pkg_source=http://www.lttng.org/files/urcu/$pkg_name-$pkg_version.tar.bz2
pkg_shasum="ca43bf261d4d392cff20dfae440836603bf009fce24fdc9b2697d837a2239d4f"
pkg_deps=(
  core/glibc
)
pkg_build_deps=(
  core/gcc
  core/make
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
