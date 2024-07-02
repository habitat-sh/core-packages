program=maven
pkg_origin=core
pkg_name=maven
pkg_version=3.9.7
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="A software project management and comprehension tool"
pkg_upstream_url="https://maven.apache.org/"
pkg_license=("Apache-2.0")
pkg_source="https://archive.apache.org/dist/maven/maven-3/${pkg_version}/source/apache-maven-${pkg_version}-src.tar.gz"
pkg_shasum=469580a1f25b998f294a07391412f4ec6eefdd05c328c0068f44588e438e702d
pkg_dirname="apache-${pkg_name}-${pkg_version}"
pkg_deps=(
  core/coreutils
  core/corretto
  core/which
)
pkg_build_deps=(core/maven-stage1)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)

do_prepare() {
  export JAVA_HOME
  JAVA_HOME="$(pkg_path_for corretto)"
  build_line "Setting JAVA_HOME=${JAVA_HOME}"
}

do_build() {
  mvn -DdistributionTargetDir="${pkg_prefix}" install
}

do_install() {
  return 0
}

