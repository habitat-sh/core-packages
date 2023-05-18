program="binutils"

pkg_name="binutils-stage1"
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
	core/glibc
	core/bash-static
	core/hab-ld-wrapper
	core/gcc-libs-stage1
)
pkg_build_deps=(
	core/flex-stage1
	core/gcc-stage1-with-glibc
	core/zlib-stage1
	core/bzip2-stage0
	core/build-tools-texinfo
	core/build-tools-perl
	core/build-tools-make
	core/build-tools-coreutils
	core/build-tools-bison
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
	./configure \
		--prefix=$pkg_prefix \
		--enable-gold=yes \
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
	wrap_binary "ld"
	wrap_binary "ld.bfd"
	# Remove unnecessary binaries
	rm -v "${pkg_prefix:?}"/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.{a,la}
}

wrap_binary() {
	local binary
	local env_prefix
	local shell
	local hab_ld_wrapper
	local wrapper_binary
	local actual_binary

	binary="$1"
	env_prefix="BINUTILS_STAGE1"
	shell="$(pkg_path_for bash-static)"
	hab_ld_wrapper="$(pkg_path_for hab-ld-wrapper)"
	wrapper_binary="$pkg_prefix/bin/$binary"
	actual_binary="$pkg_prefix/bin/$binary.real"

	build_line "Adding wrapper for $binary"
	mv -v "$wrapper_binary" "$actual_binary"

	sed "$PLAN_CONTEXT/ld-wrapper.sh" \
		-e "s^@shell@^${shell}/bin/sh^g" \
		-e "s^@env_prefix@^${env_prefix}^g" \
		-e "s^@wrapper@^${hab_ld_wrapper}/bin/hab-ld-wrapper^g" \
		-e "s^@program@^${actual_binary}^g" \
		>"$wrapper_binary"

	chmod 755 "$wrapper_binary"
}
