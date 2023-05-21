program="inetutils"
pkg_name="inetutils"
pkg_origin="core"
pkg_version="1.9.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Inetutils is a collection of common network programs. It includes: an ftp \
client and server, a telnet client and server, an rsh client and server, an \
rlogin client and server, a tftp client and server, and much more...\
"
pkg_upstream_url="http://www.gnu.org/software/inetutils/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/$program/${program}-${pkg_version}.tar.xz"
pkg_shasum="849d96f136effdef69548a940e3e0ec0624fc0c81265296987986a0dd36ded37"
pkg_deps=(
	core/glibc
	core/readline
	core/ncurses
	core/libidn2
)
pkg_build_deps=(
	core/iana-etc
	core/gcc
)
pkg_bin_dirs=(bin)

do_build() {
	# Configure flag notes:
	#
	# * `--disable-logger`: prevents building the `logger`, as the version from
	#   Util-linux will be used instead
	# * `--disable-whois`: prevents building the `whois` tool, which is out of
	#   date
	# * `--disable-r*`: prevents building of obsolete programs such as `rlogin`,
	#   `rsh`, etc.
	# * `--disable-servers`: prevents the building of the server components in
	#   this codebase, such as `telnetd`, `ftpd`, etc.--a dedicated Plan for
	#   any of these service components is much preferred
	./configure \
		--prefix="$pkg_prefix" \
		--disable-logger \
		--disable-whois \
		--disable-rcp \
		--disable-rexec \
		--disable-rlogin \
		--disable-rsh \
		--disable-servers \
		--with-idn \
		--enable-threads
	make
}

do_check() {
	ln -sv "$(pkg_path_for iana-etc)/etc/protocols" /etc/protocols
	ln -sv "$(pkg_path_for iana-etc)/etc/services" /etc/services
	make check
}

do_install() {
	do_default_install

	# `libexec/` directory is not used
	rm -rfv "$pkg_prefix/libexec"
}
