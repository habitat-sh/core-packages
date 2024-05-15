program="binutils"

pkg_name="build-tools-binutils"
pkg_origin="core"
pkg_version="2.42"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU Binary Utilities, or binutils, are a set of programming tools for \
creating and managing binary programs, object files, libraries, profile data, \
and assembly source code.\
"
pkg_upstream_url="https://www.gnu.org/software/binutils/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.bz2"
pkg_shasum="aa54850ebda5064c72cd4ec2d9b056c294252991486350d9a97ab2a6dfdfaf12"
pkg_dirname="${program}-${pkg_version}"
pkg_bin_dirs=(
	bin
)
pkg_lib_dirs=(
	lib
)

pkg_build_deps=(
	core/build-tools-clang
	core/build-tools-coreutils
	core/build-tools-patch
	core/build-tools-sed
)

do_prepare() {

	# We don't want to search for libraries in system directories such as `/lib`,
	# `/usr/local/lib`, etc. This prevents us breaking out of habitat.
	echo 'NATIVE_LIB_DIRS=' >>ld/configure.tgt

	# Replace dynamic link with libfl from flex with a static link so that
	# we don't need to include the flex package at runtime
	for f in binutils/configure gas/configure ld/configure; do
		sed -i "$f" -e 's|-lfl|-l:libfl.a|'
	done

	# Use symlinks instead of hard links to save space (otherwise `strip(1)`
	# needs to process each hard link seperately)
	for f in binutils/Makefile.in gas/Makefile.in ld/Makefile.in gold/Makefile.in; do
		sed -i "$f" -e 's|ln |ln -s |'
	done
}

do_build() {
	# We need to patch binutils 2.37 because of a known issue that causes a "malformed archive"
	# error when linking certain Node.js object files. The patch fixes this issue by modifying
	# the way `ld` processes archive files.
	# This patch should be removed once we upgrade binutils to a later version.
	# Bug Report: https://sourceware.org/bugzilla/show_bug.cgi?id=28138
	patch -p0 <"$PLAN_CONTEXT/malformarchive-linking-fix.patch"
	./configure \
		--prefix=$pkg_prefix \
		--disable-gold \
		--enable-gprofng=no \
		--enable-ld=default \
		--enable-shared \
		--enable-plugins \
		--enable-deterministic-archives \
		--disable-werror \
		--enable-threads \
		--enable-new-dtags \
		--enable-64-bit-bfd \
		--with-system-zlib

	make tooldir="${pkg_prefix}" V=1
}

do_check() {
	make -k check
}

# skip stripping of binaries
do_strip() {
	return 0
}

do_install() {
	make tooldir="${pkg_prefix}" install
	# Remove unnecessary binaries
	rm -v "${pkg_prefix:?}"/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.{a,la}
}