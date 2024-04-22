program="findutils"

pkg_name="findutils"
pkg_origin="core"
pkg_version="4.9.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU Find Utilities are the basic directory searching utilities of the GNU \
operating system. These programs are typically used in conjunction with other \
programs to provide modular and powerful directory search and file locating \
capabilities to other commands.\
"
pkg_upstream_url="http://www.gnu.org/software/findutils"
pkg_license=('GPL-3.0-only')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.xz"
pkg_shasum="a2bfb8c09d436770edc59f50fa483e785b161a3b7b9d547573cb08065fd462fe"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
	core/shadow
	core/dejagnu
)
pkg_bin_dirs=(bin)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--localstatedir="$pkg_svc_var_path/locate"
	make
}

do_check() {
	chown -R hab .
	su hab -c "PATH=$PATH make check"
}

do_install() {
	make install

	install -Dm644 ${CACHE_PATH}/COPYING ${pkg_prefix}
}
