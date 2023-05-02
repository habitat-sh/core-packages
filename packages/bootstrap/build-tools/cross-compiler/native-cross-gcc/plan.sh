program="gcc"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="native-cross-gcc"
pkg_origin="core"
pkg_version="12.2.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU Compiler Collection (GCC) is a compiler system produced by the GNU \
Project supporting various programming languages. GCC is a key component of \
the GNU toolchain and the standard compiler for most Unix-like operating \
systems.This package is a wrapper around the native-cross-gcc-base package.\
"
pkg_upstream_url="https://gcc.gnu.org/"
pkg_license=('GPL-3.0-or-later WITH GCC-exception-3.1' 'LGPL-3.0-or-later')

pkg_deps=(
	core/native-cross-binutils
	core/native-cross-gcc-base
	core/build-tools-glibc
	core/build-tools-libstdcpp
	core/build-tools-linux-headers
	core/hab-cc-wrapper
)

pkg_bin_dirs=(bin)

do_build() {
	return 0
}

do_install() {
	for file in "$(pkg_path_for native-cross-gcc-base)"/bin/*; do
		ln -sv "$file" "${pkg_prefix:?}/bin/$(basename "$file")"
	done

	wrap_binary "${native_target}-c++"
	wrap_binary "${native_target}-g++"
	wrap_binary "${native_target}-cpp"
	wrap_binary "${native_target}-gcc"
	wrap_binary "${native_target}-gcc-${pkg_version}"

	# Many packages use the name cc to call the C compiler
	ln -sv "${native_target}-gcc" "$pkg_prefix/bin/cc"
}

wrap_binary() {
	local binary="$1"
	local env_prefix="NATIVE_CROSS_GCC"

	local hab_cc_wrapper
	hab_cc_wrapper="$(pkg_path_for hab-cc-wrapper)"
	local binutils
	binutils="$(pkg_path_for native-cross-binutils)"
	local gcc_base
	gcc_base="$(pkg_path_for native-cross-gcc-base)"
	local linux_headers
	linux_headers="$(pkg_path_for build-tools-linux-headers)"
	local libc
	libc="$(pkg_path_for build-tools-glibc)"
	local libcxx
	libcxx="$(pkg_path_for build-tools-libstdcpp)"

	local wrapper_binary="$pkg_prefix/bin/$binary"
	local actual_binary="$gcc_base/bin/$binary"

	case $native_target in
	aarch64-hab-linux-gnu)
		dynamic_linker="$libc/lib/ld-linux-aarch64.so.1"
		;;
	x86_64-hab-linux-gnu)
		dynamic_linker="$libc/lib/ld-linux-x86-64.so.2"
		;;
	esac

	build_line "Adding wrapper for $binary"
	# remove symbolic link first
	rm -v "$wrapper_binary"

	sed "$PLAN_CONTEXT/cc-wrapper.sh" \
		-e "s^@env_prefix@^${env_prefix}^g" \
		-e "s^@executable_name@^${binary}^g" \
		-e "s^@wrapper@^${hab_cc_wrapper}/bin/hab-cc-wrapper^g" \
		-e "s^@program@^${actual_binary}^g" \
		-e "s^@ld_bin@^${binutils}/${native_target}/bin^g" \
		-e "s^@dynamic_linker@^${dynamic_linker}^g" \
		-e "s^@c_start_files@^${libc}/lib^g" \
		-e "s^@c_std_libs@^${libc}/lib^g" \
		-e "s^@c_std_headers@^${libc}/include:${linux_headers}/include^g" \
		-e "s^@cxx_std_libs@^${libcxx}/lib^g" \
		-e "s^@cxx_std_headers@^${libcxx}/include/c++/${pkg_version}:${libcxx}/include/c++/${pkg_version}/${native_target}:${libcxx}/include/c++/${pkg_version}/backward^g" \
		>"$wrapper_binary"

	build_line "WRAPPER FILE: $(file "$wrapper_binary")"
	build_line "ACTUAL FILE: $(file "$actual_binary")"
	chmod 755 "$wrapper_binary"
}
