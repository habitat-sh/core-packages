$pkg_name="protobuf"
$pkg_origin="core"
$pkg_version="3.27.3"
$pkg_file_name=$pkg_name + ($pkg_version).Replace(".", "")
$pkg_description="Protocol buffers are a language-neutral, platform-neutral extensible mechanism for serializing structured data."
$pkg_upstream_url="https://developers.google.com/protocol-buffers/"
$pkg_license=("BSD")
$pkg_source="https://github.com/protocolbuffers/protobuf/archive/refs/tags/v${pkg_version}.zip"
$pkg_shasum="dda7464336f1f8072ce087b4d7c2d3647d57961b0fd38ebf6308e8417c18ac85"
$pkg_deps=@(
    "core/zlib"
)
$pkg_build_deps=@(
    "core/visual-build-tools-2022",
	"core/windows-11-sdk",
	"core/git"
)
$pkg_bin_dirs=@("bin")
$pkg_lib_dirs=@("lib")
$pkg_include_dirs=@("include")



function Invoke-Build {
	
	git clone https://github.com/abseil/abseil-cpp.git $HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\$pkg_name-$pkg_version\third_party/abseil-cpp
    Set-Location "$pkg_name-$pkg_version\cmake"

    $zlib_libdir = "$(Get-HabPackagePath zlib)\lib\zlibwapi.lib"
    $zlib_includedir = "$(Get-HabPackagePath zlib)\include"

    mkdir build
    Set-Location build
    cmake -G "Visual Studio 17 2022" -A x64 -T "v143" -DCMAKE_SYSTEM_VERSION="10.0" -DCMAKE_INSTALL_PREFIX=$pkg_prefix -DZLIB_LIBRARY_RELEASE="${zlib_libdir}" -DZLIB_INCLUDE_DIR="${zlib_includedir}" -Dprotobuf_BUILD_TESTS=OFF ../../ 
    # We'll build the required parts here
    msbuild /p:Configuration=Release /p:Platform=x64 "INSTALL.vcxproj"
    if($LASTEXITCODE -ne 0) { Write-Error "msbuild failed!" }

    .\extract_includes.bat
}

function Invoke-Install {
    Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\$pkg_name-$pkg_version\cmake\build\Release\protoc.exe" "$pkg_prefix\bin\" -Force
    Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\$pkg_name-$pkg_version\cmake\build\Release\*.lib" "$pkg_prefix\lib\" -Force
    Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\$pkg_name-$pkg_version\cmake\build\include\*" "$pkg_prefix\include\" -Force -Recurse
}
