program="coreutils"

pkg_name="coreutils-stage1"
pkg_origin="core"
pkg_version="9.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU Core Utilities are the basic file, shell and text manipulation \
utilities of the GNU operating system. These are the core utilities which are \
expected to exist on every operating system.\
"
pkg_upstream_url="https://www.gnu.org/software/coreutils/"
pkg_license=("GPL-3.0-or-later")
pkg_source="http://ftp.gnu.org/gnu/$program/${program}-${pkg_version}.tar.xz"
pkg_shasum="61a1f410d78ba7e7f37a5a4f50e6d1320aca33375484a3255eddf17a38580423"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
)

pkg_build_deps=(
	core/bash-static
	core/gcc
	core/acl-stage1
	core/attr-stage1
	core/libcap-stage1
	core/build-tools-perl
	core/build-tools-util-linux
	core/build-tools-python
)
pkg_bin_dirs=(bin)
pkg_interpreters=(bin/env bin/coreutils)

do_build() {
	FORCE_UNSAFE_CONFIGURE=1 ./configure \
		--prefix="$pkg_prefix" \
		--enable-single-binary \
		--enable-no-install-program="kill,uptime"
	make
}

do_check() {
	# Patch test to ensure they run
	find tests -name "*.pl" -o -name "*.xpl" \( -exec sed -e "s^#\!.*bin/perl^#\!$(pkg_path_for build-tools-perl)/bin/perl^" -i {} + \)
	sed -e "s^#\!.*bin/python^#\!$(pkg_path_for build-tools-python)/bin/python^" -i tests/d_type-check
	make NON_ROOT_USERNAME=nobody check-root
	make RUN_EXPENSIVE_TESTS=yes check
}
