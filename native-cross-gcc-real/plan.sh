app_name="gcc"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"
glibc_version="2.36"

pkg_name="native-cross-gcc-real"
pkg_origin="core"
pkg_version="12.2.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU Compiler Collection (GCC) is a compiler system produced by the GNU \
Project supporting various programming languages. GCC is a key component of \
the GNU toolchain and the standard compiler for most Unix-like operating \
systems.\
"
pkg_upstream_url="https://gcc.gnu.org/"
pkg_license=('GPL-3.0-or-later' 'GCC Runtime Library Exception')
pkg_source="http://ftp.gnu.org/gnu/$app_name/${app_name}-${pkg_version}/${app_name}-${pkg_version}.tar.xz"
pkg_shasum="e549cf9cf3594a00e27b6589d4322d70e0720cdd213f39beb4181e06926230ff"
pkg_dirname="${app_name}-${pkg_version}"

pkg_deps=(
    core/native-cross-binutils
    core/native-libgmp
    core/native-libisl
    core/native-libmpfr
    core/native-libmpc

)

# We don't specify a bin directory so that the cross compiler
# from the native-cross-gcc is found
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
    # Tell gcc not to look under the default `/lib/` and `/usr/lib/` directories
    # for libraries
    #
    # Thanks to: https://raw.githubusercontent.com/NixOS/nixpkgs/release-22.05/pkgs/development/compilers/gcc/gcc-12-no-sys-dirs.patch
    # shellcheck disable=SC2002
    patch -p1 <"$PLAN_CONTEXT/gcc-12-no-sys-dirs.patch"
}

do_build() {
    mkdir -v build
    pushd build || exit 1
    ../configure \
        --prefix="$pkg_prefix" \
        --build="$(../config.guess)" \
        --host="$(../config.guess)" \
        --target="$native_target" \
        --with-sysroot="$pkg_prefix" \
        --with-gmp="$(pkg_path_for native-libgmp)" \
        --with-isl="$(pkg_path_for native-libisl)" \
        --with-mpfr="$(pkg_path_for native-libmpfr)" \
        --with-mpc="$(pkg_path_for native-libmpc)" \
        --with-glibc-version="$glibc_version" \
        --with-newlib \
        --without-headers \
        --enable-default-pie \
        --enable-default-ssp \
        --disable-nls \
        --disable-shared \
        --disable-multilib \
        --disable-decimal-float \
        --disable-threads \
        --disable-libatomic \
        --disable-libgomp \
        --disable-libquadmath \
        --disable-libssp \
        --disable-libvtv \
        --disable-libstdcxx \
        --enable-languages=c,c++
    make -j"$(nproc)"
    popd || exit 1
}

do_install() {
    pushd build || exit 1
    make install

    # IMPORTANT: This is some build hackery to make the bootstrapping process work for us
    # The full gcc limits.h file depends on a file of the same name (limits.h) from glibc.
    # Since we haven't built glibc yet we cannot use the final version of gcc's limits.h to build glibc.
    # To work around this we make a copy of the partial limits.h in a new include folder 'bootstrap-include'
    # We then include this folder prior to the standard gcc search path to make gcc use the partial header
    # when building glibc.

    # Create a copy of the partial limits.h file that we use to compile glibc
    mkdir -v "$pkg_prefix/bootstrap-include"
    cp -v "$pkg_prefix"/lib/gcc/"$native_target"/$pkg_version/include-fixed/* "$pkg_prefix/bootstrap-include"

    # Create the full limits.h file
    cat ../gcc/limitx.h ../gcc/glimits.h ../gcc/limity.h >"$(dirname "$("$pkg_prefix"/bin/"$native_target"-gcc -print-libgcc-file-name)")"/install-tools/include/limits.h
    
    # Install the full limits.h file
    "$pkg_prefix"/libexec/gcc/"$native_target"/12.2.0/install-tools/mkheaders
    popd || exit 1

}
