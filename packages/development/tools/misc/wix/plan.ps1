$pkg_name="wix"
$pkg_origin="core"
$pkg_version="5.0.0"
$pkg_license=('MS-RL')
$pkg_upstream_url="http://wixtoolset.org/"
$pkg_description="The most powerful set of tools available to create your windows installation experience."
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_source="https://github.com/wixtoolset/wix/releases/download/v${pkg_version}/artifacts.zip"
$pkg_shasum="723ea68773c51e63fcd9c14503bb35ed67acf3c58cfd2549ad6b22688559c80f"
$pkg_bin_dirs=@("bin")

function Invoke-Unpack {
    Expand-Archive -Path "$HAB_CACHE_SRC_PATH/${pkg_filename}" -DestinationPath "$HAB_CACHE_SRC_PATH/$pkg_dirname"
}

function Invoke-Install {
    Copy-Item * "$pkg_prefix/bin" -Recurse -Force
}