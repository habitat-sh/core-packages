$pkg_name="openssl"
$pkg_origin="core"
$pkg_version="3.0.9"
$pkg_description="OpenSSL is an open source project that provides a robust, commercial-grade, and full-featured toolkit for the Transport Layer Security (TLS) and Secure Sockets Layer (SSL) protocols. It is also a general-purpose cryptography library."
$pkg_upstream_url="https://www.openssl.org"
$pkg_license=@("OpenSSL")
$pkg_source="https://github.com/openssl/openssl/archive/refs/tags/openssl-$pkg_version.zip"
$pkg_shasum="e32785cddc5f156c7dafab996b56da84beb05fd1d17efde9792e7d342b7f4588"
$pkg_deps=@("core/visual-cpp-redist-2022")
$pkg_build_deps=@("core/visual-build-tools-2022", "core/windows-11-sdk", "core/perl", "core/nasm")
$pkg_bin_dirs=@("bin")
$pkg_include_dirs=@("include")
$pkg_lib_dirs=@("lib")

function Invoke-Build {
    Set-Location "$pkg_name-$pkg_name-$pkg_version"
    perl Configure VC-WIN64A --prefix=$pkg_prefix --openssldir=$pkg_prefix\SSL
    nmake
    if($LASTEXITCODE -ne 0) { Write-Error "nmake failed!" }
}

function Invoke-Install {
    Set-Location "$pkg_name-$pkg_name-$pkg_version"
    nmake install
}
function Invoke-Check {
    Set-Location "$pkg_name-$pkg_name-$pkg_version"
    nmake test
}
