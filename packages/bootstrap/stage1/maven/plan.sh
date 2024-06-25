program="maven"
pkg_origin=core
pkg_name=maven-stage1
pkg_version=3.9.7
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="A software project management and comprehension tool"
pkg_upstream_url="https://maven.apache.org/"
pkg_license=("Apache-2.0")
pkg_source="https://archive.apache.org/dist/maven/maven-3/${pkg_version}/binaries/apache-maven-${pkg_version}-bin.tar.gz"
pkg_shasum=c8fb9f620e5814588c2241142bbd9827a08e3cb415f7aa437f2ed44a3eeab62c
pkg_dirname="apache-${program}-${pkg_version}"

pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)

do_build() {
  return 0
}

do_install() {
   cp -r bin lib conf boot "${pkg_prefix}"
}

