app_name="gcc"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"
glibc_version="2.36"

pkg_name="build-tools-gcc"
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
    core/build-tools-glibc
    core/build-tools-libgmp
    core/build-tools-libisl
    core/build-tools-libmpfr
    core/build-tools-libmpc
)

pkg_build_deps=(
    core/build-tools-binutils
    core/build-tools-linux-headers
    core/native-cross-gcc
    core/native-cross-binutils
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
    # We move the LD_RUN_PATH into the LDFLAGS and unset LD_RUN_PATH
    # so that the build compiler and linker doesn't pick it up.
    export LDFLAGS="${LDFLAGS} -Wl,-rpath=${LD_RUN_PATH}"
    unset LD_RUN_PATH

    # By default LDFLAGS, CFLAGS, CPPFLAGS and CXXFLAGS get used by the
    # build compiler. To prevent this we set *FLAGS_FOR_BUILD="" to
    # prevent any interference with the build compiler and linker.
    export LDFLAGS_FOR_BUILD="${LDFLAGS}"
    export CFLAGS_FOR_BUILD=""
    export CPPFLAGS_FOR_BUILD=""
    export CXXFLAGS_FOR_BUILD=""
    
    export LDFLAGS_FOR_TARGET="-L$(pwd)/build/${native_target}/libgcc ${LDFLAGS}"
    export CPPFLAGS_FOR_TARGET="${CPPFLAGS}"
    export CFLAGS_FOR_TARGET="${CFLAGS}"
    export CXXFLAGS_FOR_TARGET="${CXXFLAGS}"
    
    unset LDFLAGS
    unset CPPFLAGS
    unset CFLAGS
    unset CXXFLAGS

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
        --host="$native_target" \
        --target="$native_target" \
        --with-gmp="$(pkg_path_for build-tools-libgmp)" \
        --with-isl="$(pkg_path_for build-tools-libisl)" \
        --with-mpfr="$(pkg_path_for build-tools-libmpfr)" \
        --with-mpc="$(pkg_path_for build-tools-libmpc)" \
        --with-build-sysroot="" \
        --with-sysroot="" \
        --with-native-system-header-dir="$(pkg_path_for build-tools-glibc)/include" \
        --with-glibc-version="$glibc_version" \
        --enable-initfini-array \
        --enable-default-pie \
        --enable-default-ssp \
        --disable-nls \
        --disable-multilib \
        --disable-decimal-float \
        --disable-libatomic \
        --disable-libgomp \
        --disable-libquadmath \
        --disable-libssp \
        --disable-libvtv \
        --enable-languages=c,c++
    make -j"$(nproc)"
    popd || exit 1
}

do_install() {
    pushd build || exit 1
    make install
    popd || exit 1
}
