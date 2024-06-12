$pkg_name="libsodium"
$pkg_origin="core"
$pkg_version="1.0.20"
$_pkg_version_text=($pkg_version).Replace(".", "_")
$pkg_description="Sodium is a new, easy-to-use software library for encryption, decryption, signatures, password hashing and more. It is a portable, cross-compilable, installable, packageable fork of NaCl, with a compatible API, and an extended API to improve usability even further."
$pkg_upstream_url="https://github.com/jedisct1/libsodium"
$pkg_license=@("ISC")
$pkg_source="https://github.com/jedisct1/libsodium/releases/download/1.0.20-RELEASE/$pkg_name-$pkg_version-msvc.zip"
$pkg_shasum="2ff97f9e3f5b341bdc808e698057bea1ae454f99e29ff6f9b62e14d0eb1b1baa"
$pkg_bin_dirs=@("bin")
$pkg_lib_dirs=@("lib")
$pkg_include_dirs=@("include")


function Invoke-Install {
    $build_path = "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\$pkg_name"

    Copy-Item "$build_path\x64\Release\v143\dynamic\libsodium.dll" "$pkg_prefix\bin\" -Force
    Copy-Item "$build_path\x64\Release\v143\dynamic\libsodium.lib" "$pkg_prefix\lib\" -Force
    Copy-Item "$build_path\x64\Release\v143\dynamic\libsodium.lib" "$pkg_prefix\lib\sodium.lib" -Force
    Copy-Item "$build_path\include\*.h" "$pkg_prefix\include\" -Force
    mkdir "$pkg_prefix\include\sodium\"
    Copy-Item "$build_path\include\sodium\*.h" "$pkg_prefix\include\sodium\" -Force
}
