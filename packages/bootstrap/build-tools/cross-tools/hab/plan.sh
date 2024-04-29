# shellcheck disable=2154
commit_hash="4462a5566cbd81cdda56fd3bc7a98829b0dbb986"

pkg_name="build-tools-hab"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/${commit_hash}.tar.gz"
pkg_shasum="d4c9ab7a5b40913171006b11205490ceae8d217735ca6b579e329bffc0e13947"
pkg_dirname="habitat-${commit_hash}"
# The result is a portable, static binary in a zero-dependency package.
pkg_deps=(
	core/build-tools-xz
)
pkg_build_deps=(
	core/build-tools-cacerts
	core/build-tools-rust
	core/build-tools-coreutils
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
	export rustc_target="${TARGET_ARCH:-${pkg_target%%-*}}-apple-darwin"

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
	cargo build "${build_type}" --target="$rustc_target" --locked --verbose --bin hab
	popd >/dev/null || exit
}

do_install() {
	install -v -D "$CARGO_TARGET_DIR"/"$rustc_target"/"${build_type#--}"/$bin "$pkg_prefix"/bin/$bin
}