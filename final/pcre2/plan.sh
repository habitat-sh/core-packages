program="pcre2"

pkg_name="pcre2"
pkg_origin="core"
pkg_version="10.40"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The PCRE library is a set of functions that implement regular expression \
pattern matching using the same syntax and semantics as Perl 5. PCRE has its \
own native API, as well as a set of wrapper functions that correspond to the \
POSIX regular expression API. The PCRE library is free, even for building \
proprietary software.\
"
pkg_upstream_url="http://www.pcre.org/"
pkg_license=('bsd')
pkg_source="https://github.com/PCRE2Project/${program}/releases/download/${program}-${pkg_version}/${program}-${pkg_version}.tar.bz2"
pkg_shasum="14e4b83c4783933dc17e964318e6324f7cae1bc75d8f3c79bc6969f00c159d68"
pkg_deps=(
	core/glibc
	core/gcc-libs
	core/bzip2
	core/zlib
	core/readline
	core/ncurses
	core/bash-static
)
pkg_build_deps=(
	core/coreutils
	core/diffutils
	core/gcc
	core/make
	core/patch
	core/sed
	core/build-tools-grep
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--enable-unicode \
		--enable-pcre2-16 \
		--enable-pcre2-32 \
		--enable-pcre2grep-libz \
		--enable-pcre2grep-libbz2 \
		--enable-pcre2test-libreadline \
		--enable-jit
	make -j"$(nproc)"
}

do_check() {
	# Create a link to echo in coreutils to be used by the pcre2 test case
	ln -s "$(pkg_path_for coreutils)"/bin/echo /bin/echo
	make check
}

do_install() {
	make install

	# Install license file
	install -Dm644 LICENCE "$pkg_prefix/share/licenses/LICENSE"

	fix_interpreter "${pkg_prefix}/bin/pcre2-config" core/bash-static bin/sh
}
