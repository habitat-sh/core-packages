program="binutils"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-binutils"
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
	core/build-tools-glibc
	core/build-tools-bash-static
)
pkg_build_deps=(
	core/native-cross-gcc
	core/build-tools-coreutils
	core/build-tools-gawk
	core/build-tools-grep
	core/build-tools-make
	core/build-tools-sed
	core/build-tools-tar
)

do_prepare() {
	# The build process uses the host system's compiler (the build compiler)
	# to compile certain components.
	# To prevent the build compiler/linker from being affected by LD_RUN_PATH,
	# we transfer its value to HAB_LD_RUN_PATH and unset LD_RUN_PATH.
	export HAB_LD_RUN_PATH="${LD_RUN_PATH}"
	unset LD_RUN_PATH

	# By default LDFLAGS, CFLAGS, CPPFLAGS and CXXFLAGS get used by the
	# build compiler. To prevent this we set *FLAGS_FOR_BUILD="" to
	# prevent any interference with the build compiler and linker.
	export LDFLAGS_FOR_BUILD=""
	export CFLAGS_FOR_BUILD=""
	export CPPFLAGS_FOR_BUILD=""
	export CXXFLAGS_FOR_BUILD=""

	# We don't want to search for libraries in system directories such as `/lib`,
	# `/usr/local/lib`, etc. This prevents us breaking out of habitat.
	echo 'NATIVE_LIB_DIRS=' >>ld/configure.tgt

	# Use symlinks instead of hard links to save space (otherwise `strip(1)`
	# needs to process each hard link seperately)
	for f in binutils/Makefile.in gas/Makefile.in ld/Makefile.in gold/Makefile.in; do
		sed -i "$f" -e 's|ln |ln -s |'
	done
}

do_build() {
	./configure \
		--prefix=$pkg_prefix \
		--build="$(./config.guess)" \
		--host="$native_target" \
		--target="$native_target" \
		--disable-nls \
		--enable-shared \
		--enable-gprofng=no \
		--disable-werror \
		--enable-new-dtags \
		--enable-64-bit-bfd
	make V=1
}

do_check() {
	make check
}

# skip stripping of binaries
do_strip() {
	return 0
}

do_install() {
	make install
	wrap_binary "ld.bfd"
	# Remove unnecessary static libraries. We also remove libtool archive
	# files because they interfere with cross compilation.
	rm -v "${pkg_prefix:?}"/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.{a,la}
}

wrap_binary() {
	local bin="$pkg_prefix/bin/$1"
	build_line "Adding wrapper $bin to ${bin}.real"
	mv -v "$bin" "${bin}.real"
	sed "$PLAN_CONTEXT/ld-wrapper.sh" \
		-e "s^@bash@^$(pkg_path_for build-tools-bash-static)/bin/bash^g" \
		-e "s^@program@^${bin}.real^g" \
		>"$bin"
	chmod 755 "$bin"
}
