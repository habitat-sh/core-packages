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
pkg_license=('GPL-3.0-or-later' 'GCC Runtime Library Exception')

pkg_deps=(
	core/native-cross-binutils
	core/native-cross-gcc-base
	core/build-tools-glibc
	core/build-tools-libstdcpp
	core/build-tools-linux-headers
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
	local wrapper_bin="$1"
	local real_bin
	real_bin="$(pkg_path_for native-cross-gcc-base)/bin/$wrapper_bin"
	case $native_target in
	aarch64-hab-linux-gnu)
		dynamic_linker="$(pkg_path_for build-tools-glibc)/lib/ld-linux-aarch64.so.1"
		;;
	x86_64-hab-linux-gnu)
		dynamic_linker="$(pkg_path_for build-tools-glibc)/lib/ld-linux-x86-64.so.2"
		;;
	esac

	build_line "Adding wrapper $pkg_prefix/bin/$wrapper_bin for $real_bin"
	rm -v "$pkg_prefix/bin/$wrapper_bin"
	sed "$PLAN_CONTEXT/cc-wrapper.sh" \
		-e "s^@glibc@^$(pkg_path_for build-tools-glibc)^g" \
		-e "s^@linux_headers@^$(pkg_path_for build-tools-linux-headers)^g" \
		-e "s^@binutils@^$(pkg_path_for native-cross-binutils)^g" \
		-e "s^@libstdcpp@^$(pkg_path_for build-tools-libstdcpp)^g" \
		-e "s^@native_target@^${native_target}^g" \
		-e "s^@dynamic_linker@^${dynamic_linker}^g" \
		-e "s^@program@^${real_bin}^g" \
		>"$pkg_prefix/bin/$wrapper_bin"

	chmod 755 "$pkg_prefix/bin/$wrapper_bin"
}
