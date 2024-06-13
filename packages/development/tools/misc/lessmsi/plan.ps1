$pkg_name="lessmsi"
$pkg_origin="core"
$pkg_version="2.0.1"
$pkg_license=('MIT')
$pkg_upstream_url="http://lessmsi.activescott.com/"
$pkg_description="A tool to view and extract the contents of a Windows Installer (.msi) file."
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_source="https://github.com/activescott/lessmsi/releases/download/v$pkg_version/lessmsi-v${pkg_version}.zip"
$pkg_shasum="776300393773f7a6d3a904a938cc4b83df31652812c1f27941c12bb3e6a5a35e"
$pkg_bin_dirs=@("bin")

function Invoke-Unpack {
    Expand-Archive -Path "$HAB_CACHE_SRC_PATH/lessmsi-v${pkg_version}.zip" -DestinationPath "$HAB_CACHE_SRC_PATH/$pkg_dirname"
}

function Invoke-Install {
    Copy-Item * "$pkg_prefix/bin" -Recurse -Force
}