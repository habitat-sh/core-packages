pkg_name="attr"
pkg_origin="core"
pkg_version="2.5.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Commands for Manipulating Filesystem Extended Attributes.
"
pkg_upstream_url="https://savannah.nongnu.org/projects/attr/"
pkg_license=('GPL-2.0-or-later')
pkg_source="http://download.savannah.gnu.org/releases/${pkg_name}/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="bae1c6949b258a0d68001367ce0c741cebdacdd3b62965d17e5eb23cd78adaf8"

pkg_deps=(
    core/glibc
)
pkg_build_deps=(
    core/build-tools-make
    core/gcc-bootstrap
    core/build-tools-patchelf
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)

do_build() {
    ./configure \
        --prefix="$pkg_prefix" \
        --sysconfdir="$pkg_prefix/etc" \
        --docdir="$pkg_prefix/share/doc/attr-2.5.1" \
        --disable-static

    make
}

do_check() {
    make check
}

do_install() {
    make install
    patchelf --shrink-rpath "${pkg_prefix}/bin/attr"
    patchelf --shrink-rpath "${pkg_prefix}/bin/setfattr"
    patchelf --shrink-rpath "${pkg_prefix}/bin/getfattr"
    patchelf --shrink-rpath "${pkg_prefix}/lib/libattr.so.1.1.2501"
}
