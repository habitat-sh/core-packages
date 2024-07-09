#!/bin/bash
program=popt
pkg_name=popt
pkg_origin=core
pkg_version=1.19
pkg_description="Popt is a C library for parsing command line parameters"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("MIT")
pkg_upstream_url=http://rpm5.org
pkg_source=https://ftp.osuosl.org/pub/rpm/${pkg_name}/releases/${pkg_name}-1.x/${pkg_name}-${pkg_version}.tar.gz
pkg_shasum=c25a4838fc8e4c1c8aacb8bd620edb3084a3d63bf8987fdad3ca2758c63240f9
pkg_deps=(core/glibc)
pkg_build_deps=(
    core/gcc
    core/make
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

