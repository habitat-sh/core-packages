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
    export LDFLAGS_FOR_BUILD=""
    export CFLAGS_FOR_BUILD=""
    export CPPFLAGS_FOR_BUILD=""
    export CXXFLAGS_FOR_BUILD=""
    # export LD_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/ld"
    # export AS_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/as"
    # export AR_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/ar"
    # export NM_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/nm"
    # export OBJCOPY_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/objcopy"
    # export OBJDUMP_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/objdump"
    # export RANLIB_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/ranlib"
    # export READELF_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/readelf"
    # export STRIP_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/strip"
    
    export LDFLAGS_FOR_TARGET="-L$(pwd)/${native_target}/libgcc ${LDFLAGS}"
    export CPPFLAGS_FOR_TARGET="${CPPFLAGS}"
    export CFLAGS_FOR_TARGET="${CFLAGS}"
    export CXXFLAGS_FOR_TARGET="${CXXFLAGS}"
    export CC_FOR_TARGET="$(pkg_path_for native-cross-gcc)/bin/${native_target}-gcc"
    # export LD_FOR_TARGET="$(pkg_path_for native-cross-binutils)/bin/${native_target}-ld"
    # export AS_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/as"
    # export AR_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/ar"
    # export NM_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/nm"
    # export OBJCOPY_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/objcopy"
    # export OBJDUMP_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/objdump"
    # export RANLIB_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/ranlib"
    # export READELF_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/readelf"
    # export STRIP_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/strip"

    

    export NATIVE_SYSTEM_HEADER_DIR="$(pkg_path_for build-tools-glibc)/include"

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
    # LDFLAGS_FOR_BUILD="" \
    #     CFLAGS_FOR_BUILD="" \
    #     CPPFLAGS_FOR_BUILD="" \
    #     CXXFLAGS_FOR_BUILD="" \
    #     LD_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/ld" \
    #     AS_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/as" \
    #     AR_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/ar" \
    #     NM_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/nm" \
    #     OBJCOPY_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/objcopy" \
    #     OBJDUMP_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/objdump" \
    #     RANLIB_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/ranlib" \
    #     READELF_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/readelf" \
    #     STRIP_FOR_BUILD="$(pkg_path_for native-cross-binutils)/${native_target}/bin/strip" \
    #     LDFLAGS_FOR_TARGET="-L$(pwd)/${native_target}/libgcc ${LDFLAGS}" \
    #     CPPFLAGS_FOR_TARGET="${CPPFLAGS}" \
    #     CFLAGS_FOR_TARGET="${CFLAGS}" \
    #     CXXFLAGS_FOR_TARGET="${CXXFLAGS}" \
    #     LD_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/ld" \
    #     AS_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/as" \
    #     AR_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/ar" \
    #     NM_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/nm" \
    #     OBJCOPY_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/objcopy" \
    #     OBJDUMP_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/objdump" \
    #     RANLIB_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/ranlib" \
    #     READELF_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/readelf" \
    #     STRIP_FOR_TARGET="$(pkg_path_for build-tools-binutils)/bin/strip" \
    #     NATIVE_SYSTEM_HEADER_DIR="$(pkg_path_for build-tools-glibc)/include" \
    ../configure \
        --prefix="$pkg_prefix" \
        --build="$(../config.guess)" \
        --host="$native_target" \
        --target="$native_target" \
        --with-sysroot="$pkg_prefix" \
        --with-gmp="$(pkg_path_for build-tools-libgmp)" \
        --with-isl="$(pkg_path_for build-tools-libisl)" \
        --with-mpfr="$(pkg_path_for build-tools-libmpfr)" \
        --with-mpc="$(pkg_path_for build-tools-libmpc)" \
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
    make
    popd || exit 1
}

do_install() {
    pushd build || exit 1
    make install
    popd || exit 1
}
