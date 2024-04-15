program="pcre2"

pkg_name="libpcre2"
pkg_origin="core"
pkg_version="10.42"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The PCRE library is a set of functions that implement regular expression \
pattern matching using the same syntax and semantics as Perl 5. PCRE has its \
own native API, as well as a set of wrapper functions that correspond to the \
POSIX regular expression API. The PCRE library is free, even for building \
proprietary software.\
"
pkg_upstream_url="http://www.pcre.org/"
pkg_license=('BSD-3-Clause')
pkg_source="https://github.com/PCRE2Project/${program}/releases/download/${program}-${pkg_version}/${program}-${pkg_version}.tar.bz2"
pkg_shasum="8d36cd8cb6ea2a4c2bb358ff6411b0c788633a2a45dabbf1aeb4b701d1b5e840"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/coreutils
	core/gcc
	core/bzip2
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
		--enable-jit
	make -j"$(nproc)"
}

do_check() {
	# Create a link to echo in coreutils to be used by the pcre2 test case
	ln -sv "$(pkg_path_for coreutils)"/bin/echo /bin/echo
	make check
}

do_install() {
	make install

	# Remove binaries and man
	rm -rf "${pkg_prefix:?}"/{bin,share}
	# Install license file
	install -Dm644 LICENCE "$pkg_prefix/share/licenses/LICENSE"

}
