program="coreutils"

pkg_name="coreutils"
pkg_origin="core"
pkg_version="9.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU Core Utilities are the basic file, shell and text manipulation \
utilities of the GNU operating system. These are the core utilities which are \
expected to exist on every operating system.\
"
pkg_upstream_url="https://www.gnu.org/software/coreutils/"
pkg_license=('GPL-3.0')
pkg_source="http://ftp.gnu.org/gnu/$program/${program}-${pkg_version}.tar.xz"
pkg_shasum="61a1f410d78ba7e7f37a5a4f50e6d1320aca33375484a3255eddf17a38580423"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/acl
	core/attr
	core/libcap
)
pkg_build_deps=(
	core/bash-static
	core/gcc
	core/shadow
	core/build-tools-coreutils
	core/build-tools-findutils
	core/build-tools-make
	core/build-tools-perl
	core/build-tools-sed
	core/build-tools-util-linux
	core/build-tools-python
)
pkg_bin_dirs=(bin)
pkg_interpreters=(bin/env)

do_build() {
	FORCE_UNSAFE_CONFIGURE=1 ./configure \
		--prefix="$pkg_prefix" \
		--enable-single-binary \
		--enable-no-install-program=kill,uptime
	make
}

do_check() {
	# Patch test to ensure they run
	find tests -name "*.pl" -o -name "*.xpl" \( -exec sed -e "s^#\!.*bin/perl^#\!$(pkg_path_for build-tools-perl)/bin/perl^" -i {} + \)
	sed -e "s^#\!.*bin/python^#\!$(pkg_path_for build-tools-python)/bin/python^" -i tests/d_type-check
	
	# Run tests that have to be run as root user
	make NON_ROOT_USERNAME=nobody check-root

	# Add the hab user to a new group 'dummy' because some tests require
	# the user to be part of 2 groups
	echo "dummy:x:102:hab" >>/etc/group

	# Change ownership of the folder to the hab user so that tests can compile
	chown -R hab .
	
	# Compile and run the expensive tests as the hab user
	su hab -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
}