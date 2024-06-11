$pkg_name="yarn"
$pkg_origin="core"
$pkg_version="1.22.22"
$pkg_description="Yarn is a package manager for your code. It allows you to use and share code with other developers from around the world. Yarn does this quickly, securely, and reliably so you don't ever have to worry."
$pkg_maintainer="The Habitat Maintainers humans@habitat.sh"
$pkg_upstream_url="https://yarnpkg.com/"
$pkg_license=@("BSD-2-Clause")
$pkg_filename="$pkg_name-$pkg_version.msi"
$pkg_source="https://github.com/yarnpkg/yarn/releases/download/v${pkg_version}/${pkg_filename}"
$pkg_shasum="ebc1f46891b8d507efad2dd18eec2c4e617457f93e13bc701483cb047a053fa1"
$pkg_bin_dirs=@("bin")
$pkg_deps=@("core/node")
$pkg_build_deps=@("core/lessmsi")

function Invoke-Unpack {
    Push-Location "$HAB_CACHE_SRC_PATH"
    try {
        lessmsi x (Resolve-Path "$HAB_CACHE_SRC_PATH/$pkg_filename").Path
    } finally {
        Pop-Location
    }
}
function Invoke-Build { }
function Invoke-Install {
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/SourceDir/Yarn/*" "$pkg_prefix" -Recurse -Force
}
