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
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(sbin)

do_prepare() {
	# Prevent static libraries from being installed
	sed -i '/install -m.*STA/d' libcap/Makefile
	LDFLAGS="${LDFLAGS} -L${pkg_prefix}/lib"
}

do_build() {
    make prefix="$pkg_prefix" lib=lib
}

do_check() {
    make test
}

do_install() {
	make prefix="$pkg_prefix" lib=lib install
	patchelf --shrink-rpath "${pkg_prefix}/sbin/capsh"
	patchelf --shrink-rpath "${pkg_prefix}/sbin/getcap"
      	patchelf --shrink-rpath "${pkg_prefix}/sbin/getpcaps"
	patchelf --shrink-rpath "${pkg_prefix}/sbin/setcap"
	patchelf --shrink-rpath "${pkg_prefix}/lib/libcap.so.${pkg_version}"
	patchelf --shrink-rpath "${pkg_prefix}/lib/libpsx.so.${pkg_version}"

	out=$(patchelf --print-rpath "${pkg_prefix}/sbin/getcap")
	patchelf --set-rpath "$out:${pkg_prefix}/lib" "${pkg_prefix}/sbin/getcap"
	out=$(patchelf --print-rpath "${pkg_prefix}/sbin/getpcaps")
	patchelf --set-rpath "$out:${pkg_prefix}/lib" "${pkg_prefix}/sbin/getpcaps"
	out=$(patchelf --print-rpath "${pkg_prefix}/sbin/setcap")
	patchelf --set-rpath "$out:${pkg_prefix}/lib" "${pkg_prefix}/sbin/setcap"
	out=$(patchelf --print-rpath "${pkg_prefix}/sbin/capsh")
	patchelf --set-rpath "$out:${pkg_prefix}/lib" "${pkg_prefix}/sbin/capsh"
}
