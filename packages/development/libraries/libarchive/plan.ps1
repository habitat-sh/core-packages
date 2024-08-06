$pkg_name="libarchive"
$pkg_origin="core"
$pkg_version="3.7.4"
$pkg_description="Multi-format archive and compression library"
$pkg_upstream_url="https://www.libarchive.org"
$pkg_license=@("BSD")
$pkg_source="https://github.com/libarchive/libarchive/archive/refs/tags/v${pkg_version}.zip"
$pkg_shasum="5a57816a6af9499554cb8b95c25123f262c678c0a54c81a19d4bfbbe6f02ac9a"
$pkg_deps=@(
    "core/openssl",
    "core/bzip2",
    "core/xz",
    "core/zlib"
)
$pkg_build_deps=@(
   "core/visual-build-tools-2022", 
   "core/windows-11-sdk"
)
$pkg_bin_dirs=@("bin")
$pkg_lib_dirs=@("lib")



function Invoke-Build {
    Set-Location "$pkg_name-$pkg_version"

    $bzip_lib = "$(Get-HabPackagePath bzip2)\lib\libbz2.lib"
    $bzip_includedir = "$(Get-HabPackagePath bzip2)\include"
    $zlib_libdir = "$(Get-HabPackagePath zlib)\lib\zlibwapi.lib"
    $zlib_includedir = "$(Get-HabPackagePath zlib)\include"
    $xz_libdir = "$(Get-HabPackagePath xz)\lib\liblzma.a"
    $xz_includedir = "$(Get-HabPackagePath xz)\include"

    cmake -G "Visual Studio 17 2022" -A x64 -T "v143" -DCMAKE_SYSTEM_VERSION="10.0" -DCMAKE_INSTALL_PREFIX="${prefix_path}\libarchive" -DBZIP2_LIBRARY_RELEASE="${bzip_lib}" -DBZIP2_INCLUDE_DIR="${bzip_includedir}" -DZLIB_LIBRARY_RELEASE="${zlib_libdir}" -DZLIB_INCLUDE_DIR="${zlib_includedir}" -DLIBLZMA_INCLUDE_DIR="${xz_includedir}" -DLIBLZMA_LIBRARY="${xz_libdir}"
    msbuild /p:Configuration=Release /p:Platform=x64 "ALL_BUILD.vcxproj"
    if($LASTEXITCODE -ne 0) { Write-Error "msbuild failed!" }
}

function Invoke-Install {
    Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\$pkg_name-$pkg_version\bin\Release\*.dll" "$pkg_prefix\bin\" -Force
    Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\$pkg_name-$pkg_version\$pkg_name\Release\*.lib" "$pkg_prefix\lib\" -Force
}
