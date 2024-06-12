$pkg_name="7zip"
$pkg_origin="core"
$pkg_version="24.06"
$pkg_license=@("LGPL-2.1", "unRAR restriction")
$pkg_upstream_url="https://www.7-zip.org/"
$pkg_description="7-Zip is a file archiver with a high compression ratio"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_source="https://www.7-zip.org/a/7z$($pkg_version.Replace('.',''))-x64.exe"
$pkg_shasum="6220bbe6c26d87fc343e0ffa4e20ccfafeca7dab2742e41963c40b56fb884807"
$pkg_filename="7z$($pkg_version.Replace('.',''))-x64.exe"
$pkg_bin_dirs=@("bin")

function Invoke-Unpack {
    Start-Process "$HAB_CACHE_SRC_PATH/$pkg_filename" -Wait -ArgumentList "/S /D=`"$(Resolve-Path $HAB_CACHE_SRC_PATH)/$pkg_dirname`""
}

function Invoke-Install {
    Copy-Item * "$pkg_prefix/bin" -Recurse -Force
}
