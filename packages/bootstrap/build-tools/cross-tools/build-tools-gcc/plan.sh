program="gcc"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"
glibc_version="2.36"

pkg_name="build-tools-gcc"
pkg_origin="core"
pkg_version="12.2.0"
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
pkg_shasum="e549cf9cf3594a00e27b6589d4322d70e0720cdd213f39beb4181e06926230ff"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/build-tools-binutils
	core/build-tools-glibc
	core/build-tools-gmp
	core/build-tools-isl
	core/build-tools-mpfr
	core/build-tools-libmpc
	core/build-tools-bash-static
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

	EXTRA_LDFLAGS_FOR_TARGET="${LDFLAGS} -Wl,-dynamic-linker=${dynamic_linker}"
	export LDFLAGS_FOR_TARGET="-L$(pwd)/build/${native_target}/libgcc ${EXTRA_LDFLAGS_FOR_TARGET}"
	export CPPFLAGS_FOR_TARGET="${CPPFLAGS} ${EXTRA_LDFLAGS_FOR_TARGET}"
	export CFLAGS_FOR_TARGET="${CFLAGS} ${EXTRA_LDFLAGS_FOR_TARGET}"
	export CXXFLAGS_FOR_TARGET="${CXXFLAGS} ${EXTRA_LDFLAGS_FOR_TARGET}"

	# To prevent the build compiler/linker from being affected by LD_RUN_PATH,
	# we transfer its value to HAB_LD_RUN_PATH and unset LD_RUN_PATH.
	# This allows the native-cross-binutils linker to correctly put rpath
	# entries for glibc, isl, gmp, etc.
	export HAB_LD_RUN_PATH="${LD_RUN_PATH}"
	unset LD_RUN_PATH

	# We unset all remaining flags that will interfere with the host compiler
	unset LDFLAGS
	unset CPPFLAGS
	unset CFLAGS
	unset CXXFLAGS

	# Remove the gcc and binutils binary directory from the PATH, otherwise the build process
	# will begin to pick up the just built compilers and the built-tools-binutils linker for compilation
	PATH=$(path_remove "${PATH}" "${pkg_prefix}/bin")
	PATH=$(path_remove "${PATH}" "$(pkg_path_for build-tools-binutils)/bin")
	build_line "Updated PATH=${PATH}"

	# Tell gcc not to look under the default `/lib/` and `/usr/lib/` directories
	# for libraries
	#
	# Thanks to: https://raw.githubusercontent.com/NixOS/nixpkgs/release-22.05/pkgs/development/compilers/gcc/gcc-12-no-sys-dirs.patch
	# shellcheck disable=SC2002
	patch -p1 <"$PLAN_CONTEXT/gcc-12-no-sys-dirs.patch"

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
	local bin="$pkg_prefix/bin/$1"
	build_line "Adding wrapper $bin to ${bin}.real"
	mv -v "$bin" "${bin}.real"
	case $native_target in
	aarch64-hab-linux-gnu)
		dynamic_linker="$(pkg_path_for build-tools-glibc)/lib/ld-linux-aarch64.so.1"
		;;
	x86_64-hab-linux-gnu)
		dynamic_linker="$(pkg_path_for build-tools-glibc)/lib/ld-linux-x86-64.so.2"
		;;
	esac
	sed "$PLAN_CONTEXT/cc-wrapper.sh" \
		-e "s^@bash@^$(pkg_path_for build-tools-bash-static)/bin/bash^g" \
		-e "s^@glibc@^$(pkg_path_for build-tools-glibc)^g" \
		-e "s^@linux_headers@^$(pkg_path_for build-tools-linux-headers)^g" \
		-e "s^@binutils@^$(pkg_path_for build-tools-binutils)/${native_target}/bin^g" \
		-e "s^@dynamic_linker@^${dynamic_linker}^g" \
		-e "s^@program@^${bin}.real^g" \
		>"$bin"
	chmod 755 "$bin"
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
