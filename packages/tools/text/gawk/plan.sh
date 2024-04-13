program="gawk"

pkg_name="gawk"
pkg_origin="core"
pkg_version="5.3.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The awk utility interprets a special-purpose programming language that makes \
it possible to handle simple data-reformatting jobs with just a few lines of \
code.\
"
pkg_upstream_url="http://www.gnu.org/software/gawk/"
pkg_license=('GPL-3.0-only' 'LGPL-2.0-only')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="378f8864ec21cfceaa048f7e1869ac9b4597b449087caf1eb55e440d30273336"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/mpfr
	core/gmp
	core/readline
)
pkg_build_deps=(
	core/gettext
	core/gcc
)
pkg_bin_dirs=(bin)
pkg_interpreters=(bin/awk bin/gawk)

do_build() {
	./configure --prefix="$pkg_prefix"
	make
}

do_check() {
	# This currently passes in core-plans CI but may fail on some workstations.
	# Ref: https://github.com/habitat-sh/core-plans/issues/2879
	make check
}

do_install() {
	do_default_install

	# copy license files to package
	install -Dm644 ${CACHE_PATH}/COPYING ${pkg_prefix}
	install -Dm644 ${CACHE_PATH}/missing_d/COPYING.LIB ${pkg_prefix}
}