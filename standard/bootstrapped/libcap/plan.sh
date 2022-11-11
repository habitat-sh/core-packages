pkg_name="libcap"
pkg_origin="core"
pkg_version="2.66"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The Libcap package implements the user-space interfaces to the POSIX 1003.1e capabilities \
available in Linux kernels. These capabilities are a partitioning of the all powerful \
root privilege into a set of distinct privileges.
"
pkg_upstream_url="http://sites.google.com/site/fullycapable/"
pkg_license=('GPL v2.0')
pkg_source="https://git.kernel.org/pub/scm/libs/libcap/libcap.git/snapshot/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="20fbc13a2443881bf13f67eb4ec7f8d6b93843bf1ce7b3015ae1890ddfbd7324"

pkg_deps=(
    core/glibc
)
pkg_build_deps=(
    core/build-tools-make
    core/gcc-bootstrap
    core/build-tools-sed
    core/build-tools-patchelf
    core/build-tools-grep
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)

do_prepare() {
    # Prevent static libraries from being installed
    sed -i '/install -m.*STA/d' libcap/Makefile

    LDFLAGS="${LDFLAGS} -L${pkg_prefix}/lib -Wl,-rpath=${pkg_prefix}/lib"
    build_line "Updating LDFLAGS=${LDFLAGS}"
}

do_build() {
    make prefix="$pkg_prefix" lib=lib sbin=bin
}

do_check() {
    make test
}

do_install() {
    make prefix="$pkg_prefix" lib=lib sbin=bin install
    patchelf --shrink-rpath "${pkg_prefix}/bin/capsh"
    patchelf --shrink-rpath "${pkg_prefix}/bin/getcap"
    patchelf --shrink-rpath "${pkg_prefix}/bin/getpcaps"
    patchelf --shrink-rpath "${pkg_prefix}/bin/setcap"
    patchelf --shrink-rpath "${pkg_prefix}/lib/libcap.so.${pkg_version}"
    patchelf --shrink-rpath "${pkg_prefix}/lib/libpsx.so.${pkg_version}"
}