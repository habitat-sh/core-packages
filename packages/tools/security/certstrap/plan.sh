pkg_origin=core
pkg_name=certstrap
pkg_version="1.3.0"
pkg_upstream_url="https://github.com/square/certstrap"
pkg_description="A simple certificate manager written in Go, to bootstrap your own certificate authority and public key infrastructure. Adapted from etcd-ca."
pkg_source="https://github.com/square/certstrap/archive/refs/tags/v${pkg_version}.tar.gz"
pkg_shasum="4b32289c20dfad7bf8ab653c200954b3b9981fcbf101b699ceb575c6e7661a90"
pkg_license=("Apache-2.0")
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'

pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/go19
)

pkg_bin_dirs=(bin)
pkg_svc_user="root"
pkg_svc_group="root"

do_prepare() {
	export GOOS=linux
	build_line "Setting GOOS=$GOOS"
	export GOARCH=amd64
	build_line "Setting GOARCH=$GOARCH"
	export GO111MODULE=on
	build_line "Setting GO111MODULE=$GO111MODULE"
}

do_build() {
	return 0
}

do_install() {
	go build -o "${pkg_prefix}/bin"
}