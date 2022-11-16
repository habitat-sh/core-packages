program="gcc"

pkg_name="gcc-stage1"
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
pkg_source="http://ftp.gnu.org/gnu/$program/${program}-${pkg_version}/${program}-${pkg_version}.tar.xz"
pkg_shasum="e549cf9cf3594a00e27b6589d4322d70e0720cdd213f39beb4181e06926230ff"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
    core/binutils-stage1
    core/glibc-stage0
    core/gmp-stage0
    core/isl-stage0
    core/mpfr-stage0
    core/mpc-stage0
    core/build-tools-bash-static
)

pkg_build_deps=(
    core/gcc-stage0
    core/zlib-stage0
    core/linux-headers
    core/build-tools-texinfo
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib lib64)

do_prepare() {
    # We unset all flags that will interfere with the compiler
    unset LD_RUN_PATH

    case $pkg_target in
    aarch64-linux)
        dynamic_linker="$(pkg_path_for glibc-stage0)/lib/ld-linux-aarch64.so.1"
        ;;
    x86_64-linux)
        dynamic_linker="$(pkg_path_for glibc-stage0)/lib/ld-linux-x86-64.so.2"
        ;;
    esac

    # Add extra flags so that the xgcc compiler generated for the target
    # platform works correctly. It needs to be able to find the C runtime
    # startfiles in glibc and the dynamic linker to be used.
    EXTRA_LDFLAGS="${LDFLAGS} -Wl,-dynamic-linker=${dynamic_linker}"

    # Add extra flags which will get passed to the build/gcc/xgcc and 
    # build/gcc/xg++ compilers. These compilers are used to compile the final
    # libraries for the target: libatomic, libgomp, libstdc++, libvtv, libgcc,
    # libquadmath, libbacktrace, libsanitizer and libssp
    FLAGS_FOR_TARGET="-B$(pkg_path_for glibc-stage0)/lib \
        -L$(pkg_path_for glibc-stage0)/lib \
        -idirafter $(pkg_path_for glibc-stage0)/include \
        -idirafter $(pkg_path_for linux-headers)/include"

    # Remove the gcc binary directory from the PATH, otherwise the build process
    # will begin to pick up the just built compiler linker for compilation
    PATH=$(path_remove "${PATH}" "${pkg_prefix}/bin")
    build_line "Updated PATH=${PATH}"

    # Tell gcc not to look under the default `/lib/` and `/usr/lib/` directories
    # for libraries
    #
    # Thanks to: https://raw.githubusercontent.com/NixOS/nixpkgs/release-22.05/pkgs/development/compilers/gcc/gcc-12-no-sys-dirs.patch
    # shellcheck disable=SC2002
    patch -p1 <"$PLAN_CONTEXT/gcc-12-no-sys-dirs.patch"
    # CPPFLAGS="${CPPFLAGS} -Wp,--verbose"
}

do_build() {
    mkdir -v build
    pushd build || exit 1

    ../configure \
        LDFLAGS_FOR_TARGET="${EXTRA_LDFLAGS}" \
        CPPFLAGS_FOR_TARGET="${EXTRA_LDFLAGS} ${CPPFLAGS}" \
        CFLAGS_FOR_TARGET="${EXTRA_LDFLAGS} ${CFLAGS}" \
        CXXFLAGS_FOR_TARGET="${EXTRA_LDFLAGS} ${CXXFLAGS}" \
        LD="$(pkg_path_for binutils-stage1)"/bin/ld \
        --prefix="$pkg_prefix" \
        --with-gmp="$(pkg_path_for gmp-stage0)" \
        --with-isl="$(pkg_path_for isl-stage0)" \
        --with-mpfr="$(pkg_path_for mpfr-stage0)" \
        --with-mpc="$(pkg_path_for mpc-stage0)" \
        --with-native-system-header-dir="$(pkg_path_for glibc-stage0)/include" \
        --enable-default-pie \
        --enable-default-ssp \
        --disable-multilib \
        --disable-bootstrap \
        --with-system-zlib \
        --enable-languages=c,c++

    make \
        FLAGS_FOR_TARGET="${FLAGS_FOR_TARGET}" \
        -j"$(nproc)" \
        --output-sync

    popd || exit 1
}

do_install() {
    pushd build || exit 1
    make install

    # Many packages use the name cc to call the C compiler
    ln -sv gcc "$pkg_prefix/bin/cc"

    wrap_binary "c++"
    wrap_binary "gcc"
    wrap_binary "g++"
    wrap_binary "cpp"

    popd || exit 1
}

wrap_binary() {
    local bin="$pkg_prefix/bin/$1"
    build_line "Adding wrapper $bin to ${bin}.real"
    mv -v "$bin" "${bin}.real"
    case $pkg_target in
    aarch64-linux)
        dynamic_linker="$(pkg_path_for glibc-stage0)/lib/ld-linux-aarch64.so.1"
        ;;
    x86_64-linux)
        dynamic_linker="$(pkg_path_for glibc-stage0)/lib/ld-linux-x86-64.so.2"
        ;;
    esac
    sed "$PLAN_CONTEXT/cc-wrapper.sh" \
        -e "s^@bash@^$(pkg_path_for build-tools-bash-static)/bin/bash^g" \
        -e "s^@glibc@^$(pkg_path_for glibc-stage0)^g" \
        -e "s^@linux_headers@^$(pkg_path_for linux-headers)^g" \
        -e "s^@binutils@^$(pkg_path_for binutils-stage1)^g" \
        -e "s^@dynamic_linker@^${dynamic_linker}^g" \
        -e "s^@program@^${bin}.real^g" \
        >"$bin"
    chmod 755 "$bin"
}

# Courtesy https://unix.stackexchange.com/questions/108873/removing-a-directory-from-path
function path_remove {
    local new_path="$1"
    # Delete path by parts so we can never accidentally remove sub paths
    if [ "$new_path" == "$2" ]; then
        new_path=""
    fi
    new_path=${new_path//":$2:"/":"} # delete any instances in the middle
    new_path=${new_path/#"$2:"/}     # delete any instance at the beginning
    new_path=${new_path/%":$2"/}     # delete any instance in the at the end
    echo "$new_path"
    return 0
}
