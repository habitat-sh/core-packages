$pkg_name="dotnet-core-sdk"
$pkg_origin="core"
$pkg_version="8.0.303"
$pkg_license=('MIT')
$pkg_upstream_url="https://www.microsoft.com/net/core"
$pkg_description=".NET Core is a blazing fast, lightweight and modular platform
  for creating web applications and services that run on Windows,
  Linux and Mac."
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_source="
https://download.visualstudio.microsoft.com/download/pr/93d39941-31b3-4c50-b124-0de50d464fe5/93a0dddb827811ff50586cb361f613b0/dotnet-sdk-$pkg_version-win-x64.zip"
$pkg_shasum="33dc7315e92a1b995cc26eed932b2aa58f4578e77c823115ad98e187aebe9e17"
$pkg_bin_dirs=@("bin")

function Invoke-SetupEnvironment {
    Set-RuntimeEnv -IsPath "MSBuildSDKsPath" "$pkg_prefix\bin\sdk\$pkg_version\Sdks"
}

function Invoke-Install {
    Copy-Item * "$pkg_prefix/bin" -Recurse -Force
}

function Invoke-Check() {
    mkdir dotnet-new
    Push-Location dotnet-new
    ../dotnet.exe new web
    if(!(Test-Path "program.cs")) {
        Pop-Location
        Write-Error "dotnet app was not generated"
    }
    Pop-Location
    Remove-Item -Recurse -Force dotnet-new
}
