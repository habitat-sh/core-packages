program="gcc"

pkg_name="gcc-stage1"
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
	core/binutils-stage0
	core/glibc-stage0
	core/hab-cc-wrapper
)

pkg_build_deps=(
	core/gcc-stage0
	core/gmp-stage0
	core/isl-stage0
	core/mpfr-stage0
	core/libmpc-stage0
	core/zlib-stage0
	core/zstd-stage0
	core/m4-stage0
	core/flex-stage0
	core/xz-stage0
	core/linux-headers
	core/build-tools-texinfo
	core/build-tools-bison
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib lib64)

do_prepare() {
	local libc
	local linux_headers
	local dynamic_linker

	libc="$(pkg_path_for glibc-stage0)"
	linux_headers="$(pkg_path_for linux-headers)"

	case $pkg_target in
	aarch64-linux)
		dynamic_linker="${libc}/lib/ld-linux-aarch64.so.1"
		;;
	x86_64-linux)
		dynamic_linker="${libc}/lib/ld-linux-x86-64.so.2"
		;;
	esac

	# This plan does a full bootstrap build of gcc. This requires us to
	# ensure that all the intermediate compilers and libraries are configured
	# to use our glibc, linux headers and other dependencies.
	# Bootstrapping is recommended when there is a major version difference
	# between the build compiler and the built compiler.
	# Since the `core/gcc-stage1` compiler is built with the `core/build-tools-gcc`
	# compiler which may potentially be quite old, we need to bootstrap it.
	# To know more about the gcc bootstrap process and it's configuration
	# check out the following link: https://gcc.gnu.org/install/build.html

	# We add extra flags which will get passed to the target xgcc compiler
	# that is used to compile the final libraries such as libatomic, libgomp,
	# libstdc++, libgcc, libquadmath, libssp among other.
	#
	# Explanation of flags used
	# * -B${libc}/lib
	#   Tells gcc where to find C runtime start files (crt{i,o,n}.o) These are
	#   provided by glibc and are required to be linked into all executables.
	# * -L${libc}/lib
	#   Tells gcc where to find the C library, usually libc and libm.
	# * -idirafter ${libc}/include
	#   Tells gcc where to find the C library's header files
	# * -idirafter ${linux_headers}/include
	#   Tells gcc where to find the linux header files.
	#   The C library's header files requires the linux headers.
	#   The linux headers folder must always come after the C library's headers
	#   otherwise they will not get included in the correct order.
	export FLAGS_FOR_TARGET="-B${libc}/lib \
		-L${libc}/lib \
		-idirafter ${libc}/include \
		-idirafter ${linux_headers}/include"

	# Extra linking flags passed to gcc so that excutables generated by
	# target xgcc compiler will use the correct dynamic linker from our glibc.
	export LDFLAGS_FOR_TARGET="${LDFLAGS} -Wl,-dynamic-linker=${dynamic_linker}"

	# Extra flags that must be passed to intermediate xgcc/xg++ bootstrapping compilers.
	# These flags are similar to the what we pass to the target xgcc/xg++ compilers.
	# We need to add '-O2' to ensure optimizations are enabled during compilation.
	export BOOT_CFLAGS="${FLAGS_FOR_TARGET} -O2"

	# Extra linking flags that must be passed to intermediate xgcc/xg++ bootstrapping compilers
	# These flags are similar to the what we pass to the target xgcc/xg++ compilers.
	export BOOT_LDFLAGS="${LDFLAGS_FOR_TARGET}"

	# Tell gcc not to look under the default `/lib/` and `/usr/lib/` directories
	# for libraries
	#
	# Thanks to: https://github.com/NixOS/nixpkgs/blob/release-15.09/pkgs/development/compilers/gcc/no-sys-dirs.patch
	# shellcheck disable=SC2002
	patch -p1 <"$PLAN_CONTEXT/no-sys-dirs.patch"

	build_line "Setting FLAGS_FOR_TARGET=${FLAGS_FOR_TARGET}"
	build_line "Setting LDFLAGS_FOR_TARGET=${LDFLAGS_FOR_TARGET}"
	build_line "Setting BOOT_CFLAGS=${BOOT_CFLAGS}"
	build_line "Setting BOOT_LDFLAGS=${BOOT_LDFLAGS}"
}

do_build() {
	mkdir -v build
	pushd build || exit 1

	# We force the usage of the correct linker via the 'LD' parameter.
	# If we do not do this, it will use the linker specified by the compiler.
	# In this case the compiler is the 'core/build-tools-gcc' compiler and it
	# would specify the 'core/build-tools-binutils' ld.
	../configure \
		LDFLAGS_FOR_TARGET="${LDFLAGS_FOR_TARGET}" \
		CPPFLAGS_FOR_TARGET="${CPPFLAGS}" \
		CFLAGS_FOR_TARGET="${CFLAGS}" \
		CXXFLAGS_FOR_TARGET="${CXXFLAGS}" \
		LD="$(pkg_path_for binutils-stage0)"/bin/ld \
		--prefix="$pkg_prefix" \
		--with-gmp="$(pkg_path_for gmp-stage0)" \
		--with-isl="$(pkg_path_for isl-stage0)" \
		--with-mpfr="$(pkg_path_for mpfr-stage0)" \
		--with-mpc="$(pkg_path_for libmpc-stage0)" \
		--with-zstd="$(pkg_path_for zstd-stage0)" \
		--with-native-system-header-dir="$(pkg_path_for glibc-stage0)/include" \
		--enable-default-pie \
		--enable-default-ssp \
		--disable-multilib \
		--with-system-zlib \
		--enable-languages=c,c++

	# These flags are passed directly to make as they cannot be
	# configured via the configure script.
	# It is important to not run this build in parallel due to this
	# race condition: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=106162
	make \
		FLAGS_FOR_TARGET="${FLAGS_FOR_TARGET}" \
		BOOT_CFLAGS="${BOOT_CFLAGS}" \
		BOOT_LDFLAGS="${BOOT_LDFLAGS}" \
		-j "$(nproc)" \
		--output-sync

	popd || exit 1
}

do_install() {
	# Determine the target prefix
	local target_prefix
	target_prefix=$(./config.guess)

	pushd build || exit 1
	make install

	# Many packages use the name cc to call the C compiler
	ln -sv gcc "$pkg_prefix/bin/cc"

	wrap_binary "${target_prefix}-c++"
	wrap_binary "${target_prefix}-g++"
	wrap_binary "${target_prefix}-gcc"
	wrap_binary "${target_prefix}-gcc-${pkg_version}"

	wrap_binary "c++"
	wrap_binary "gcc"
	wrap_binary "g++"
	wrap_binary "cpp"

	popd || exit 1
}

wrap_binary() {
	local binary
	local env_prefix
	local hab_cc_wrapper
	local binutils
	local linux_headers
	local libc
	local wrapper_binary
	local actual_binary

	binary="$1"
	env_prefix="GCC_STAGE1"
	hab_cc_wrapper="$(pkg_path_for hab-cc-wrapper)"
	binutils="$(pkg_path_for binutils-stage0)"
	linux_headers="$(pkg_path_for linux-headers)"
	libc="$(pkg_path_for glibc-stage0)"
	wrapper_binary="$pkg_prefix/bin/$binary"
	actual_binary="$pkg_prefix/bin/$binary.real"

	case $pkg_target in
	aarch64-linux)
		dynamic_linker="$libc/lib/ld-linux-aarch64.so.1"
		;;
	x86_64-linux)
		dynamic_linker="$libc/lib/ld-linux-x86-64.so.2"
		;;
	esac

	build_line "Adding wrapper for $binary"
	mv -v "$wrapper_binary" "$actual_binary"

	sed "$PLAN_CONTEXT/cc-wrapper.sh" \
		-e "s^@env_prefix@^${env_prefix}^g" \
		-e "s^@executable_name@^${binary}^g" \
		-e "s^@wrapper@^${hab_cc_wrapper}/bin/hab-cc-wrapper^g" \
		-e "s^@program@^${actual_binary}^g" \
		-e "s^@ld_bin@^${binutils}/bin^g" \
		-e "s^@dynamic_linker@^${dynamic_linker}^g" \
		-e "s^@c_start_files@^${libc}/lib^g" \
		-e "s^@c_std_libs@^${libc}/lib^g" \
		-e "s^@c_std_headers@^${libc}/include:${linux_headers}/include^g" \
		>"$wrapper_binary"

	chmod 755 "$wrapper_binary"
}

do_strip() {
	return 0
}
