# shellcheck disable=SC2164
pkg_name="postgresql14"
pkg_version="14.11"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="PostgreSQL is a powerful, open source object-relational database system."
pkg_upstream_url="https://www.postgresql.org/"
pkg_license=('PostgreSQL' 'Spencer-99' 'TCL')
pkg_dirname="postgresql-${pkg_version}"
pkg_source="https://ftp.postgresql.org/pub/source/v${pkg_version}/${pkg_dirname}.tar.bz2"
pkg_shasum="a670bd7dce22dcad4297b261136b3b1d4a09a6f541719562aa14ca63bf2968a8"

pkg_deps=(
	core/bash
	core/gawk
	core/glibc
	core/grep
	core/libossp-uuid
	core/openssl
	core/perl
	core/readline
	core/zlib
)

pkg_build_deps=(
	core/bison
	core/coreutils
	core/flex
	core/gcc
	core/make
	core/pkg-config
)
do_prepare() {
	LDFLAGS="${LDFLAGS}  -Wl,-rpath=${pkg_prefix}/lib"
	build_line "Updating LDFLAGS=${LDFLAGS}"
}

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_exports=(
	[port]=port
	[superuser_name]=superuser.name
	[superuser_password]=superuser.password
)
pkg_exposes=(port)

do_build() {
	./configure --disable-rpath \
		--with-openssl \
		--prefix="$pkg_prefix" \
		--with-uuid=ossp \
		--sysconfdir="$pkg_svc_config_path" \
		--localstatedir="$pkg_svc_var_path"
	make --jobs="$(nproc)" world
}

do_install() {
	make install-world
}
