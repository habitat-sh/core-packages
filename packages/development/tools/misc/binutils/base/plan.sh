program="binutils"

pkg_name="binutils-base"
pkg_origin="core"
pkg_version="2.39"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU Binary Utilities, or binutils, are a set of programming tools for \
creating and managing binary programs, object files, libraries, profile data, \
and assembly source code.\
"
pkg_upstream_url="https://www.gnu.org/software/binutils/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.bz2"
pkg_shasum="da24a84fef220102dd24042df06fdea851c2614a5377f86effa28f33b7b16148"
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
)

pkg_build_deps=(
	core/gcc-base
	core/gcc-libs
	core/binutils-stage1
	core/dejagnu-stage1
	core/flex-stage1
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

	sed -i /hab/cache/src/binutils-2.39/ld/configure -e 's|-lfl|-l:libfl.a|'
	# Use symlinks instead of hard links to save space (otherwise `strip(1)`
	# needs to process each hard link seperately)
	for f in binutils/Makefile.in gas/Makefile.in ld/Makefile.in gold/Makefile.in; do
		sed -i "$f" -e 's|ln |ln -s |'
	done
}

do_build() {
	./configure \
		--prefix=$pkg_prefix \
		--enable-gold \
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
	wrap_binary "ld.bfd"
	# Remove unnecessary binaries
	rm -v "${pkg_prefix:?}"/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.{a,la}
}

wrap_binary() {
	local bin="$pkg_prefix/bin/$1"
	build_line "Adding wrapper $bin to ${bin}.real"
	mv -v "$bin" "${bin}.real"
	sed "$PLAN_CONTEXT/ld-wrapper.sh" \
		-e "s^@bash@^$(pkg_path_for bash-static)/bin/bash^g" \
		-e "s^@program@^${bin}.real^g" \
		>"$bin"
	chmod 755 "$bin"
}
