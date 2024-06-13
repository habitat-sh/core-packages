$pkg_name = "docker-credential-helper"
$pkg_description = "Docker Credential Helper"
$pkg_origin = "core"
$pkg_version = "0.8.2"
$pkg_maintainer = "The Habitat Maintainers <humans@habitat.sh>"
$pkg_license = @("MIT")
$pkg_source = "https://github.com/docker/docker-credential-helpers/releases/download/v$pkg_version/docker-credential-wincred-v$pkg_version.windows-amd64.exe"
$pkg_filename="docker-credential-wincred-v$pkg_version.windows-amd64.exe"
$pkg_upstream_url = "https://github.com/docker/docker-credential-helpers"
$pkg_shasum = "57d3ea7a97e73abd913f71b0ba4f497f729c640b022108716207b4bd47a9d658"
$pkg_bin_dirs = @("bin")

function Invoke-Unpack {}

function Invoke-Install {
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_filename" "$pkg_prefix/bin/docker-credential-wincred.exe" -Force
}
