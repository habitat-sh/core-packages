program="dejagnu"

pkg_name="dejagnu-stage1"
pkg_origin="core"
pkg_version="1.6.3"
pkg_license=('GPL-3.0-or-later')
pkg_upstream_url="https://www.gnu.org/software/dejagnu/"
pkg_description="A framework for testing other programs."
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="87daefacd7958b4a69f88c6856dbd1634261963c414079d0c371f589cd66a2e3"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/expect-stage1
	core/build-tools-bash-static
	core/build-tools-coreutils
	core/build-tools-sed
	core/build-tools-grep
	core/build-tools-gawk
)
pkg_build_deps=(
	core/gcc-stage1
	core/build-tools-diffutils
	core/build-tools-patch
	core/build-tools-make
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)

do_check() {
	make check
}

do_install() {
	make install

	# Set an absolute path `expect` in the `runtest` binary
	sed \
		-e "s,expectbin=expect,expectbin=$(pkg_path_for expect-stage1)/bin/expect,g" \
		-i "$pkg_prefix/bin/runtest"

	# Fix scripts
	fix_interpreter "${pkg_prefix}/bin/*" core/build-tools-bash-static bin/sh
}
