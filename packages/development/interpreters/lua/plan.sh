program=lua
pkg_origin=core
pkg_name=lua
pkg_version=5.4.6
pkg_description="A powerful, efficient, lightweight, embeddable scripting language"
pkg_upstream_url="https://www.lua.org/"
pkg_license=("MIT")
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://www.lua.org/ftp/lua-${pkg_version}.tar.gz"
pkg_shasum=7d5ea1b9cb6aa0b59ca3dde1c6adcb57ef83a1ba8e5432c0ecd06bf439b3ad88
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
	core/make
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
    make linux MYCFLAGS="$CFLAGS -fPIC" MYLDFLAGS="$LDFLAGS" INSTALL_TOP="$pkg_prefix"
}

do_check() {
    make test
}

do_install() {
    make install INSTALL_TOP="$pkg_prefix"
    rm -rf "${pkg_prefix}/share"
}
