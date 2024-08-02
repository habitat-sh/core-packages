pkg_name=grpcurl
pkg_origin=core
pkg_version="1.9.1"
pkg_description="Like cURL, but for gRPC: Command-line tool for interacting with gRPC servers"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://github.com/fullstorydev/grpcurl/archive/v${pkg_version}.tar.gz"
pkg_upstream_url="https://github.com/fullstorydev/grpcurl"
pkg_license=('MIT')
pkg_shasum="4bc60a920635929bdf9fa9bb5d310fe3f82bccd441a1487680566694400e4304"

pkg_bin_dirs=(bin)
pkg_build_deps=(
    core/git
    core/go1_19
)

do_prepare() {
	export GOOS=linux
	build_line "Setting GOOS=$GOOS"
	case $pkg_target in
        aarch64-linux)
                GOARCH=arm64
		export GOARCH=arm64
                ;;
        x86_64-linux)
                GOARCH=amd64
		export GOARCH=amd64
                ;;
        esac
	build_line "Setting GOARCH=$GOARCH"
	export GO111MODULE=on
	build_line "Setting GO111MODULE=$GO111MODULE"
}

do_build() {
    return 0
}

do_install() {
	CGO_ENABLED=0 go build \
      -ldflags "-X 'main.version=v${pkg_version}'" \
      -o "${pkg_prefix}/bin" \
      ./cmd/grpcurl
}
