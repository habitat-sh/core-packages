# Disable shellcheck that would require quotes around pkg_name
# shellcheck disable=SC2209
pkg_name="patch"
pkg_origin="core"
pkg_version="2.7.6"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Patch takes a patch file containing a difference listing produced by the diff \
program and applies those differences to one or more original files, producing \
patched versions.\
"
pkg_upstream_url="https://www.gnu.org/software/patch/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/$pkg_name/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="ac610bda97abe0d9f6b7c963255a11dcb196c25e337c61f94e4778d632f1d8fd"
pkg_deps=(
	core/glibc
	core/attr
)
pkg_build_deps=(
	core/coreutils
	core/make
	core/gcc
	core/build-tools-sed
	core/build-tools-diffutils
)
pkg_bin_dirs=(bin)

do_check() {
	make check
}
