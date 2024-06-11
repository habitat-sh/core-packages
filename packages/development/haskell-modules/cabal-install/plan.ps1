$pkg_name="cabal-install"
$pkg_origin="core"
$pkg_version="3.10.3.0"
$pkg_license=@("BSD-3-Clause")
$pkg_upstream_url="https://www.haskell.org/cabal/"
$pkg_description="Command-line interface for Cabal and Hackage"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_source="https://downloads.haskell.org/~cabal/${pkg_name}-${pkg_version}/${pkg_name}-${pkg_version}-x86_64-windows.zip"
$pkg_shasum="b651ca732998eba5c0e54f4329c147664a7fb3fe3e74eac890c31647ce1e179a"

$pkg_bin_dirs=@("bin")

$pkg_build_deps=@(
    "core/ghc"
)

function Invoke-Check {
    ./cabal.exe v1-update
    ./cabal.exe info cabal
}

function Invoke-Install {
    Copy-Item "cabal.exe" "$pkg_prefix/bin/" -Force
}
