program="ncurses"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-ncurses"
pkg_origin="core"
pkg_version="6.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
ncurses (new curses) is a programming library providing an application \
programming interface (API) that allows the programmer to write text-based \
user interfaces in a terminal-independent manner.\
"
pkg_upstream_url="https://www.gnu.org/software/ncurses/"
pkg_license=('ncurses')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="97fc51ac2b085d4cde31ef4d2c3122c21abc217e9090a43a30fc5ec21684e059"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
    core/build-tools-libstdcpp
    core/build-tools-glibc
)
pkg_build_deps=(
    core/native-cross-gcc
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
    # Cross building ncurses still requires use of the host system's compiler.
    # We move the LD_RUN_PATH into the LDFLAGS instead and unset LD_RUN_PATH so 
    # it doesn't get picked up by the native compiler. 
    # We alse use the --with-build-ldflags="" to ensure the native compiler doesn't pick up rpath
    LDFLAGS="${LDFLAGS} -Wl,-rpath=${LD_RUN_PATH}"
    build_line "Updating LDFLAGS=${LDFLAGS}"
    unset LD_RUN_PATH
}

do_build() {
    sed -i s/mawk// configure

    # We run this in a sub shell so we can preserve the original build environment
    (
        mkdir build
        pushd build || exit 1
        
        # We clear out all environment variables that interfere with the native compiler
        unset PREFIX
        unset PKG_CONFIG_PATH
        unset LD_RUN_PATH
        unset LDFLAGS
        unset CFLAGS
        unset CPPFLAGS
        unset CXXFLAGS

        ../configure \
            --build="$(../config.guess)" \
            --host="$(../config.guess)" \
            --target="$(../config.guess)" \
            --with-build-cflags="" \
            --with-build-cppflags="" \
            --with-build-ldflags=""
        make -C include
        make -C progs tic
        popd || exit 1
    )

    ./configure \
        --prefix="$pkg_prefix" \
        --build="$(./config.guess)" \
        --host="$native_target" \
        --with-shared \
        --without-normal \
        --with-cxx-shared \
        --without-debug \
        --without-ada \
        --disable-stripping \
        --with-build-cflags="" \
        --with-build-cppflags="" \
        --with-build-ldflags="" \
        --enable-widec
    make
}

do_install() {
    make TIC_PATH="$(pwd)"/build/progs/tic install
    echo "INPUT(-lncursesw)" >"$pkg_prefix/lib/libncurses.so"
}

do_check() {
    make check
}
