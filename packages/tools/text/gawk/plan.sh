program="gawk"

pkg_name="gawk"
pkg_origin="core"
pkg_version="5.2.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The awk utility interprets a special-purpose programming language that makes \
it possible to handle simple data-reformatting jobs with just a few lines of \
code.\
"
pkg_upstream_url="http://www.gnu.org/software/gawk/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="ef5af4449cb0269faf3af24bf4c02273d455f0741bf3c50f86ddc09332d6cf56"
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

do_prepare() {
	# Prevent building unnecessary binaries
	sed -i 's/extras//' Makefile.in
	# Fix a bug from upstream: https://clfs.org/~kb0iic/lfs-systemd/chapter08/gawk.html
	sed -i '241i UPREF(m);' interpret.h
}

do_check() {
	# This currently passes in core-plans CI but may fail on some workstations.
	# Ref: https://github.com/habitat-sh/core-plans/issues/2879
	make check
}
