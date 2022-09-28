app_name="glibc"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-glibc"
pkg_origin="core"
pkg_version="2.36"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU C Library project provides the core libraries for the GNU system and \
GNU/Linux systems, as well as many other systems that use Linux as the \
kernel. These libraries provide critical APIs including ISO C11, \
POSIX.1-2008, BSD, OS-specific APIs and more. These APIs include such \
foundational facilities as open, read, write, malloc, printf, getaddrinfo, \
dlopen, pthread_create, crypt, login, exit and more.\
"
pkg_upstream_url="https://www.gnu.org/software/libc"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="http://ftp.gnu.org/gnu/${app_name}/${app_name}-${pkg_version}.tar.xz"
pkg_shasum="1c959fea240906226062cb4b1e7ebce71a9f0e3c0836c09e7e3423d434fcfe75"
pkg_dirname="${app_name}-${pkg_version}"
pkg_deps=(
    core/build-tools-linux-headers
)

pkg_build_deps=(
    core/native-cross-binutils
    core/native-cross-gcc-real
)

pkg_bin_dirs=(bin sbin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
    PATH="$(pkg_path_for native-cross-binutils)/$native_target/bin:$(pkg_path_for native-cross-gcc-real)/bin:${PATH}"
    # Don't use the system's `/etc/ld.so.cache` and `/etc/ld.so.preload`, but
    # rather the version under `$pkg_prefix/etc`.
    #
    # Thanks to https://github.com/NixOS/nixpkgs/blob/54fc2db/pkgs/development/libraries/glibc/dont-use-system-ld-so-cache.patch
    # and to https://github.com/NixOS/nixpkgs/blob/dac591a/pkgs/development/libraries/glibc/dont-use-system-ld-so-preload.patch
    # shellcheck disable=SC2002
    cat "$PLAN_CONTEXT/dont-use-system-ld-so-preload.patch" |
        sed "s,@PREFIX@,$pkg_prefix,g" |
        patch -p1

    patch -p1 <"$PLAN_CONTEXT/dont-use-system-ld-so-cache.patch"
    CPPFLAGS="${CPPFLAGS} -isystem $(pkg_path_for native-cross-gcc-real)/bootstrap-include"
    # We cannot have RPATH set in the glibc binaries
    unset LD_RUN_PATH
}

do_build() {
    mkdir -v build
    pushd build || exit 1

    "../configure" \
        --prefix="$pkg_prefix" \
        --build="$(../config.guess)" \
        --host="$native_target" \
        --sbindir="$pkg_prefix/bin" \
        --with-headers="$(pkg_path_for build-tools-linux-headers)/include" \
        --libdir="$pkg_prefix/lib" \
        --libexecdir="$pkg_prefix/lib/glibc" \
        --sysconfdir="$pkg_prefix/etc" \
        --enable-kernel=5.4 \
        libc_cv_slibdir="$pkg_prefix"/lib

    make -j"$(nproc)"

    popd >/dev/null || exit 1
}

do_install() {
    pushd build || exit 1
    make install
    popd || exit 1
    rm -f "$pkg_prefix/bin/sln"
}
