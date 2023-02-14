pkg_name=libyaml
pkg_version=0.2.5
pkg_origin=core
pkg_license=('MIT')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_upstream_url="https://pyyaml.org/wiki/LibYAML"
pkg_description="LibYAML is a YAML parser and emitter library."
pkg_dirname=yaml-"${pkg_version}"
pkg_source=http://pyyaml.org/download/"${pkg_name}"/yaml-"${pkg_version}".tar.gz
pkg_filename=yaml-"${pkg_version}".tar.gz
pkg_shasum=c642ae9b75fee120b2d96c712538bd2cf283228d2337df2cf2988e3c02678ef4
pkg_deps=(
    core/glibc
)
pkg_build_deps=(
    core/coreutils
    core/make
    core/gcc
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
