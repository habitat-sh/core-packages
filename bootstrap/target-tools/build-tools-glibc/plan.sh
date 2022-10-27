program="glibc"
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
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.xz"
pkg_shasum="1c959fea240906226062cb4b1e7ebce71a9f0e3c0836c09e7e3423d434fcfe75"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
    core/build-tools-linux-headers
)

pkg_build_deps=(
	core/build-tools-gcc
	core/build-tools-bison
	core/build-tools-python
)

pkg_bin_dirs=(bin sbin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
    mkdir -v build
    pushd build || exit 1

    "../configure" \
        --prefix="$pkg_prefix" \
        --with-headers="$(pkg_path_for build-tools-linux-headers)/include" \
        --enable-kernel=5.4 \
        libc_cv_slibdir="$pkg_prefix"/lib

    make

    popd >/dev/null || exit 1
}

do_check() {
	make check
}

do_install() {
    pushd build || exit 1
    make install
    popd || exit 1
    rm -f "$pkg_prefix/bin/sln"
}
