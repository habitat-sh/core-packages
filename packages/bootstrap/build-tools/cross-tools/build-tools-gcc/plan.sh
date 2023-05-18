program="gcc"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"
glibc_version="2.34"

pkg_name="build-tools-gcc"
pkg_origin="core"
pkg_version="9.4.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU Compiler Collection (GCC) is a compiler system produced by the GNU \
Project supporting various programming languages. GCC is a key component of \
the GNU toolchain and the standard compiler for most Unix-like operating \
systems.\
"
pkg_upstream_url="https://gcc.gnu.org/"
pkg_license=('GPL-3.0-or-later WITH GCC-exception-3.1' 'LGPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/$program/${program}-${pkg_version}/${program}-${pkg_version}.tar.xz"
pkg_shasum="c95da32f440378d7751dd95533186f7fc05ceb4fb65eb5b85234e6299eb9838e"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/build-tools-binutils
	core/build-tools-glibc
	core/build-tools-gmp
	core/build-tools-isl
	core/build-tools-mpfr
	core/build-tools-libmpc
	core/build-tools-bash-static
	core/hab-cc-wrapper
)

pkg_build_deps=(
	core/native-cross-gcc
	core/build-tools-coreutils
	core/build-tools-gawk
	core/build-tools-grep
	core/build-tools-linux-headers
	core/build-tools-make
	core/build-tools-patch
	core/build-tools-sed
	core/build-tools-tar
	core/build-tools-xz
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib lib64)

do_prepare() {
	local dynamic_linker
	local cleaned_path

	case $native_target in
	aarch64-hab-linux-gnu)
		dynamic_linker="$(pkg_path_for build-tools-glibc)/lib/ld-linux-aarch64.so.1"
		;;
	x86_64-hab-linux-gnu)
		dynamic_linker="$(pkg_path_for build-tools-glibc)/lib/ld-linux-x86-64.so.2"
		;;
	esac

	sed '/thread_header =/s/@.*@/gthr-posix.h/' -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

	# The build process uses the host system's compiler (the build compiler)
	# to compile certain components.
	# By default LDFLAGS, CFLAGS, CPPFLAGS and CXXFLAGS get used by the
	# build compiler. To prevent this we set *FLAGS_FOR_BUILD="" to
	# prevent any interference with the build compiler and linker.
	export LDFLAGS_FOR_BUILD=""
	export CFLAGS_FOR_BUILD=""
	export CPPFLAGS_FOR_BUILD=""
	export CXXFLAGS_FOR_BUILD=""

	# We transfer all the flags from the default variable to the target's variables
	# so that they correctly configure the intermediate target compiler
	export LDFLAGS_FOR_TARGET="-L${SRC_PATH}/build/${native_target}/libgcc ${LDFLAGS} -Wl,-dynamic-linker=${dynamic_linker}"
	export CPPFLAGS_FOR_TARGET="${CPPFLAGS}"
	export CFLAGS_FOR_TARGET="${CFLAGS}"
	export CXXFLAGS_FOR_TARGET="${CXXFLAGS}"

	# We unset all remaining flags that will interfere with the host compiler
	unset LDFLAGS
	unset CPPFLAGS
	unset CFLAGS
	unset CXXFLAGS

	# To prevent the build compiler/linker from being affected by LD_RUN_PATH,
	# we transfer its value to HAB_LD_RUN_PATH and unset LD_RUN_PATH.
	# This allows the native-cross-binutils linker to correctly put rpath
	# entries for glibc, isl, gmp, etc.
	export HAB_LD_RUN_PATH="${LD_RUN_PATH}"
	unset LD_RUN_PATH

	# Remove the gcc and binutils binary directory from the PATH, otherwise the build process
	# will begin to pick up the just built compilers and the built-tools-binutils linker for compilation
	cleaned_path=$(path_remove "${PATH}" "${pkg_prefix}/bin")
	cleaned_path=$(path_remove "${cleaned_path}" "$(pkg_path_for build-tools-binutils)/bin")
	export PATH="${cleaned_path}"

	build_line "Setting LDFLAGS_FOR_BUILD=${LDFLAGS_FOR_BUILD}"
	build_line "Setting CFLAGS_FOR_BUILD=${CFLAGS_FOR_BUILD}"
	build_line "Setting CPPFLAGS_FOR_BUILD=${CPPFLAGS_FOR_BUILD}"
	build_line "Setting CXXFLAGS_FOR_BUILD=${CXXFLAGS_FOR_BUILD}"
	build_line "Setting LDFLAGS_FOR_TARGET=${LDFLAGS_FOR_TARGET}"
	build_line "Setting CPPFLAGS_FOR_TARGET=${CPPFLAGS_FOR_TARGET}"
	build_line "Setting CFLAGS_FOR_TARGET=${CFLAGS_FOR_TARGET}"
	build_line "Setting CXXFLAGS_FOR_TARGET=${CXXFLAGS_FOR_TARGET}"
	build_line "Setting HAB_LD_RUN_PATH=${HAB_LD_RUN_PATH}"
	build_line "Unsetting LDFLAGS"
	build_line "Unsetting CPPFLAGS"
	build_line "Unsetting CFLAGS"
	build_line "Unsetting CXXFLAGS"
	build_line "Unsetting LD_RUN_PATH"
	build_line "Updated PATH=${PATH}"

	# Tell gcc not to look under the default `/lib/` and `/usr/lib/` directories
	# for libraries
	#
	# Thanks to: https://github.com/NixOS/nixpkgs/blob/release-15.09/pkgs/development/compilers/gcc/no-sys-dirs.patch
	# shellcheck disable=SC2002
	patch -p1 <"$PLAN_CONTEXT/no-sys-dirs.patch"

}

do_build() {
	mkdir -v build
	pushd build || exit 1

	../configure \
		--prefix="$pkg_prefix" \
		--build="$(../config.guess)" \
		--host="$native_target" \
		--target="$native_target" \
		--with-gmp="$(pkg_path_for build-tools-gmp)" \
		--with-isl="$(pkg_path_for build-tools-isl)" \
		--with-mpfr="$(pkg_path_for build-tools-mpfr)" \
		--with-mpc="$(pkg_path_for build-tools-libmpc)" \
		--with-build-sysroot="" \
		--with-sysroot="" \
		--with-native-system-header-dir="$(pkg_path_for build-tools-glibc)/include" \
		--with-glibc-version="$glibc_version" \
		--enable-initfini-array \
		--enable-default-pie \
		--enable-default-ssp \
		--disable-nls \
		--disable-multilib \
		--disable-decimal-float \
		--disable-libatomic \
		--disable-libgomp \
		--disable-libquadmath \
		--disable-libssp \
		--disable-libvtv \
		--enable-languages=c,c++
	make -j"$(nproc)" --output-sync
	popd || exit 1
}

do_install() {
	pushd build || exit 1
	make install

	# Many packages use the name cc to call the C compiler
	ln -sv gcc "$pkg_prefix/bin/cc"

	wrap_binary "${native_target}-c++"
	wrap_binary "${native_target}-g++"
	wrap_binary "${native_target}-gcc"
	wrap_binary "${native_target}-gcc-${pkg_version}"

	wrap_binary "c++"
	wrap_binary "gcc"
	wrap_binary "g++"
	wrap_binary "cpp"

	popd || exit 1
}

wrap_binary() {
	local binary
	local env_prefix
	local shell
	local hab_cc_wrapper
	local binutils
	local linux_headers
	local libc
	local wrapper_binary
	local actual_binary

	binary="$1"
	env_prefix="BUILD_TOOLS_GCC"
	shell="$(pkg_path_for build-tools-bash-static)"
	hab_cc_wrapper="$(pkg_path_for hab-cc-wrapper)"
	binutils="$(pkg_path_for build-tools-binutils)"
	linux_headers="$(pkg_path_for build-tools-linux-headers)"
	libc="$(pkg_path_for build-tools-glibc)"
	wrapper_binary="$pkg_prefix/bin/$binary"
	actual_binary="$pkg_prefix/bin/$binary.real"

	case $native_target in
	aarch64-hab-linux-gnu)
		dynamic_linker="$libc/lib/ld-linux-aarch64.so.1"
		;;
	x86_64-hab-linux-gnu)
		dynamic_linker="$libc/lib/ld-linux-x86-64.so.2"
		;;
	esac

	build_line "Adding wrapper for $binary"
	mv -v "$wrapper_binary" "$actual_binary"

	sed "$PLAN_CONTEXT/cc-wrapper.sh" \
		-e "s^@shell@^${shell}/bin/sh^g" \
		-e "s^@env_prefix@^${env_prefix}^g" \
		-e "s^@executable_name@^${binary}^g" \
		-e "s^@wrapper@^${hab_cc_wrapper}/bin/hab-cc-wrapper^g" \
		-e "s^@program@^${actual_binary}^g" \
		-e "s^@ld_bin@^${binutils}/${native_target}/bin^g" \
		-e "s^@dynamic_linker@^${dynamic_linker}^g" \
		-e "s^@c_start_files@^${libc}/lib^g" \
		-e "s^@c_std_libs@^${libc}/lib^g" \
		-e "s^@c_std_headers@^${libc}/include:${linux_headers}/include^g" \
		>"$wrapper_binary"

	chmod 755 "$wrapper_binary"
}

# Courtesy https://unix.stackexchange.com/questions/108873/removing-a-directory-from-path
function path_remove {
	local new_path="$1"
	# Delete path by parts so we can never accidentally remove sub paths
	if [ "$new_path" == "$2" ]; then
		new_path=""
	fi
	new_path=${new_path//":$2:"/":"} # delete any instances in the middle
	new_path=${new_path/#"$2:"/}     # delete any instance at the beginning
	new_path=${new_path/%":$2"/}     # delete any instance in the at the end
	echo "$new_path"
	return 0
}
