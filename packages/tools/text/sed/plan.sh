pkg_name="sed"
pkg_origin="core"
pkg_version="4.9"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
sed (stream editor) is a non-interactive command-line text editor. sed is \
commonly used to filter text, i.e., it takes text input, performs some \
operation (or set of operations) on it, and outputs the modified text. sed is \
typically used for extracting part of a file using pattern matching or \
substituting multiple occurrences of a string within a file.\
"
pkg_upstream_url="https://www.gnu.org/software/sed/"
pkg_license=('GPL-3.0-only')
pkg_source="http://ftp.gnu.org/gnu/$pkg_name/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="6e226b732e1cd739464ad6862bd1a1aba42d7982922da7a53519631d24975181"
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

do_install() {
	do_default_install

	# copy license files to package
	install -Dm644 ${CACHE_PATH}/COPYING ${pkg_prefix}
}