program="binutils"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-binutils"
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
	core/build-tools-glibc
	core/build-tools-bash-static
	core/hab-ld-wrapper
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

	build_line "Setting HAB_LD_RUN_PATH=${HAB_LD_RUN_PATH}"
	build_line "Setting LDFLAGS_FOR_BUILD=${LDFLAGS_FOR_BUILD}"
	build_line "Setting CFLAGS_FOR_BUILD=${CFLAGS_FOR_BUILD}"
	build_line "Setting CPPFLAGS_FOR_BUILD=${CPPFLAGS_FOR_BUILD}"
	build_line "Setting CXXFLAGS_FOR_BUILD=${CXXFLAGS_FOR_BUILD}"
	build_line "Unsetting LD_RUN_PATH"
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
	local binary
	local env_prefix
	local shell
	local hab_ld_wrapper
	local wrapper_binary
	local actual_binary

	binary="$1"
	env_prefix="BUILD_TOOLS_BINUTILS"
	shell="$(pkg_path_for build-tools-bash-static)"
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
