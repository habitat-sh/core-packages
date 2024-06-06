$pkg_name="buildkite-cli"
$pkg_origin="core"
$pkg_version="2.0.0"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=@("MIT")
$pkg_description="A command line interface for Buildkite"
$pkg_deps=@("core/git", "core/buildkite-agent")
$pkg_source="https://github.com/buildkite/cli/releases/download/v${pkg_version}/cli-windows-amd64"
$pkg_filename="cli-windows-amd64"
$pkg_shasum="813b16374425005d30ac425d9c7f321ad2f8b1370487b2b7005482154f95c6f6"
$pkg_upstream_url="https://buildkite.com"
$pkg_bin_dirs=@("bin")

function Invoke-Unpack {}

function Invoke-Install {
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_filename" "$pkg_prefix/bin/bk.exe"
}
