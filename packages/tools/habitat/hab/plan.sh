# shellcheck disable=2034
git_url="https://github.com/habitat-sh/habitat.git"
commit_hash="94d6d50138d1fe005e59f4a7117974ce1b977ae2"
pkg_shasum="ba63a6638fb181c6a7f24d8efb5f5750a648d85fa9456a4a3a9be71471f098f1"

pkg_name="hab"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/habitat-sh/habitat/archive/${commit_hash}.tar.gz"
pkg_dirname="habitat-${commit_hash}"

# The result is a portable, static binary in a zero-dependency package.
pkg_deps=()

pkg_build_deps=(
	core/coreutils
	core/perl
	core/protobuf
	core/rust
)
pkg_bin_dirs=(bin)

pkg_version() {
	cat "$SRC_PATH/VERSION"
}

do_unpack() {
	do_default_unpack
	update_pkg_version
}

# shellcheck disable=2155
do_prepare() {
	local protoc
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

	# We need a static hab binary when installing habitat on a new
	# system for the first time to ensure it always works regardless
	# of the host environment. This initial hab binary is then used
	# to download and install all additional packages required.
	# We can do this by linking in the C runtime statically into
	# the generated rust binary.
	export RUSTFLAGS='-C target-feature=+crt-static'

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
	cargo build --release --target="$rustc_target" --verbose --bin hab
	popd >/dev/null || exit
}

do_install() {
	install -v -D "$CARGO_TARGET_DIR"/"$rustc_target"/release/hab "$pkg_prefix"/bin/hab
}
