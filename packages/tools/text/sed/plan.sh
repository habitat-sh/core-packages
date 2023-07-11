pkg_name="sed"
pkg_origin="core"
pkg_version="4.8"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
sed (stream editor) is a non-interactive command-line text editor. sed is \
commonly used to filter text, i.e., it takes text input, performs some \
operation (or set of operations) on it, and outputs the modified text. sed is \
typically used for extracting part of a file using pattern matching or \
substituting multiple occurrences of a string within a file.\
"
pkg_upstream_url="https://www.gnu.org/software/sed/"
pkg_license=("GPL-3.0-or-later")
pkg_source="http://ftp.gnu.org/gnu/$pkg_name/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="f79b0cfea71b37a8eeec8490db6c5f7ae7719c35587f21edb0617f370eeff633"
pkg_deps=(
	core/acl
	core/glibc
)
pkg_build_deps=(
	core/gcc
	core/shadow
	core/build-tools-perl
)
pkg_bin_dirs=(bin)

do_check() {
	chown -R hab .
	su hab -c "PATH=$PATH make check"
}
