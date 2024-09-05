$pkg_name="pester"
$pkg_origin="core"
$pkg_version="5.5.0"
$pkg_license=@('Apache-2.0')
$pkg_upstream_url="https://github.com/pester/Pester"
$pkg_description="Pester is the ubiquitous test and mock framework for PowerShell"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_source="https://github.com/pester/Pester/archive/$pkg_version.zip"
$pkg_shasum="39dac4c4c19ad2ffce1e863bea8b68b05a648156833933ecde1826a49ac8f2d6"
$pkg_bin_dirs=@("module/bin")
$pkg_build_deps=@("core/dotnet-core-sdk")
function Invoke-Build {
	Set-Location "$pkg_name-$pkg_version"
	.\build.ps1 -Clean
}
function Invoke-Install {
    Copy-Item "pester-$pkg_version\*" "$pkg_prefix/module" -Recurse -Force
}
