pkg_origin="core"
pkg_name="local-lib"
pkg_version="2.000029"
pkg_license=('GPL-1.0-or-later' 'Artistic-1.0')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="create and use a local lib/ for perl modules with PERL5LIB"
pkg_upstream_url='https://github.com/Perl-Toolchain-Gang/local-lib'
pkg_source="https://cpan.metacpan.org/authors/id/H/HA/HAARG/${pkg_name}-${pkg_version}.tar.gz"
pkg_filename=${pkg_name}-${pkg_version}.tar.gz
pkg_dirname=${pkg_name}-${pkg_version}
pkg_shasum="8df87a10c14c8e909c5b47c5701e4b8187d519e5251e87c80709b02bb33efdd7"

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
