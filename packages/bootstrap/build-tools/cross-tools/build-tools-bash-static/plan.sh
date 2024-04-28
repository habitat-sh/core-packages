program="bash"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-bash-static"
pkg_origin="core"
pkg_version="5.2.21"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
 Bash is the GNU Project's shell. Bash is the Bourne Again SHell. Bash is an \
sh-compatible shell that incorporates useful features from the Korn shell \
(ksh) and C shell (csh). It is intended to conform to the IEEE POSIX \
P1003.2/ISO 9945.2 Shell and Tools standard. It offers functional \
improvements over sh for both programming and interactive use. In addition, \
most sh scripts can be run by Bash without modification.\
"
pkg_upstream_url="http://www.gnu.org/software/bash/bash.html"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="c8e31bdc59b69aaffc5b36509905ba3e5cbb12747091d27b4b977f078560d5b8"
pkg_dirname="${program}-${pkg_version}"
pkg_interpreters=(
	bin/sh
	bin/bash
)
pkg_build_deps=(
	core/native-cross-gcc
)
pkg_bin_dirs=(bin)

do_prepare() {
	# Cross building bash still requires use of the host system's compiler to compile
	# So we explicitly clear out all CFLAGS, CPPFLAGS and LDFLAGS for build.
	export CFLAGS_FOR_BUILD=""
	export CPPFLAGS_FOR_BUILD=""
	export LDFLAGS_FOR_BUILD=""

	build_line "Setting CFLAGS_FOR_BUILD=$CFLAGS_FOR_BUILD"
	build_line "Setting CPPFLAGS_FOR_BUILD=$CPPFLAGS_FOR_BUILD"
	build_line "Setting LDFLAGS_FOR_BUILD=$LDFLAGS_FOR_BUILD"
}

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--build="$(support/config.guess)" \
		--host="$native_target" \
		--without-bash-malloc \
		--enable-static-link
	make
}

do_install() {
	make install
	ln -sv bash "$pkg_prefix/bin/sh"

	# Remove unnecessary binaries
	rm -v "${pkg_prefix}/bin/bashbug"
}
