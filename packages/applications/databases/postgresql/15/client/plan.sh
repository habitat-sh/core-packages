pkg_name=postgresql15-client
pkg_version=15.1
pkg_origin=core
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="PostgreSQL is a powerful, open source object-relational database system."
pkg_upstream_url="https://www.postgresql.org/"
pkg_license=('PostgreSQL')
pkg_dirname="postgresql-${pkg_version}"
pkg_source="https://ftp.postgresql.org/pub/source/v${pkg_version}/${pkg_dirname}.tar.bz2"
pkg_shasum="64fdf23d734afad0dfe4077daca96ac51dcd697e68ae2d3d4ca6c45cb14e21ae"

pkg_deps=(
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
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

# These commands only make sense for if there's a postgres server
# running locally, and in that case can use the versions that came
# with that install

server_execs=(
	ecpg
	initdb
	pg_archivecleanup
	pg_controldata
	pg_resetxlog
	pg_rewind
	pg_test_fsync
	pg_test_timing
	pg_upgrade
	pg_xlogdump
	pg_bench
	pg_resetwal
	pg_waldump
	pg_ctl
	pg_checksums
)

server_includes=(
	informix
	server
)

do_prepare() {
	LDFLAGS="${LDFLAGS}  -Wl,-rpath=${pkg_prefix}/lib"
	build_line "Updating LDFLAGS=${LDFLAGS}"
}

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
	make -C src/bin install
	make -C src/include install
	make -C src/interfaces install

	# Clean up files needed only for server installs
	# this shrinks the package by about 60%
	echo "Purging unneeded execs"
	for unneeded in "${server_execs[@]}"; do
		target="$pkg_prefix/bin/${unneeded}"
		echo "rm -f ${target}"
		rm -f "${target}"
	done
	echo "Purging unneeded includes"
	for unneeded in "${server_includes[@]}"; do
		target="$pkg_prefix/include/${unneeded}"
		echo "rm -rf ${target}"
		rm -rf "${target}"
	done
}
