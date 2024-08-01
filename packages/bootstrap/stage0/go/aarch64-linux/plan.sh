# shellcheck disable=SC2034
program="go"
pkg_name="go-stage0"
pkg_origin=core
pkg_version=1.8.5
pkg_description="Go is an open source programming language that makes it easy to
  build simple, reliable, and efficient software."
pkg_upstream_url=https://golang.org/
pkg_license=('BSD-3-Clause')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://go.dev/dl/go${pkg_version}.linux-arm64.tar.gz"
pkg_shasum="6c552ae1e77c52944e0f9b9034761bd3dcc3fef57dad6d751a53638783b07d2c"
pkg_dirname=go
pkg_deps=(
)
pkg_build_deps=( 
)
pkg_bin_dirs=(bin)

do_prepare() {
 export GOOS=linux
 build_line "Setting GOOS=$GOOS"
 export GOARCH=arm64
 build_line "Setting GOARCH=$GOARCH"
 export CGO_ENABLED=1
 build_line "Setting CGO_ENABLED=$CGO_ENABLED"

  export GOROOT
  GOROOT="$PWD"
  build_line "Setting GOROOT=$GOROOT"
  export GOBIN="$GOROOT/bin"
  build_line "Setting GOBIN=$GOBIN"
  # shellcheck disable=SC2154
  export GOROOT_FINAL="$pkg_prefix"
  build_line "Setting GOROOT_FINAL=$GOROOT_FINAL"

  PATH="$GOBIN:$PATH"
  build_line "Updating PATH=$PATH"

}

do_build() {
  return 0

}

do_install() {
  cp -av bin/* "${pkg_prefix}/bin"
  cp -av src lib misc "${pkg_prefix}/"

  mkdir -pv "${pkg_prefix}/pkg"
  cp -av pkg/{linux_${GOARCH},tool,include} "${pkg_prefix}/pkg/"
  if [[ -d "pkg/linux_${GOARCH}_race" ]]; then
    cp -av pkg/linux_${GOARCH}_race "${pkg_prefix}/pkg/"
  fi
  # Install the license
  install -v -Dm644 LICENSE "${pkg_prefix}/share/licenses/LICENSE"
  # Remove unneeded Windows files
  rm -fv "${pkg_prefix}/src/*.bat"

  # Move header files to the correct place
  cp -arv "${pkg_prefix}/src/runtime" "${pkg_prefix}/pkg/include"
}

do_strip() {
  # Strip manually since `strip` will not process Go's static libraries.
  for f in "${pkg_prefix}/bin/"* "${pkg_prefix}/pkg/tool/linux_${GOARCH}/"*; do
    strip -s "${f}"
  done
}

