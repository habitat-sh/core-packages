$pkg_name="zeromq"
$pkg_origin="core"
$pkg_version="4.3.5"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_description="ZeroMQ core engine in C++, implements ZMTP/3.1"
$pkg_upstream_url="http://zeromq.org"
$pkg_license=("LGPL-3.0-only")
$pkg_source="https://github.com/zeromq/libzmq/archive/v$pkg_version.zip"
$pkg_shasum="49b9d6cd12275d94a27724fcda646554f13af27857e3fe778b72cb245c74976e"
$pkg_deps=("core/libsodium")
$pkg_build_deps=(
    "core/visual-build-tools-2022", 
    "core/windows-11-sdk"
)
$pkg_bin_dirs=("bin")
$pkg_include_dirs=("include")
$pkg_lib_dirs=("lib")

function Invoke-Build {
    Set-Location "libzmq-$pkg_version"

    $sodium_includedir = "$(Get-HabPackagePath libsodium)\include"

    mkdir cmake-build
    Set-Location cmake-build
    cmake -G "Visual Studio 17 2022" -A "x64" -T "v143" -DCMAKE_SYSTEM_VERSION="10.0" -DCMAKE_INSTALL_PREFIX="${prefix_path}\zeromq" -DWITH_LIBSODIUM="true" -DSODIUM_INCLUDE_DIRS="${sodium_includedir}" -DENABLE_CURVE="false" ..

    msbuild /p:Configuration=Release /p:Platform=x64 "ZeroMQ.sln"
    if($LASTEXITCODE -ne 0) { Write-Error "msbuild failed!" }
}

function Invoke-Install {
    Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\libzmq-$pkg_version\cmake-build\bin\Release\libzmq-v143-mt-4_3_5.dll" "$pkg_prefix\bin\" -Force
    Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\libzmq-$pkg_version\cmake-build\bin\Release\libzmq-v143-mt-4_3_5.dll" "$pkg_prefix\bin\zmq.dll" -Force
    Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\libzmq-$pkg_version\cmake-build\lib\Release\*.lib" "$pkg_prefix\lib\" -Force
    Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\libzmq-$pkg_version\cmake-build\lib\Release\libzmq-v143-mt-4_3_5.lib" "$pkg_prefix\lib\zmq.lib" -Force
    Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\libzmq-$pkg_version\include\*" "$pkg_prefix\include\" -Force
}
