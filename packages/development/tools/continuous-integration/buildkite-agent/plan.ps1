$pkg_name="buildkite-agent"
$pkg_origin="core"
$pkg_version="3.73.1"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=@("MIT")
$pkg_description="The Buildkite Agent is an open-source toolkit written in Golang for securely running build jobs on any device or network."
$pkg_source="https://github.com/buildkite/agent/releases/download/v${pkg_version}/buildkite-agent-windows-amd64-${pkg_version}.zip"
$pkg_filename="buildkite-agent-windows-amd64-${pkg_version}.zip"
$pkg_shasum="d9721d0dc10fb4568a74e9994d7c9e222a4e19fa0da4eb3586c30ce6afca9e17"
$pkg_upstream_url="https://buildkite.com"
$pkg_bin_dirs=@("bin")

function Invoke-Install {
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/buildkite-agent.exe" "$pkg_prefix/bin"
}
