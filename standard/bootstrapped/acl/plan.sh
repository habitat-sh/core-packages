pkg_name="acl"
pkg_origin="core"
pkg_version="2.3.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Commands for Manipulating POSIX Access Control Lists.
"
pkg_upstream_url="https://savannah.nongnu.org/projects/acl/"
pkg_license=('LGPL-3.0-or-later')
pkg_source="http://download.savannah.gnu.org/releases/$pkg_name/$pkg_name-${pkg_version}.tar.gz"
pkg_shasum="760c61c68901b37fdd5eefeeaf4c0c7a26bdfdd8ac747a1edff1ce0e243c11af"

pkg_deps=(
    core/glibc
    core/attr
)
pkg_build_deps=(
    core/gcc-bootstrap
    core/build-tools-make
    core/build-tools-grep
    core/build-tools-sed
    core/build-tools-patchelf
    core/build-tools-coreutils
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)

do_build() {
    ./configure \
        --prefix="$pkg_prefix" \
        --docdir="$pkg_prefix/share/doc/acl-2.3.1" \
        --disable-static
    make
}

do_check() {
    make check
}

do_install() {
    make install
    patchelf --shrink-rpath "${pkg_prefix}/bin/chacl"
    patchelf --shrink-rpath "${pkg_prefix}/bin/getfacl"
    patchelf --shrink-rpath "${pkg_prefix}/bin/setfacl"
    patchelf --shrink-rpath "${pkg_prefix}/lib/libacl.so.1.1.2301"
}
