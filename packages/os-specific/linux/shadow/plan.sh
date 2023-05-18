program="shadow"

pkg_name="shadow"
pkg_origin="core"
pkg_version="4.12.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Password and account management tool suite.
"
pkg_upstream_url="https://github.com/shadow-maint/shadow"
pkg_license=('BSD-3-Clause')
pkg_source="https://github.com/shadow-maint/shadow/releases/download/${pkg_version}/shadow-${pkg_version}.tar.gz"
pkg_shasum="f525154adc5605e4ebf03d3e7ee8be4d7f3c7cf9df2c2244043406b6eefca2da"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/attr
	core/acl
)

pkg_build_deps=(
	core/gcc
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)

do_prepare() {
	# Disable the installation of the groups program and its man pages, as Coreutils provides a better version. Also, prevent the installation of manual pages that were already installed in man-pages
	sed -i 's/groups$(EXEEXT) //' src/Makefile.in
	find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;
	find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
	find man -name Makefile.in -exec sed -i 's/passwd\.5 / /' {} \;

	sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
		-e 's:/var/spool/mail:/var/mail:' \
		-e '/PATH=/{s@/sbin:@@;s@/bin:@@}' \
		-i etc/login.defs

}

do_build() {
	./configure --sysconfdir="${pkg_prefix}/etc" \
		--with-group-name-max-length=32

	make
}

do_install() {
	make exec_prefix="${pkg_prefix}" install

	# Move all binaries in `sbin/` into `bin/` as this isn't handled by
	# `./configure`.
	mv "$pkg_prefix/sbin"/* "$pkg_prefix/bin/"
	rm -rf "$pkg_prefix/sbin"
}
