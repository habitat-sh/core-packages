program="binutils"

pkg_name="binutils-stage0"
pkg_origin="core"
pkg_version="2.37"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU Binary Utilities, or binutils, are a set of programming tools for \
creating and managing binary programs, object files, libraries, profile data, \
and assembly source code.\
"
pkg_upstream_url="https://www.gnu.org/software/binutils/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.bz2"
pkg_shasum="67fc1a4030d08ee877a4867d3dcab35828148f87e1fd05da6db585ed5a166bd4"
pkg_dirname="${program}-${pkg_version}"
pkg_bin_dirs=(
	bin
)
pkg_lib_dirs=(
	lib
)

pkg_deps=(
	core/glibc-stage0
	core/hab-ld-wrapper
)
pkg_build_deps=(
	core/gcc-stage0
	core/zlib-stage0
	core/bzip2-stage0
	core/build-tools-texinfo
	core/build-tools-perl
	core/build-tools-bison
)

do_prepare() {
	# We don't want to search for libraries in system directories such as `/lib`,
	# `/usr/local/lib`, etc. This prevents us breaking out of habitat.
	echo 'NATIVE_LIB_DIRS=' >>ld/configure.tgt

	# Use symlinks instead of hard links to save space (otherwise `strip(1)`
	# needs to process each hard link seperately)
	for f in binutils/Makefile.in gas/Makefile.in ld/Makefile.in gold/Makefile.in; do
		sed -i "$f" -e 's|ln |ln -s |'
	done

	# We need to patch binutils 2.37 because of a known issue that causes a "malformed archive"
	# error when linking certain Node.js object files. The patch fixes this issue by modifying
	# the way `ld` processes archive files.
	# This patch should be removed once we upgrade binutils to a later version.
	# Bug Report: https://sourceware.org/bugzilla/show_bug.cgi?id=28138
	patch -p0 <"$PLAN_CONTEXT/malformarchive-linking-fix.patch"
}

do_build() {
	./configure \
		--prefix=$pkg_prefix \
		--enable-ld=default \
		--enable-gprofng=no \
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
	wrap_binary "ld"
	wrap_binary "ld.bfd"
	# Remove unnecessary binaries
	rm -v "${pkg_prefix:?}"/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.{a,la}
}

wrap_binary() {
	local binary
	local env_prefix
	local hab_ld_wrapper
	local wrapper_binary
	local actual_binary

	binary="$1"
	env_prefix="BINUTILS_STAGE0"
	hab_ld_wrapper="$(pkg_path_for hab-ld-wrapper)"
	wrapper_binary="$pkg_prefix/bin/$binary"
	actual_binary="$pkg_prefix/bin/$binary.real"

	build_line "Adding wrapper for $binary"
	mv -v "$wrapper_binary" "$actual_binary"

	sed "$PLAN_CONTEXT/ld-wrapper.sh" \
		-e "s^@env_prefix@^${env_prefix}^g" \
		-e "s^@wrapper@^${hab_ld_wrapper}/bin/hab-ld-wrapper^g" \
		-e "s^@program@^${actual_binary}^g" \
		>"$wrapper_binary"

	chmod 755 "$wrapper_binary"
}
