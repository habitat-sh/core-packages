program="tcl"

pkg_name="tcl-stage1"
pkg_origin="core"
pkg_version="8.6.11"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Tool Command Language -- A dynamic programming language."
pkg_upstream_url="http://tcl.sourceforge.net/"
pkg_license=('TCL')
pkg_source="http://downloads.sourceforge.net/sourceforge/${program}/${program}${pkg_version}-src.tar.gz"
pkg_shasum="8c0486668586672c5693d7d95817cb05a18c5ecca2f40e2836b9578064088258"
pkg_dirname="${program}${pkg_version}"
pkg_deps=(
	core/glibc
	core/gcc-libs-stage1
	core/tzdata
)
pkg_build_deps=(
	core/gcc-stage1-with-glibc
	core/zlib-stage1
	core/build-tools-util-linux
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	# Link libgcc_s so that libpthread works
	export LDFLAGS="-lgcc_s ${LDFLAGS}"

	build_line "Setting LDFLAGS=${LDFLAGS}"
}

do_build() {
	pushd unix >/dev/null || exit 1

	./configure \
		--prefix="$pkg_prefix" \
		--enable-threads

	make

	# The Tcl package expects that its source tree is preserved so that
	# packages depending on it for their compilation can utilize it. These sed
	# remove the references to the build directory and replace them with more
	# reasonable system-wide locations.
	#
	# Thanks to: https://clfs.org/~kb0iic/lfs-systemd/chapter08/tcl.html
	local srcdir
	local tdbcver
	local itclver

	srcdir=$(abspath ..)
	tdbcver="tdbc1.1.2"
	itclver="itcl4.2.1"

	sed \
		-e "s#$srcdir/unix#$pkg_prefix/lib#" \
		-e "s#$srcdir#$pkg_prefix/include#" \
		-i tclConfig.sh
	sed \
		-e "s#$srcdir/unix/pkgs/$tdbcver#$pkg_prefix/lib/$tdbcver#" \
		-e "s#$srcdir/pkgs/$tdbcver/generic#$pkg_prefix/include#" \
		-e "s#$srcdir/pkgs/$tdbcver/library#$pkg_prefix/lib/tcl${pkg_version%.?}#" \
		-e "s#$srcdir/pkgs/$tdbcver#$pkg_prefix/include#" \
		-i pkgs/$tdbcver/tdbcConfig.sh
	sed \
		-e "s#$srcdir/unix/pkgs/$itclver#$pkg_prefix/lib/$itclver#" \
		-e "s#$srcdir/pkgs/$itclver/generic#$pkg_prefix/include#" \
		-e "s#$srcdir/pkgs/$itclver#$pkg_prefix/include#" \
		-i pkgs/$itclver/itclConfig.sh

	popd >/dev/null || exit 1
}

do_check() {
	pushd unix >/dev/null || exit 1
	# Set timezone so some test cases pass
	TZ="UTC" make test
	popd >/dev/null || exit 1
}

do_install() {
	pushd unix >/dev/null || exit 1

	make install
	make install-private-headers

	# Many packages expect a file named tclsh, so create a symlink
	ln -sfv "tclsh${pkg_version%.??}" "$pkg_prefix/bin/tclsh"

	chmod -v 755 "$pkg_prefix/lib/libtcl${pkg_version%.??}.so"
	ln -sfv "libtcl${pkg_version%.??}.so" "$pkg_prefix/lib/libtcl.so"

	# Install license file
	install -Dm644 ../license.terms "${pkg_prefix}/share/licenses/LICENSE"

	popd >/dev/null || exit 1
}
