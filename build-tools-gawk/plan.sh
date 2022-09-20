app_name="gawk"
native_target="${pkg_target%%-*}-hab-linux-gnu"

pkg_name="build-tools-gawk"
pkg_origin="core"
pkg_version="5.2.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The awk utility interprets a special-purpose programming language that makes \
it possible to handle simple data-reformatting jobs with just a few lines of \
code.\
"
pkg_upstream_url="http://www.gnu.org/software/gawk/"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${app_name}/${app_name}-${pkg_version}.tar.gz"
pkg_shasum="ef5af4449cb0269faf3af24bf4c02273d455f0741bf3c50f86ddc09332d6cf56"
pkg_dirname="${app_name}-${pkg_version}"

pkg_deps=(
    core/build-tools-glibc
)
pkg_build_deps=(
    core/native-cross-gcc
)
pkg_bin_dirs=(bin)
pkg_interpreters=(bin/awk bin/gawk)

do_build() {
    ./configure \
        --prefix="$pkg_prefix" \
        --build="$(build-aux/config.guess)" \
        --host="$native_target"
    make
}