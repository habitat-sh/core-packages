pkg_name=sccache
pkg_origin=core
pkg_version=0.8.1
pkg_license=('Apache-2.0')
pkg_upstream_url="https://github.com/mozilla/sccache"
pkg_description="sccache is ccache with cloud storage"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://github.com/mozilla/sccache/archive/v${pkg_version}.tar.gz"
pkg_shasum=30b951b49246d5ca7d614e5712215cb5f39509d6f899641f511fb19036b5c4e5
pkg_bin_dirs=(bin)
pkg_deps=(
  core/glibc
  core/gcc-libs
  core/openssl
)
pkg_build_deps=(
  core/rust
  core/pkg-config
)
pkg_svc_user="root"
pkg_svc_group="root"

do_build() {
  cargo build \
    --features="all" \
    --release
}

do_install() {
  install -v -D "${CACHE_PATH}/target/release/sccache" "${pkg_prefix}/bin/sccache"
}
