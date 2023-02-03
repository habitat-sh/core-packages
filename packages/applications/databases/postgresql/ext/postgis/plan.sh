# shellcheck disable=SC2164
pkg_name=postgis
pkg_version=3.3.2
pkg_origin=core
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="PostGIS is a spatial database extender for PostgreSQL object-relational database. It adds support for geographic objects allowing location queries to be run in SQL."
pkg_upstream_url="https://postgis.net/"
pkg_license=('Creative Commons Attribution-Share Alike 3.0 License')
pkg_dirname="postgis-${pkg_version}"
pkg_source="http://download.osgeo.org/postgis/source/${pkg_dirname}.tar.gz"
pkg_shasum="9a2a219da005a1730a39d1959a1c7cec619b1efb009b65be80ffc25bad299068"

pkg_deps=(
  core/libxml2
  core/geos
  core/proj
  core/gdal
  core/json-c
  core/protobuf-c
)

pkg_build_deps=(
  core/postgresql
  core/pkg-config
  core/gcc
)
do_prepare() {
mkdir -p ${pkg_prefix}/bin; 
ln -s $(pkg_path_for postgresql)/bin/postgres ${pkg_prefix}/bin/postgres
}


do_build() {
    ./configure --prefix=${pkg_prefix}
    make
}

do_install() {
  make install
}
