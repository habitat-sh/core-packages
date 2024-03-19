program="expect"

pkg_name="expect"
pkg_origin="core"
pkg_version="5.45.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Expect is a tool for automating interactive applications such as telnet, ftp, \
passwd, fsck, rlogin, tip, etc. Expect really makes this stuff trivial. Expect \
is also useful for testing these same applications.\
"
pkg_upstream_url="https://www.nist.gov/services-resources/software/expect"
pkg_license=('LicenseRef-Public-Domain')
pkg_source="https://prdownloads.sourceforge.net/${program}/${program}${pkg_version}.tar.gz"
pkg_shasum="49a7da83b0bdd9f46d04a04deec19c7767bb9a323e40c4781f89caf760b92c34"
pkg_dirname=${program}${pkg_version}
pkg_deps=(
	core/tcl
	core/glibc
)
pkg_build_deps=(
	core/gcc
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	do_default_prepare

	# Make the path to `stty` absolute from `coreutils`
	sed -i "s,/bin/stty,$(pkg_path_for coreutils)/bin/stty,g" configure
}

do_build() {
	# We need to explicitly set the --exec-prefix to pkg_prefix so that the
	# 'expect' binary is installed in the $pkg_prefix/bin directory
	./configure \
		--prefix="$pkg_prefix" \
		--exec-prefix="$pkg_prefix" \
		--build="${pkg_target%%-*}"-unknown-linux-gnu \
		--with-tcl="$(pkg_path_for tcl)/lib" \
		--with-tclinclude="$(pkg_path_for tcl)/include"
	make
}

do_check() {
	make test
}

do_install() {
	make install

	# Add an absolute path to `tclsh` in each script binary
	find "$pkg_prefix/bin" \
		-type f \
		-exec sed -e "s,exec tclsh,exec $(pkg_path_for tcl)/bin/tclsh,g" -i {} \;

}
