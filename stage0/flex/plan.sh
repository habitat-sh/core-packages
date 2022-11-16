program="flex"

pkg_name="flex-stage0"
pkg_origin="core"
pkg_version="2.6.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Flex is a fast lexical analyser generator. It is a tool for generating programs that perform pattern-matching on text. Flex is a free (but non-GNU) implementation of the original Unix lex program."
pkg_license=('custom')
pkg_upstream_url="https://www.gnu.org/software/flex/"
pkg_source="https://github.com/westes/flex/releases/download/v${pkg_version}/${program}-${pkg_version}.tar.gz"
pkg_shasum="e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
    core/glibc-stage0
)
pkg_build_deps=(
    core/gcc-stage0
    core/build-tools-coreutils
    core/build-tools-make
    core/build-tools-bison
    core/build-tools-sed
    core/build-tools-grep
    core/build-tools-texinfo
    core/build-tools-m4
    core/build-tools-patchelf
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
    ./configure \
        --prefix="${pkg_prefix}" \
        --docdir="${pkg_prefix}"/share/doc/flex-2.6.4 \
        --disable-static
}

do_check() {
    make check
}

do_install() {
    make install

    install --mode 0644 COPYING "$pkg_prefix"/

    # A few programs do not know about `flex` yet and try to run its predecessor,
    # `lex`
    ln -sv flex "$pkg_prefix/bin/lex"

    # Removes unnecesary rpath entry to build-tools-gcc/lib64
    patchelf --shrink-rpath "${pkg_prefix}/bin/flex"
    patchelf --shrink-rpath "${pkg_prefix}/lib/libfl.so.2.0.0"
}
