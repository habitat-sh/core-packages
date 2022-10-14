program=python
pkg_name=build-tools-python
pkg_distname=Python
pkg_version=3.10.7
pkg_origin=core
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Python-2.0')
pkg_description="Python is a programming language that lets you work quickly \
  and integrate systems more effectively."
pkg_upstream_url="https://www.python.org"
pkg_dirname="${pkg_distname}-${pkg_version}"
pkg_source="https://www.python.org/ftp/python/${pkg_version}/${pkg_dirname}.tgz"
pkg_shasum=1b2e4e2df697c52d36731666979e648beeda5941d0f95740aafbf4163e5cc126

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
#pkg_interpreters=(bin/python bin/python3 bin/python3.9)

pkg_deps=(
)

pkg_build_deps=(
  core/build-tools-gcc
)

do_setup_environment() {
  export LDFLAGS="$LDFLAGS -lgcc_s"
}

do_build() {
  ./configure --prefix="$pkg_prefix" \
              --enable-shared \
              --without-ensurepip 
  make
}

do_install() {
make install PREFIX="$pkg_prefix"
}
