# shellcheck disable=2034
git_url="https://github.com/habitat-sh/habitat.git"
commit_hash="91fa6e13562e3f8da6e0740c3e3e863a309ab473"
pkg_shasum="626b7c6c37fc87a3fc3d43f1e03d58d83b5e9e09be1b3cd70908928145fa463b"

pkg_name="hab-sup"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/${commit_hash}.tar.gz"
pkg_dirname="habitat-${commit_hash}"

pkg_deps=(
	core/glibc
	core/gcc-libs
	core/zeromq
)
pkg_build_deps=(
	core/coreutils
	core/gcc
	core/perl
	core/protobuf
	core/rust/1.68.2
	core/raml2html
	core/pkg-config
)
pkg_bin_dirs=(bin)

pkg_version() {
	cat "$SRC_PATH/VERSION"
}

do_unpack() {
	do_default_unpack
	update_pkg_version
}

do_prepare() {
	local protoc
	local gcc_libs

	export CARGO_HOME="$HAB_CACHE_SRC_PATH/$pkg_dirname/.cargo"
	export CARGO_TARGET_DIR="$HAB_CACHE_SRC_PATH/$pkg_dirname/target"
	export rustc_target="${TARGET_ARCH:-${pkg_target%%-*}}-unknown-linux-gnu"

	# Used by the `build.rs` program to set the version of the binaries
	export PLAN_VERSION="${pkg_version}/${pkg_release}"
	# Used to set the active package target for the binaries at build time
	export PLAN_PACKAGE_TARGET="$pkg_target"
	# Prost (our Rust protobuf library) embeds a `protoc` binary, but
	# it's dynamically linked, which means it won't work in a
	# Studio. Prost does allow us to override that, though, so we can
	# just use our Habitat package by setting these two environment
	# variables.
	protoc="$(pkg_path_for protobuf)"
	export PROTOC="${protoc}/bin/protoc"
	export PROTOC_INCLUDE="${protoc}/include"

	# We need to pass in the path to core/gcc-libs lib folder to the rust
	# compiler so that it is passed to the habitat linker script and added
	# correctly in the rpath of the resulting binaries
	gcc_libs="$(pkg_path_for gcc-libs)"
	export RUSTFLAGS="-L ${gcc_libs}/lib"

	build_line "Building for target $rustc_target"
	build_line "Setting CARGO_HOME=$CARGO_HOME"
	build_line "Setting CARGO_TARGET_DIR=$CARGO_TARGET_DIR"
	build_line "Setting PLAN_VERSION=$PLAN_VERSION"
	build_line "Setting PLAN_PACKAGE_TARGET=$PLAN_PACKAGE_TARGET"
	build_line "Setting PROTOC=$PROTOC"
	build_line "Setting PROTOC_INCLUDE=$PROTOC_INCLUDE"
	build_line "Setting RUSTFLAGS=$RUSTFLAGS"
}

do_build() {
	pushd "$SRC_PATH" >/dev/null || exit
	cargo build --release --target="$rustc_target" --verbose --bin hab-sup
	popd >/dev/null || exit
}

do_install() {
	install -v -D "$CARGO_TARGET_DIR"/"$rustc_target"/release/hab-sup "$pkg_prefix"/bin/hab-sup
}
