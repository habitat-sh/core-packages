program="haproxy"

pkg_name=haproxy
pkg_origin=core
pkg_description="The Reliable, High Performance TCP/HTTP Load Balancer"
pkg_version=2.8.5
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'
pkg_license=('GPL-2.0' 'LGPL-2.1')
pkg_source="https://www.haproxy.org/download/2.8/src/haproxy-${pkg_version}.tar.gz"
pkg_upstream_url="https://www.haproxy.org/"
pkg_shasum=3f5459c5a58e0b343a32eaef7ed5bed9d3fc29d8aa9e14b36c92c969fc2a60d9
pkg_svc_run='haproxy -f config/haproxy.conf -db'
pkg_svc_user=root
pkg_svc_group=root
pkg_exports=(
  [port]=front-end.port
  [status-port]=status.port
)
pkg_exposes=(port status-port)
pkg_binds=(
  [backend]="port"
)
pkg_deps=(
  core/zlib
  core/pcre2
  core/openssl
)
pkg_build_deps=(
  core/coreutils
  core/gcc
  core/make
  core/diffutils
)
pkg_bin_dirs=(bin)

do_build() {
  make \
    USE_PCRE2=1 \
    USE_PCRE2_JIT=1 \
    TARGET=linux-glibc \
    USE_OPENSSL=1 \
    USE_ZLIB=1 \
    USE_GETADDRINFO=1 \
    ADDINC="${CFLAGS}" \
    ADDLIB="${LDFLAGS}" 
}

do_install() {
  mkdir -p "${pkg_prefix}"/bin
  cp haproxy "${pkg_prefix}"/bin
}

