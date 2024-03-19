pkg_name="pcre"
pkg_origin="core"
pkg_version="8.45"
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
pkg_source="https://sourceforge.net/projects/${pkg_name}/files/${pkg_name}-${pkg_version}.tar.bz2"
pkg_shasum="4dae6fdcd2bb0bb6c37b5f97c33c2be954da743985369cddac3546e3218bffb8"
pkg_deps=(
	core/glibc
	core/gcc-libs
	core/bzip2
	core/zlib
	core/readline
)
pkg_build_deps=(
	core/gcc
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--enable-unicode-properties \
		--enable-utf \
		--enable-pcre16 \
		--enable-pcre32 \
		--enable-pcregrep-libz \
		--enable-pcregrep-libbz2 \
		--enable-pcretest-libreadline \
		--enable-jit
	make -j"$(nproc)"
}

do_check() {
	make check
}

do_install() {
	make install

	# Install license file
	install -Dm644 LICENCE "$pkg_prefix/share/licenses/LICENSE"
}
