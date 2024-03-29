pkg_origin="core"
pkg_name="which"
pkg_version="2.21"
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/which/which-"${pkg_version}".tar.gz"
pkg_upstream_url="https://savannah.gnu.org/projects/which"
pkg_description="GNU which - is a utility that is used to find which executable (or alias or shell function) is executed when entered on the shell prompt."
pkg_shasum="f4a245b94124b377d8b49646bf421f9155d36aa7614b6ebf83705d3ffc76eaad"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
)
pkg_bin_dirs=(bin)

do_check() {
	make check
}
