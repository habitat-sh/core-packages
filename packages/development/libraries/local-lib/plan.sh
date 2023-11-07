pkg_name="local-lib"
pkg_origin="core"
pkg_version="2.000028"
pkg_license=('Artistic-2.0')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="create and use a local lib/ for perl modules with PERL5LIB"
pkg_upstream_url='https://github.com/Perl-Toolchain-Gang/local-lib'
pkg_source="https://cpan.metacpan.org/authors/id/H/HA/HAARG/${pkg_name}-${pkg_version}.tar.gz"
pkg_filename=${pkg_name}-${pkg_version}.tar.gz
pkg_dirname=${pkg_name}-${pkg_version}
pkg_shasum="408317d67a59f9f91e23e3000b82de4f529cf9cf0896e228f3a27d6f607bfe3d"
pkg_build_deps=(
	core/perl
	core/gcc
	core/make
	core/coreutils
)
pkg_lib_dirs=(lib)

do_build() {
	perl Makefile.PL --bootstrap="${pkg_prefix}" --no-manpages
	# Remove empty bin directory
	rm -rf $pkg_prefix/bin
}
