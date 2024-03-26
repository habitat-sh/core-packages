program="gzip"

pkg_name="gzip"
pkg_origin="core"
pkg_version="1.12"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GNU Gzip is a popular data compression program originally written by Jean-loup \
Gailly for the GNU project.\
"
pkg_upstream_url="https://www.gnu.org/software/gzip/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.xz"
pkg_shasum="ce5e03e519f637e1f814011ace35c4f87b33c0bbabeec35baf5fbd3479e91956"

pkg_deps=(
	core/coreutils
	core/diffutils
	core/glibc
	core/grep
	core/less
)
pkg_build_deps=(
	core/gcc
	core/build-tools-perl
	core/build-tools-util-linux
)
pkg_bin_dirs=(bin)

do_build() {
	./configure \
		--prefix="$pkg_prefix"

	make -j"$(nproc)"
}

do_check() {
	make check
}

do_install() {
	make install
}
