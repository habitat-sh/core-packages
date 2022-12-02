pkg_name="gdbm"
pkg_origin="core"
pkg_version="1.23"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GNU dbm is a set of database routines that use extensible hashing. It works \
similar to the standard UNIX dbm routines.\
"
pkg_upstream_url="http://www.gnu.org/software/gdbm/gdbm.html"
pkg_license=('gplv3+')
pkg_source="http://ftp.gnu.org/gnu/$pkg_name/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="74b1081d21fff13ae4bd7c16e5d6e504a4c26f7cde1dca0d963a484174bbcacd"
pkg_deps=(
	core/glibc
	core/readline
)
pkg_build_deps=(
	core/bison
	core/coreutils
	core/dejagnu
	core/flex
	core/gawk
	core/gettext
	core/gcc
	core/grep
	core/gzip
	core/make
	core/sed
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--enable-libgdbm-compat
	make
}

do_check() {
	make check
}

do_install() {
	do_default_install

	# create symlinks for compatibility
	install -dm755 "$pkg_prefix/include/gdbm"
	ln -sf ../gdbm.h "$pkg_prefix/include/gdbm/gdbm.h"
	ln -sf ../ndbm.h "$pkg_prefix/include/gdbm/ndbm.h"
	ln -sf ../dbm.h "$pkg_prefix/include/gdbm/dbm.h"
}
