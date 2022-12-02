program="shadow"

pkg_name="shadow"
pkg_origin="core"
pkg_version="4.12.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Password and account management tool suite.
"
pkg_upstream_url="https://github.com/shadow-maint/shadow"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="https://github.com/shadow-maint/shadow/releases/download/${pkg_version}/shadow-${pkg_version}.tar.gz"
pkg_shasum="f525154adc5605e4ebf03d3e7ee8be4d7f3c7cf9df2c2244043406b6eefca2da"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/gcc
	core/attr
	core/acl
	core/build-tools-findutils
	core/build-tools-bash-static
	core/build-tools-make
	core/build-tools-patchelf
	core/build-tools-sed
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

	LDFLAGS="${LDFLAGS} -L${pkg_prefix}/lib -Wl,-rpath=${pkg_prefix}/lib"
	build_line "Updating LDFLAGS=${LDFLAGS}"
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

	patchelf --shrink-rpath "${pkg_prefix}/bin/getsubids"
	patchelf --shrink-rpath "${pkg_prefix}/bin/login"
	patchelf --shrink-rpath "${pkg_prefix}/bin/su"
	patchelf --shrink-rpath "${pkg_prefix}/bin/nologin"
	patchelf --shrink-rpath "${pkg_prefix}/lib/libsubid.so.4.0.0"
}