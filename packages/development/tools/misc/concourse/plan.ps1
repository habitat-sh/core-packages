$pkg_name="concourse"
$pkg_origin="core"
$pkg_version="7.11.2"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=('Apache-2.0')
$pkg_description="CI that scales with your project"
$pkg_upstream_url="https://concourse.ci"
$pkg_source="https://github.com/concourse/concourse/releases/download/v${pkg_version}/concourse-${pkg_version}-windows-amd64.zip"
$pkg_shasum="c4c9af6f33500237c71cc7d21cd93844c9d5fb8d44aa2b16a5a19150d8864224"

$pkg_bin_dirs=@("bin")

function Invoke-Install {
    Copy-Item "$HAB_CACHE_SRC_PATH/concourse-${pkg_version}/concourse/bin/concourse.exe" "$pkg_prefix/bin/" -Force
}