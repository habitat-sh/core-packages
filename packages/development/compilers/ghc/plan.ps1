$pkg_name="ghc"
$pkg_origin="core"
$pkg_version="9.10.1"
$pkg_license=@("BSD-3-Clause")
$pkg_upstream_url="https://www.haskell.org/ghc/"
$pkg_description="The Glasgow Haskell Compiler"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_source="https://downloads.haskell.org/~ghc/${pkg_version}/ghc-${pkg_version}-x86_64-unknown-mingw32.tar.xz"
$pkg_shasum="8bac01906ec2fa5c10c730b5ee5b8165654d654dbaf25ba9d3c42f8e26484c6a"

$pkg_bin_dirs=@("bin")
$pkg_lib_dirs=@("lib")
$pkg_include_dirs=@("lib/ghc-${pkg_version}/include")
$pkg_interpreters=@(
    "bin/runhaskell.exe"
    "bin/runghc.exe"
)

$pkg_build_deps=@(
    "core/7zip"
)

function Invoke-Unpack {
    Push-Location (Resolve-Path $HAB_CACHE_SRC_PATH).Path
    Try {
        $tar = $pkg_filename.Substring(0, $pkg_filename.LastIndexOf('.'))
        7z x -y (Resolve-Path $HAB_CACHE_SRC_PATH/$pkg_filename).Path
        7z x -y -o"." (Resolve-Path $HAB_CACHE_SRC_PATH/$tar).Path
    } finally { Pop-Location }
}

function Invoke-Install {
    foreach ($dir in @("bin","lib","mingw")) {
        Copy-Item $HAB_CACHE_SRC_PATH/$pkg_dirname-x86_64-unknown-mingw32/$dir "$pkg_prefix" -Recurse -Force
    }
}