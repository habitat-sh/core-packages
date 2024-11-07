$pkg_name="visual-build-tools-2022"
$pkg_origin="core"
$pkg_version="17.10.4"
$pkg_description="Standalone compiler, libraries and scripts"
$pkg_upstream_url="https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022"
$pkg_license=@("Microsoft Software License")
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
# When accessing the vs_BuildTools.exe from https://aka.ms/vs/17/release/vs_BuildTools.exe, 
# it always provides the latest version of the build tools, which, in turn, can change dependencies. 
# This may cause issues due to differences in the build time and result in a loss of reproducibility. 
# Instead, we should always use the exact version of the build tools based on the configured version.
# https://github.com/microsoft/winget-pkgs/tree/master/manifests/m/Microsoft/VisualStudio/2022/BuildTools
$pkg_source="https://download.visualstudio.microsoft.com/download/pr/7593f7f0-1b5b-43e1-b0a4-cceb004343ca/9a5b493178cde0ec0aa3543d3285c3e037956119ca426aaed14f59d24fe62e90/vs_BuildTools.exe"
$pkg_shasum="9a5b493178cde0ec0aa3543d3285c3e037956119ca426aaed14f59d24fe62e90"
$pkg_build_deps=@("core/7zip")

$pkg_bin_dirs=@(
    "Contents\VC\Tools\MSVC\14.40.33807\bin\HostX64\x64",
    "Contents\VC\Redist\MSVC\14.40.33807\x64\Microsoft.VC143.CRT",
    "Contents\VC\Redist\MSVC\14.40.33807\x86\Microsoft.VC143.CRT", # For packaged 32 bit cmake
    "Contents\MSBuild\Current\Bin\amd64",
	"Contents\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin",
	"Contents\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja"
)
$pkg_lib_dirs=@(
    "Contents\VC\Tools\MSVC\14.40.33807\atlmfc\lib\x64",
    "Contents\VC\Tools\MSVC\14.40.33807\lib\x64"
)
$pkg_include_dirs=@(
    "Contents\VC\Tools\MSVC\14.40.33807\atlmfc\include",
    "Contents\VC\Tools\MSVC\14.40.33807\include"
)

function Invoke-SetupEnvironment {
    Set-RuntimeEnv "DisableRegistryUse" "true"
    # Setting this Windows Driver Kit variable is necessary to enable
    # cmake to use this portable build tools package and not query
    # the windows registry or the vieual studio installer components
    Set-RuntimeEnv "EnterpriseWDK" "true"
    Set-RuntimeEnv "UseEnv" "true"
    Set-RuntimeEnv "VCToolsVersion" "14.40.33807"
    Set-RuntimeEnv "VisualStudioVersion" "17.0"
    Set-RuntimeEnv -IsPath "VSINSTALLDIR" "$pkg_prefix\Contents"
    Set-RuntimeEnv -IsPath "VCToolsInstallDir_170" "$pkg_prefix\Contents\VC\Redist\MSVC\14.40.33807"
}

function Invoke-Unpack {
    # This makes me very sad, but is a necessary evil to get the layout working in docker.
    # In previous VS versions or in a non-docker environment, you should just call the
    # downloaded vs_buildtools.exe with the --layout arguments but that seems to fail
    # in a container. To work around that, we need to extract some data from the installer,
    # download the setup.exe program and then invoke it directly. Note that this will
    # write a 'Unhandled Exception: System.IO.IOException: The parameter is incorrect' error
    # to the console but by this time we have everything we need to proceed.
    7z x "$HAB_CACHE_SRC_PATH/$pkg_filename" -o"$HAB_CACHE_SRC_PATH/$pkg_dirname"
    $opcInstaller = (Get-Content "$HAB_CACHE_SRC_PATH\$pkg_dirname\vs_bootstrapper_d15\vs_setup_bootstrapper.config")[0].Split("=")[-1]
    Invoke-WebRequest $opcInstaller -Outfile "$HAB_CACHE_SRC_PATH/$pkg_dirname/vs_installer.opc"
    7z x "$HAB_CACHE_SRC_PATH/$pkg_dirname/vs_installer.opc" -o"$HAB_CACHE_SRC_PATH/$pkg_dirname"

    $installArgs =  "layout --quiet --layout $HAB_CACHE_SRC_PATH/$pkg_dirname --lang en-US --in $HAB_CACHE_SRC_PATH/$pkg_dirname/vs_bootstrapper_d15/vs_setup_bootstrapper.json"
    $components = @(
	 "Microsoft.Component.MSBuild",
	 "Microsoft.VisualStudio.Component.VC.CoreBuildTools",
         "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
	 "Microsoft.VisualStudio.Component.VC.ATLMFC",
	 "Microsoft.VisualStudio.Component.VC.CMake.Project"	
    )
    foreach ($component in $components) {
        $installArgs += " --add $component"
    }

    $setup = "$HAB_CACHE_SRC_PATH/$pkg_dirname/Contents/resources/app/layout/setup.exe"
    Write-Host "Launching $setup with args: $installArgs"
    Start-Process -FilePath $setup -ArgumentList $installArgs.Split(" ") -Wait
    Push-Location "$HAB_CACHE_SRC_PATH/$pkg_dirname"
    try {
        Get-ChildItem "$HAB_CACHE_SRC_PATH/$pkg_dirname" -Include *.vsix -Exclude @('*x86*', '*.arm.*') -Recurse | ForEach-Object {
            Rename-Item $_ "$_.zip"
            Expand-Archive "$_.zip" expanded -force
        }
    } finally { Pop-Location }
}

function Invoke-Install {
    Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_dirname\expanded\Contents" $pkg_prefix -Force -Recurse
}
