program="tcl"
pkg_name="build-tools-tcl"
pkg_origin="core"
pkg_version="8.6.12"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Tool Command Language -- A dynamic programming language."
pkg_upstream_url="http://tcl.sourceforge.net/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="http://downloads.sourceforge.net/sourceforge/${program}/${program}${pkg_version}-src.tar.gz"
pkg_shasum="26c995dd0f167e48b11961d891ee555f680c175f7173ff8cb829f4ebcde4c1a6"
pkg_dirname="${program}${pkg_version}"

pkg_build_deps=(
	core/build-tools-gcc
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	SRCDIR=${CACHE_PATH}

	pushd unix || exit 1

	./configure \
		--prefix="$pkg_prefix" \
		--mandir="${pkg_prefix}/share/man"
	make

	# The Tcl package expects that its source tree is preserved so that
	# packages depending on it for their compilation can utilize it. These sed
	# remove the references to the build directory and replace them with more
	# reasonable system-wide locations.

	sed -e "s|$SRCDIR/unix|$pkg_prefix/lib|" \
		-e "s|$SRCDIR|$pkg_prefix/include|" \
		-i tclConfig.sh

	sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.3|$pkg_prefix/lib/tdbc1.1.3|" \
		-e "s|$SRCDIR/pkgs/tdbc1.1.3/generic|$pkg_prefix/include|" \
		-e "s|$SRCDIR/pkgs/tdbc1.1.3/library|$pkg_prefix/lib/tcl8.6|" \
		-e "s|$SRCDIR/pkgs/tdbc1.1.3|$pkg_prefix/include|" \
		-i pkgs/tdbc1.1.3/tdbcConfig.sh

	sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.2|$pkg_prefix/lib/itcl4.2.2|" \
		-e "s|$SRCDIR/pkgs/itcl4.2.2/generic|$pkg_prefix/include|" \
		-e "s|$SRCDIR/pkgs/itcl4.2.2|$pkg_prefix/include|" \
		-i pkgs/itcl4.2.2/itclConfig.sh

	unset SRCDIR

	popd >/dev/null || exit 1
}

do_check() {
	pushd unix || exit 1

	make test

	popd >/dev/null || exit 1
}

do_install() {
	pushd unix || exit 1

	make install
	make install-private-headers

	ln -sfv tclsh8.6 ${pkg_prefix}/bin/tclsh

	popd >/dev/null || exit 1
}
