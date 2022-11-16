program="gmp"

pkg_name="gmp-stage0"
pkg_origin="core"
pkg_version="6.2.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GMP is a free library for arbitrary precision arithmetic, operating on signed \
integers, rational numbers, and floating-point numbers.\
"
pkg_upstream_url="https://gmplib.org"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.xz"
pkg_shasum="fd4829912cddd12f84181c3451cc752be224643e87fac497b69edddadc49b4f2"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
    core/glibc-stage0
)
pkg_build_deps=(
    core/gcc-stage0
    core/m4-stage0
    core/build-tools-make
    core/build-tools-patchelf
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
    # default settings of GMP produce libraries optimized for the host processor. \
    # If libraries suitable for processors less capable than the host's CPU are desired, \
    # generic libraries can be created by
    cp -v configfsf.guess config.guess
    cp -v configfsf.sub config.sub
}

do_build() {
    ./configure \
        --prefix="$pkg_prefix" \
        --enable-cxx \
        --disable-static \
        --docdir="$pkg_prefix/share/doc/gmp-6.2.1" \
        --build="aarch64-unknown-linux-gnu"

    make
}

do_check() {
    make check
}

do_install() {
    make install
    patchelf --shrink-rpath "${pkg_prefix}/lib/libgmp.so.10.4.1"
    patchelf --shrink-rpath "${pkg_prefix}/lib/libgmpxx.so.4.6.1"
}
