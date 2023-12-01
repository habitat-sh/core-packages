pkg_name=sensu
pkg_origin=core
pkg_version=1.9.0
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="A monitoring framework that aims to be simple, malleable, and scalable."
pkg_upstream_url="https://sensuapp.org"
pkg_license=('MIT')
pkg_bin_dirs=(bin)
pkg_svc_user=root
pkg_svc_group=${pkg_svc_user}
pkg_build_deps=(
  core/gcc
  core/bundler
)
pkg_deps=(
  core/gcc-libs
  core/coreutils
  core/libffi
  core/openssl
  core/bash
  core/ruby
)
pkg_binds_optional=(
  [rabbitmq]="port"
  [redis]="port"
)
pkg_exports=(
  [port]=api.port
)
pkg_exposes=(port)

do_setup_environment() {
  BUNDLE_PATH="${pkg_prefix}/vendor/bundle"
  set_runtime_env BUNDLE_PATH "${BUNDLE_PATH}"
  set_buildtime_env BUNDLE_PATH "${BUNDLE_PATH}"
  build_line "Setting BUNDLE_PATH=${BUNDLE_PATH}"
}

do_build() {
  return 0
}

do_install() {
  pushd "${pkg_prefix}"
  cp "${PLAN_CONTEXT}"/Gemfile .
  bundle install --jobs 2 --retry 5
  bundle binstubs --all
  grep -nrlI '^\#\!.*bin/env' "$pkg_prefix" | while read -r target; do
    sed -e "s|#!.*bin/env|#!$(pkg_path_for coreutils)/bin/env|" -i "$target"
  done
  popd
}
