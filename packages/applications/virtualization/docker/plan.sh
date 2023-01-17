pkg_name="docker"
pkg_description="The Docker Engine"
pkg_origin="core"
pkg_version="20.10.22"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2')
pkg_source="https://download.docker.com/linux/static/stable/${pkg_target%%-*}/${pkg_name}-${pkg_version}.tgz"
pkg_upstream_url="https://docs.docker.com/engine/installation/binaries/"
pkg_shasum="2c75cd6c3dc9b81cb5bde664c882e4339a2054e09cf09606f9f7dd6970e7f078"
pkg_dirname="docker"
pkg_bin_dirs=(bin)

pkg_build_deps=(
	core/coreutils
)

do_build() {
  return 0
}

do_install() {
  for bin in *; do
    install -v -D "${bin}" "${pkg_prefix}/bin/${bin}"
  done
}

# Skip stripping down the Go binaries
do_strip() {
  return 0
}
