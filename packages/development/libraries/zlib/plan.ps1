$pkg_name="zlib"
$pkg_origin="core"
$pkg_version="1.3.1"
$pkg_file_name=$pkg_name + ($pkg_version).Replace(".", "")
$pkg_description="Compression library implementing the deflate compression method found in gzip and PKZIP."
$pkg_upstream_url="http://www.zlib.net/"
$pkg_license=("zlib")
$pkg_source="https://github.com/madler/zlib/archive/refs/tags/v1.3.1.zip"

$pkg_shasum="50b24b47bf19e1f35d2a21ff36d2a366638cdf958219a66f30ce0861201760e6"
$pkg_build_deps=@("core/visual-build-tools-2022", "core/windows-11-sdk")
$pkg_bin_dirs=@("bin")
$pkg_lib_dirs=@("lib")
$pkg_include_dirs=@("include")

function Invoke-Build {
	
	Set-Location "$pkg_name-$pkg_version"
	# Replace VERSION 1.3.1 with 1.3 for build error (https://github.com/madler/zlib/issues/919)
	(Get-Content contrib\vstudio\vc17\zlibvc.def).Replace("1.3.1", "1.3") | Set-Content contrib\vstudio\vc17\zlibvc.def
	
	msbuild /p:Configuration=Release /p:Platform=x64 "contrib\vstudio\vc17\zlibvc.sln"
    if($LASTEXITCODE -ne 0) { Write-Error "msbuild failed!" }
}

function Invoke-Install {
    Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\$pkg_name-$pkg_version\contrib\vstudio\vc17\x64\ZlibDllRelease\zlibwapi.dll" "$pkg_prefix\bin\" -Force
    Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\$pkg_name-$pkg_version\contrib\vstudio\vc17\x64\ZlibDllRelease\zlibwapi.lib" "$pkg_prefix\lib\" -Force
    Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\$pkg_name-$pkg_version\zlib.h" "$pkg_prefix\include\" -Force
    Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\$pkg_name-$pkg_version\zconf.h" "$pkg_prefix\include\" -Force
}
