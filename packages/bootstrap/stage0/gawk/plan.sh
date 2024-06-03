program="gawk"

pkg_name="gawk"
pkg_origin="core"
pkg_version="5.1.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The awk utility interprets a special-purpose programming language that makes \
it possible to handle simple data-reformatting jobs with just a few lines of \
code.\
"
pkg_upstream_url="http://www.gnu.org/software/gawk/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="03a0360edcd84bec156fe211bbc4fc8c78790973ce4e8b990a11d778d40b1a26"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/clang
)
pkg_bin_dirs=(bin)
pkg_interpreters=(bin/awk bin/gawk)

do_build() {
	./configure \
		--prefix="$pkg_prefix"
	make
}

do_install() {
	make install
}
