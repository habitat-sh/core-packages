program="acl"

pkg_name="acl"
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

pkg_deps=(
	core/glibc
	core/attr
)

pkg_build_deps=(
	core/gcc
	core/coreutils-stage1
	core/build-tools-bash-static
	core/build-tools-perl
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--docdir="$pkg_prefix/share/doc/acl-2.3.1"
	make
}

do_check() {
	sed -e "s^#\!.*bin/sh^#\!$(pkg_path_for build-tools-bash-static)/bin/sh^" -i "test/make-tree"
	sed -e "s^#\!.*bin/perl^#\!$(pkg_path_for build-tools-perl)/bin/perl^" -i "test/run"
	sed -e "s^#\!.*bin/perl^#\!$(pkg_path_for build-tools-perl)/bin/perl^" -i "test/sort-getfacl-output"
	sed -e "s^#\!.*bin/bash^#\!$(pkg_path_for build-tools-bash-static)/bin/bash^" -i "test/runwrapper"
	make check
}

do_install() {
	make install
}
