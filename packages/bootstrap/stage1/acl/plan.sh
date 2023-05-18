program="acl"

pkg_name="acl-stage1"
pkg_origin="core"
pkg_version="2.3.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Commands for Manipulating POSIX Access Control Lists.
"
pkg_upstream_url="https://savannah.nongnu.org/projects/acl/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="http://download.savannah.gnu.org/releases/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="760c61c68901b37fdd5eefeeaf4c0c7a26bdfdd8ac747a1edff1ce0e243c11af"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/gcc
	core/attr-stage1
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--docdir="$pkg_prefix/share/doc/acl-2.3.1" \
		--enable-static \
		--disable-shared
	make
}

do_install() {
	make install

	# Remove unnecessary components not required to build static coreutils
	rm -rfv "${pkg_prefix:?}"/bin
	rm -v "${pkg_prefix:?}"/lib/*.la
	rm -rfv "${pkg_prefix:?}"/lib/pkgconfig
}
