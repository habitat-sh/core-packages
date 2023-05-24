pkg_name="libxml2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Libxml2 is the XML C parser and toolkit developed for the Gnome project"
pkg_upstream_url="http://xmlsoft.org/"
pkg_origin="core"
pkg_version="2.9.12"
pkg_license=('MIT')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source=http://xmlsoft.org/sources/${pkg_name}-${pkg_version}.tar.gz
pkg_shasum="c8d6681e38c56f172892c85ddc0852e1fd4b53b4209e7f4ebf17f7e2eae71d92"
pkg_filename="${pkg_name}-${pkg_version}.tar.xz"
pkg_deps=(
	core/zlib
	core/glibc
	core/readline
	core/xz
)
pkg_build_deps=(
	core/gcc
	core/pkg-config
	core/python
	core/wget
	core/valgrind
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_bin_dirs=(bin)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--with-readline="$(pkg_path_for readline)"/lib \
		--with-history
	make
}

do_check() {
	# Updates the /bin/sh to point to a dynamically linked bash shell.
	# Running against bash statically linked with glibc causes various memory leak errors
	ln -sf "$(pkg_path_for bash)/bin/bash" /bin/sh
	# Download test case data and verify it
	download_file "https://www.w3.org/XML/Test/xmlts20130923.tar.gz" "$(pwd)/xmlts20130923.tar.gz" "c6b2d42ee50b8b236e711a97d68e6c4b5c8d83e69a2be4722379f08702ea7273"
	verify_file "${pkg_dirname}/xmlts20130923.tar.gz" "c6b2d42ee50b8b236e711a97d68e6c4b5c8d83e69a2be4722379f08702ea7273"
	tar -xf ./xmlts20130923.tar.gz
	make check-valgrind
}
