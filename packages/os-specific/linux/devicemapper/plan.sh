pkg_name=devicemapper
pkg_origin=core
pkg_version=2.03.26
pkg_description="The Device-mapper is a component of the linux kernel (since version 2.6) that supports logical volume management."
pkg_upstream_url="https://sourceware.org/lvm2/"
pkg_dirname="LVM2.${pkg_version}"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('BSD-2-Clause' 'GPL-2.0-only' 'LGPL-2.1-only')
pkg_source="https://mirrors.kernel.org/sourceware/lvm2/releases/LVM2.${pkg_version}.tgz"
pkg_shasum=72ea8b4f0e1610de5d119296b15ef2a2203431089541dcbebc66361f65fb35f5
pkg_build_deps=(
  core/gcc
  core/make
)
pkg_deps=(
  core/glibc
  core/libaio
  core/bash
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_bin_dirs=(sbin)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
    ./configure --prefix="$pkg_prefix" --enable-pkgconfig
    make
}
do_install() {
	do_default_install
	fix_interpreter "$pkg_prefix/sbin/*" core/bash bin/bash
  fix_interpreter "$pkg_prefix/libexec/*" core/bash bin/bash
}
