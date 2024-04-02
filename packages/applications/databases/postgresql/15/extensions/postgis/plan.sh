# shellcheck disable=SC2164
pkg_name="postgis3"
pkg_version="3.3.2"
pkg_origin="core"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="PostGIS is a spatial database extender for PostgreSQL object-relational database. It adds support for geographic objects allowing location queries to be run in SQL."
pkg_upstream_url="https://postgis.net/"
pkg_license=('GPL-2.0-or-later')
pkg_dirname="postgis-${pkg_version}"
pkg_source="http://download.osgeo.org/postgis/source/${pkg_dirname}.tar.gz"
pkg_shasum="9a2a219da005a1730a39d1959a1c7cec619b1efb009b65be80ffc25bad299068"

pkg_deps=(
	core/coreutils
	core/gcc-libs
	core/gdal
	core/geos
	core/glibc
	core/json-c
	core/libpcre2
	core/libxml2
	core/icu
	core/perl
	core/proj
	core/protobuf-c
	core/xz
	core/zlib
	core/postgresql15
)

pkg_build_deps=(
	core/bison
	core/cunit
	core/flex
	core/gcc
	core/git
	core/pkg-config
	core/sed
	core/which
)

do_build() {
	./configure \
		--datadir="${pkg_prefix}"/share \
		--datarootdir="${pkg_prefix}"/share \
		--bindir="${pkg_prefix}"/bin

	sed -i "s|@mkdir -p \$(DESTDIR)\$(PGSQL_BINDIR)||g ;
            s|\$(DESTDIR)\$(PGSQL_BINDIR)|$pkg_prefix/bin|g
            " \
		"raster/loader/Makefile"
	sed -i "s|\$(DESTDIR)\$(PGSQL_BINDIR)|$pkg_prefix/bin|g
            " \
		"raster/scripts/python/Makefile"
	mkdir -p "$pkg_prefix"/bin
	# postgis' build system assumes it is being installed to the same place as postgresql, and looks
	# for the postgres binary relative to $PREFIX. We gently support this system using an illusion.
	ln -s "$(pkg_path_for postgresql15)"/bin/postgres "$pkg_prefix"/bin/postgres

	make \
		datadir="${pkg_prefix}"/share \
		pkglibdir="${pkg_prefix}"/lib \
		bindir="${pkg_prefix}"/bin
}

do_install() {
	make \
		datadir="${pkg_prefix}"/share \
		pkglibdir="${pkg_prefix}"/lib \
		bindir="${pkg_prefix}"/bin \
		install
	rm "$pkg_prefix"/bin/postgres

	fix_interpreter "${pkg_prefix}/share/contrib/postgis-3.3/postgis_restore.pl" core/coreutils bin/env
}
