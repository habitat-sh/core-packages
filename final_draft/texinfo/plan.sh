program="texinfo"
pkg_name="build-tools-texinfo"
pkg_origin="core"
pkg_version="6.8"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Texinfo is the official documentation format of the GNU project. It was \
invented by Richard Stallman and Bob Chassell many years ago, loosely based on \
Brian Reid's Scribe and other formatting languages of the time. It is used by \
many non-GNU projects as well.\
"
pkg_upstream_url="http://www.gnu.org/software/texinfo/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/$program/${program}-${pkg_version}.tar.xz"
pkg_shasum="8eb753ed28bca21f8f56c1a180362aed789229bd62fff58bf8368e9beb59fec4"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/build-tools-perl
	core/build-tools-glibc
	core/build-tools-bash-static
)
pkg_build_deps=(
	core/gcc
)
pkg_bin_dirs=(bin)

do_build() {
	./configure --prefix="$pkg_prefix"
	make
}
do_install() {
	make install

	# Fix scripts
	fix_interpreter "${pkg_prefix}/bin/*" core/build-tools-bash-static bin/sh
}
do_check() {
	make check
}
