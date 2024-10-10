program=ShellCheck

pkg_name=shellcheck
pkg_origin=core
pkg_version="0.10.0"
pkg_license=('GPL-3.0-or-later')
pkg_upstream_url="http://www.shellcheck.net/"
pkg_description="ShellCheck is a GPLv3 tool that gives warnings and suggestions for bash/sh shell scripts"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://github.com/koalaman/shellcheck/releases/download/v${pkg_version}/shellcheck-v${pkg_version}.linux.x86_64.tar.xz"
pkg_shasum="6c881ab0698e4e6ea235245f22832860544f17ba386442fe7e9d629f8cbedf87"
pkg_dirname="shellcheck-v${pkg_version}"

pkg_bin_dirs=(bin)

do_build() {
	return 0
}

do_install() {
	cp ${CACHE_PATH}/* ${pkg_prefix}
	mv ${pkg_prefix}/shellcheck ${pkg_prefix}/bin
}
