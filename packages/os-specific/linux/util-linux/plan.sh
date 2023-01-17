pkg_name="util-linux"
pkg_origin="core"
pkg_version="2.38.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Miscellaneous system utilities for Linux"
pkg_upstream_url="https://www.kernel.org/pub/linux/utils/util-linux"
pkg_license=('GPLv2-or-later')
pkg_source="https://www.kernel.org/pub/linux/utils/${pkg_name}/v${pkg_version%.?}/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="60492a19b44e6cf9a3ddff68325b333b8b52b6c59ce3ebd6a0ecaa4c5117e84f"
pkg_deps=(
	core/glibc
	core/zlib
	core/ncurses
	core/readline
	core/file
)
pkg_build_deps=(
	core/bison
	core/coreutils
	core/gawk
	core/gettext
	core/gcc
	core/grep
	core/make
	core/sed
	core/pkg-config
	core/python
	core/pcre2
	core/shadow
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--sbindir="$pkg_prefix/bin" \
		--localstatedir="$pkg_svc_var_path/run" \
		--enable-nls \
		--enable-write \
		--disable-use-tty-group \
		--without-slang \
		--without-systemd \
		--without-systemdsystemunitdir \
		--disable-chfn-chsh \
		--disable-login \
		--disable-nologin \
		--disable-su \
		--disable-setpriv \
		--disable-runuser
	make
}

do_check() {
	# Change ownership of the folder to the hab user so that tests can compile
	chown -R hab .

	# Compile and run the expensive tests as the hab user
	su hab -c "PATH=$PATH make -k check"
}

do_install() {
	make install usrsbin_execdir="$pkg_prefix/bin"
}
