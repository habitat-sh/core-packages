program="tcl"

pkg_name="tcl-stage1"
pkg_origin="core"
pkg_version="8.6.12"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Tool Command Language -- A dynamic programming language."
pkg_upstream_url="http://tcl.sourceforge.net/"
pkg_license=('custom')
pkg_source="http://downloads.sourceforge.net/sourceforge/${program}/${program}${pkg_version}-src.tar.gz"
pkg_shasum="26c995dd0f167e48b11961d891ee555f680c175f7173ff8cb829f4ebcde4c1a6"
pkg_dirname="${program}${pkg_version}"
pkg_deps=(
	core/gcc-libs-stage1
	core/glibc-stage0
	core/zlib-stage0
	core/tzdata
	core/build-tools-bash-static
)
pkg_build_deps=(
	core/gcc-stage1
	core/build-tools-coreutils
	core/build-tools-diffutils
	core/build-tools-patch
	core/build-tools-make
	core/build-tools-sed
	core/build-tools-util-linux
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	pushd unix >/dev/null || exit 1

	# Link libgcc_s so that libpthread works
	export LDFLAGS="-lgcc_s ${LDFLAGS}"

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
	srcdir=$(abspath ..)
	local tdbcver=tdbc1.1.3
	local itclver=itcl4.2.2
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

	# Fix scripts
	fix_interpreter "${pkg_prefix}"/bin/sqlite3_analyzer core/build-tools-bash-static bin/sh

	# Install license file
	install -Dm644 ../license.terms "${pkg_prefix}/share/licenses/LICENSE"

	popd >/dev/null || exit 1
}
