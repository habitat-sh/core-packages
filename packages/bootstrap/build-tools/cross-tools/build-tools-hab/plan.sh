# shellcheck disable=2154
_version="1.6.1108"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-hab"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/refs/tags/${_version}.tar.gz"
pkg_shasum="5145d59c2ec86290c8c5329171ece2b1289e795a3524c3db97b533679dc668b9"
pkg_dirname="habitat-${_version}"
# The result is a portable, static binary in a zero-dependency package.
pkg_deps=(
	core/build-tools-glibc
	core/build-tools-gcc-libs
)
pkg_build_deps=(
	core/native-rust
	core/native-patchelf
)
pkg_bin_dirs=(bin)

bin="hab"

pkg_version() {
	cat "$SRC_PATH/VERSION"
}

do_unpack() {
	do_default_unpack
	update_pkg_version
}

do_prepare() {
	build_type="--release"
	
	export CARGO_HOME="$HAB_CACHE_SRC_PATH/$pkg_dirname/.cargo"
	
	export CARGO_TARGET_DIR="$HAB_CACHE_SRC_PATH/$pkg_dirname/target"

	export rustc_target="${TARGET_ARCH:-${pkg_target%%-*}}-unknown-linux-gnu"


	# Remove remaining flags that will interfere with the build compiler/linker
	unset LD_RUN_PATH
	unset CFLAGS
	unset CPPFLAGS
	unset CXXFLAGS
	unset LDFLAGS

	build_line "Building artifacts with \`${build_type#--}' mode"
	build_line "Setting CARGO_HOME=$CARGO_HOME"
	build_line "Setting CARGO_TARGET_DIR=$CARGO_TARGET_DIR"
	build_line "Setting rustc_target=$rustc_target"
	build_line "Unsetting LD_RUN_PATH"
	build_line "Unsetting CFLAGS"
	build_line "Unsetting CPPFLAGS"
	build_line "Unsetting CXXFLAGS"
	build_line "Unsetting LDFLAGS"
}

do_build() {
	pushd "$SRC_PATH" >/dev/null || exit
	cargo build "${build_type}" --target="$rustc_target" --verbose --bin hab
	popd >/dev/null || exit
}

do_install() {
	case $native_target in
	aarch64-hab-linux-gnu)
		dynamic_linker="$(pkg_path_for build-tools-glibc)/lib/ld-linux-aarch64.so.1"
		;;
	x86_64-hab-linux-gnu)
		dynamic_linker="$(pkg_path_for build-tools-glibc)/lib/ld-linux-x86-64.so.2"
		;;
	esac
	install -v -D "$CARGO_TARGET_DIR"/"$rustc_target"/"${build_type#--}"/$bin "$pkg_prefix"/bin/$bin
	patchelf --set-rpath "$(pkg_path_for build-tools-glibc)/lib:$(pkg_path_for build-tools-gcc-libs)/lib" --set-interpreter "$dynamic_linker" "$pkg_prefix"/bin/$bin
}

do_strip() {
	if [[ $build_type != "--debug" ]]; then
		strip --strip-debug "$pkg_prefix"/bin/$bin
	fi
}
