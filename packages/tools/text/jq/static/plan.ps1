$pkg_name="jq-static"
$pkg_origin="core"
$pkg_version="1.7.1"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=@("MIT")
$pkg_upstream_url="https://stedolan.github.io/jq/"
$pkg_description="jq is a lightweight and flexible command-line JSON processor."
$pkg_source="https://github.com/stedolan/jq/releases/download/jq-$pkg_version/jq-win64.exe"
$pkg_shasum="7451fbbf37feffb9bf262bd97c54f0da558c63f0748e64152dd87b0a07b6d6ab"
$pkg_bin_dirs=@("bin")

function Invoke-Unpack { }

function Invoke-Install {
    Copy-Item $HAB_CACHE_SRC_PATH/$pkg_filename $pkg_prefix/bin/jq.exe
}
