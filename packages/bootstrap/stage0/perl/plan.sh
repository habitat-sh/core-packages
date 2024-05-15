program="perl"
pkg_name="perl"
pkg_origin="core"
pkg_version="5.34.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Perl 5 is a highly capable, feature-rich programming language with over 29 \
years of development.\
"
pkg_upstream_url="http://www.perl.org/"
pkg_license=('Artistic-1.0 OR GPL-1.0-or-later')
pkg_source="http://www.cpan.org/src/5.0/${program}-${pkg_version}.tar.gz"
pkg_shasum="551efc818b968b05216024fb0b727ef2ad4c100f8cb6b43fab615fa78ae5be9a"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/clang
)

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_interpreters=(bin/perl bin/perl5.34.0)

do_build() {
	sh Configure \
		-de \
		-Dprefix="$pkg_prefix" \
		-Dcc=gcc \
		-Dvendorprefix="$pkg_prefix" \
		-Dprivlib="$pkg_prefix/lib/perl5/5.34/core_perl" \
		-Darchlib="$pkg_prefix/lib/perl5/5.34/core_perl" \
		-Dsitelib="$pkg_prefix/lib/perl5/5.34/site_perl" \
		-Dsitearch="$pkg_prefix/lib/perl5/5.34/site_perl" \
		-Dvendorlib="$pkg_prefix/lib/perl5/5.34/vendor_perl" \
		-Dvendorarch="$pkg_prefix/lib/perl5/5.34/vendor_perl" \
	make -j"$(nproc)"
}
do_install() {
	make install
}

do_check() {
	make check
}