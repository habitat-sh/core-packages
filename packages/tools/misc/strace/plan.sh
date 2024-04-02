pkg_name="strace"
pkg_origin="core"
pkg_version="6.0"
pkg_license=("GPL-2.0-or-later" "LGPL-2.1-or-later")
pkg_description="strace is a system call tracer for Linux"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_upstream_url=https://strace.io/
pkg_source="https://github.com/strace/strace/releases/download/v${pkg_version}/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum=92d720a666855e9f1c6a11512fd6e99674a82bbfe1442557815f2ce8e1293338
pkg_deps=(
	core/glibc
	core/libunwind
)
pkg_build_deps=(
	core/gcc
)
pkg_bin_dirs=(bin)

do_prepare() {
	# thanks to https://www.linuxquestions.org/questions/showthread.php?p=6222340
	patch -i "${PLAN_CONTEXT}"/000-binutils-wide.patch src/mpers.sh
}

do_build() {
	./configure \
		--prefix="${pkg_prefix}" \
		--enable-mpers=check
	make
}

do_check() {
	make check
}
