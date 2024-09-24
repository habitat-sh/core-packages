pkg_name=scaffolding-go
pkg_description="Scaffolding for Go Applications"
pkg_origin=core
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_version="0.2.0"
pkg_license=('Apache-2.0')
pkg_upstream_url="https://github.com/habitat-sh/core-packages/tree/LTS-2024/packages/tools/misc/scaffolding-go"
pkg_deps=(
  "${pkg_deps[@]}"
  core/go1_19
  core/git
  core/gcc
  core/make
)
pkg_scaffolding=core/scaffolding-base

do_install() {
  install -D -m 0644 "$PLAN_CONTEXT/lib/scaffolding.sh" "$pkg_prefix/lib/scaffolding.sh"
  install -D -m 0644 "$PLAN_CONTEXT/lib/gopath_mode.sh" "$pkg_prefix/lib/gopath_mode.sh"
  install -D -m 0644 "$PLAN_CONTEXT/lib/go_module.sh" "$pkg_prefix/lib/go_module.sh"
}

