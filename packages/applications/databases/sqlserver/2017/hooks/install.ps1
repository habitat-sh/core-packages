$ProgressPreference="SilentlyContinue"
$sqlMajorVersion = [Version]::new("{{pkg.version}}").Major
$setupPath = "{{pkg.path}}\bin"
if("{{cfg.custom_install_media_dir}}" -ne "") {
    $setupPath = "{{cfg.custom_install_media_dir}}"
}
$setupExe = Get-Item (Join-Path $setupPath setup.exe) -ErrorAction SilentlyContinue
if($setupExe) {
    $sqlMajorVersion = [Version]::new($setupExe.VersionInfo.ProductVersion).Major
}

# If the sql instance data is not present, install a new instance
if (!(Test-Path "{{pkg.svc_data_path}}/mssql${sqlMajorVersion}.{{cfg.instance}}")) {
    (Get-Content "{{pkg.svc_config_install_path}}/config.ini" | Where-Object { !$_.EndsWith("`"`"") }) | Set-Content "{{pkg.svc_config_install_path}}/config.ini"
    ."$setupExe" /configurationfile={{pkg.svc_config_install_path}}/config.ini /Q

    # This is a workaround for Sql Server 2016 which fails to
    # create user databases with forward slashes in the Default
    # data directory. Future Habitat Supervisors will not use
    # forward slashes and make this workaround unnecessary
    Set-ItemProperty -Path  "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL${sqlMajorVersion}.{{cfg.instance}}\MSSQLServer" -Name DefaultData -Value (Resolve-Path "{{pkg.svc_data_path}}").Path
    Set-ItemProperty -Path  "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL${sqlMajorVersion}.{{cfg.instance}}\MSSQLServer" -Name DefaultLog -Value (Resolve-Path "{{pkg.svc_data_path}}").Path
}

# Configure the instance for the configured port
Set-ItemProperty -Path  "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL${sqlMajorVersion}.{{cfg.instance}}\MSSQLServer\SuperSocketNetLib\Tcp\IPAll" -Name TcpPort -Value {{cfg.port}}

# Open port on firewall only if Windows Firewall service is running
if($(Get-Service 'MpsSvc').Status -eq "Running") {
    Invoke-Command -ComputerName localhost -EnableNetworkAccess {
        $ProgressPreference="SilentlyContinue"
        Write-Host "Checking for nuget package provider..."
        if(!(Get-PackageProvider -Name nuget -ErrorAction SilentlyContinue -ListAvailable)) {
            Write-Host "Installing Nuget provider..."
            Install-PackageProvider -Name NuGet -Force | Out-Null
        }
        Write-Host "Checking for xNetworking PS module..."
        if(!(Get-Module xNetworking -ListAvailable)) {
            Write-Host "Installing xNetworking PS Module..."
            Install-Module xNetworking -Force | Out-Null
        }
    }
}

Write-Host "Checking for SqlServer PS module in core environment..."
if(!(Get-Module SqlServer -ListAvailable)) {
    Write-Host "Installing SqlServer PS Module in core environment..."
    Install-Module SqlServer -Force -Scope AllUsers
}
