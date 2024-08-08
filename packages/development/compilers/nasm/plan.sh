pkg_name=nasm
pkg_origin=core
pkg_version="2.16.03"
pkg_description="The Netwide Assembler, NASM, is an 80x86 and x86-64 assembler designed for portability and modularity."
pkg_upstream_url=http://www.nasm.us/
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('BSD-2-Clause')
pkg_source="https://www.nasm.us/pub/nasm/releasebuilds/${pkg_version}/nasm-${pkg_version}.tar.gz"
pkg_shasum="5bc940dd8a4245686976a8f7e96ba9340a0915f2d5b88356874890e207bdb581"

pkg_deps=(
    core/glibc
)
pkg_build_deps=(
    core/gcc
    core/make
)

pkg_bin_dirs=(bin)