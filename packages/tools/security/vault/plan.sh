pkg_name=vault
pkg_origin=core
pkg_version="1.17.3"
pkg_description="A tool for managing secrets."
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'
pkg_license=('')
pkg_upstream_url=https://www.vaultproject.io/
pkg_source="https://releases.hashicorp.com/vault/${pkg_version}/vault_${pkg_version}_linux_amd64.zip"
pkg_shasum="146536fd9ef8aa1465894e718a8fe7a9ca13d68761bae900428f01f7ecd83806"
pkg_filename="${pkg_name}-${pkg_version}_linux_amd64.zip"

pkg_build_deps=(
  core/unzip
)

pkg_bin_dirs=(bin)
pkg_svc_user=root
pkg_svc_group=root
pkg_exports=(
  [port]=listener.port
)
pkg_exposes=(port)

do_unpack() {
  cd "${HAB_CACHE_SRC_PATH}" || exit
  unzip "${pkg_filename}" -d "${pkg_name}-${pkg_version}"
}

do_build_config() {
  do_default_build_config
}

do_build() {
  return 0
}

do_install() {
  install -D vault "${pkg_prefix}"/bin/vault

  install -D LICENSE.txt "${pkg_prefix}"
}