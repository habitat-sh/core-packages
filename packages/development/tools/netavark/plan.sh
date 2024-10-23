pkg_name=netavark
pkg_origin=core
pkg_version="1.12.2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("Apache-2.0")
pkg_deps=(
  core/glibc
  core/gcc-base
)
pkg_build_deps=(
    core/protobuf
    core/rust
)
pkg_bin_dirs=(bin)
pkg_description="A rust based network stack for containers"
pkg_upstream_url="https://github.com/containers/netavark"
pkg_source="https://github.com/containers/netavark/archive/v${pkg_version}.tar.gz"
pkg_shasum=d1e5a7e65b825724fd084b0162084d9b61db8cda1dad26de8a07be1bd6891dbc

do_prepare() {
    export PROTOC="$(pkg_path_for protobuf)/bin/protoc"
}

do_build() {
	cargo build --release
}

do_install() {
    install -v -D "${CACHE_PATH}/target/release/netavark" "${pkg_prefix}/bin/netavark"
}

