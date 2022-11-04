pkg_name="tzdata"
pkg_origin="core"
pkg_version="2022e"
pkg_description="Sources for time zone and daylight saving time data"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("gpl")
pkg_source="https://www.iana.org/time-zones/repository/releases/${pkg_name}${pkg_version}.tar.gz"
pkg_shasum="8de4c2686dce3d1aae9030719e6814931c216a2d5e891ec3d332e6f6516aeccd"
pkg_upstream_url="http://www.iana.org/time-zones"
pkg_dirname="${pkg_name}-${pkg_version}"

pkg_build_deps=(
    core/build-tools-coreutils
    core/build-tools-tar
    core/glibc
)

do_unpack() {
    mkdir -p "$HAB_CACHE_SRC_PATH/$pkg_dirname"
    pushd "$HAB_CACHE_SRC_PATH/$pkg_dirname" >/dev/null || exit 1
    tar xf "$HAB_CACHE_SRC_PATH/$pkg_filename"
    popd >/dev/null || exit 1
}

do_prepare() {
    set_runtime_env "TZDIR" "${pkg_prefix}"/share/zoneinfo
}

do_build() {
    return 0
}

do_install() {
    mkdir -pv "${pkg_prefix}"/share/zoneinfo/{posix,right}

    for tz in etcetera southamerica northamerica europe africa antarctica asia australasia backward; do
        zic -L /dev/null   -d "${pkg_prefix}"/share/zoneinfo       ${tz}
        zic -L /dev/null   -d "${pkg_prefix}"/share/zoneinfo/posix ${tz}
        zic -L leapseconds -d "${pkg_prefix}"/share/zoneinfo/right ${tz}
    done

    cp -v zone.tab zone1970.tab iso3166.tab "${pkg_prefix}"/share/zoneinfo
    zic -d "${pkg_prefix}"/share/zoneinfo -p America/New_York
}
