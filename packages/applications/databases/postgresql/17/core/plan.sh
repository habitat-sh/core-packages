# shellcheck disable=SC2164
pkg_name="postgresql17"
pkg_version="17.2"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="PostgreSQL is a powerful, open source object-relational database system."
pkg_upstream_url="https://www.postgresql.org/"
pkg_license=('PostgreSQL' 'Spencer-99' 'TCL')
pkg_dirname="postgresql-${pkg_version}"
pkg_source="https://ftp.postgresql.org/pub/source/v${pkg_version}/${pkg_dirname}.tar.bz2"
pkg_shasum="82ef27c0af3751695d7f64e2d963583005fbb6a0c3df63d0e4b42211d7021164"

pkg_deps=(
	core/bash
	core/glibc
	core/libossp-uuid
	core/openssl
	core/perl
	core/readline
	core/zlib
)

pkg_build_deps=(
	core/coreutils
	core/gcc
	core/make
	core/pkg-config
	core/bison
	core/flex
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

pkg_exports=(
	[port]=port
	[superuser_name]=superuser.name
	[superuser_password]=superuser.password
)
pkg_exposes=(port)

do_prepare() {
	LDFLAGS="${LDFLAGS}  -Wl,-rpath=${pkg_prefix}/lib"
	build_line "Updating LDFLAGS=${LDFLAGS}"
}

do_build() {
	./configure --prefix="$pkg_prefix" \
		--disable-rpath \
		--with-ssl=openssl \
		--with-uuid=ossp \
		--without-icu \
		--with-libraries="$pkg_prefix/lib" \
		--sysconfdir="$pkg_svc_config_path" \
		--localstatedir="$pkg_svc_var_path"
	make --jobs="$(nproc)" world-bin
}

do_install() {
	make install-world-bin

	# remove unwanted linking paths from binaries
	find "$pkg_prefix"/bin -type f -executable -exec patchelf --shrink-rpath {} \;
}
