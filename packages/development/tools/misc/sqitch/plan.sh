pkg_origin=core
pkg_name=sqitch
pkg_version="1.4.1"
pkg_description="Sqitch the database management application, bundled with the DBD::Pg Perl module for PostgreSQL"
pkg_upstream_url="http://sqitch.org/" # Note: also https://metacpan.org/dist/App-Sqitch
pkg_source="https://github.com/sqitchers/sqitch/releases/download/v${pkg_version}/App-Sqitch-v${pkg_version}.tar.gz"
pkg_shasum="caf31cc8f772e3a4c9d4b3ff3a8f684a6eb5b1b3c261f4ddc0f90a88c36007c6"
pkg_maintainer="The Habitat Maintainers humans@habitat.sh"
pkg_license=('MIT')
pkg_dirname="App-Sqitch-v${pkg_version}"

pkg_deps=(
	core/glibc
	core/perl
	core/cpanminus
)
pkg_build_deps=(
	core/gcc
	core/local-lib
)

do_setup_environment() {
	push_runtime_env PERL5LIB "${pkg_prefix}/lib/perl5:${pkg_prefix}/lib/perl5/x86_64-linux-thread-multi"
}

do_prepare() {
	eval "$(perl -I"$(pkg_path_for core/local-lib)"/lib/perl5 -Mlocal::lib="$(pkg_path_for core/local-lib)")"
	# Create a new lib dir in our pacakge for cpanm to house all of its libs
	eval "$(perl -Mlocal::lib="${pkg_prefix}")"

	#to stop installation prompts	
	export PERL_MM_USE_DEFAULT=1
}

pkg_bin_dirs=(bin)

do_build() {
	cpanm Module::Build
	perl Build.PL
}

do_install() {
	./Build installdeps --cpan_client 'cpanm -v --notest' --defaultdeps
	# build with postgre support
	./Build --install_base ${pkg_prefix} --with postgres
	./Build install

	for file in "${pkg_prefix}"/bin/*; do
		sed -i "1 s,.*,& -I${pkg_prefix}/lib/perl5," "$file"
	done
}

do_check() {
	./Build test
}