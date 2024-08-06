$pkg_name="packer"
$pkg_origin="core"
$pkg_version="1.11.0"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=@('MPL2')
$pkg_bin_dirs=@("bin")
$pkg_source="https://releases.hashicorp.com/packer/${pkg_version}/packer_${pkg_version}_windows_amd64.zip"
$pkg_shasum="ea20acf68e13476c4939f75a3f0646fcc86f46940e4f5b4eb4c6571ada3054b5"

function Invoke-Install {
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_name-$pkg_version/$pkg_name.exe" $pkg_prefix\bin
}
