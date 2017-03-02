Function Install-Sysmon {
#requires -version 4.0
#requires -runasadministrator
    <#

    .SYNOPSIS

    Installs a given Sysmon Configuration file to the local PC.

    .DESCRIPTION

    This will install the Sysmon tool and a specified configuration file onto the currently running PC.

    .PARAMETER config

    This should be the path to the Sysmon configuration file to install.

    .PARAMETER sysmonlocation

    This is an optional path to the Sysmon.exe file (default is to use the current folder).

    .EXAMPLE

  

    

    .NOTES

    As the Sysmon tool installs a device driver this script needs to be run from an administrative powershell session.

    #>

    [CmdletBinding(DefaultParameterSetName = 'config')]

    Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'config')]
    [ValidateScript({Test-Path $_ -PathType 'Leaf' })]
    [string]
    $config
    ,
    [ValidateScript({Test-Path $_ -PathType 'Leaf' })]
    [string]
    $sysmonlocation
    )
    
    # Debug: dump the variables we got passed.
    Write-Verbose "Sysmon path: $($sysmonlocation)"
    Write-Verbose "Config path: $($config)"

    # If a sysmon.exe location wasn't passed via a parameter, lets assume it exists in the current directory for now.
   
    Write-Verbose "test is: $test"
    if(!(Test-Path variable:global:sysmonlocation)) {
        Write-Verbose "No Sysmonlocation passed, detecting via current directory"
        $currentpath = Get-AbsolutePath
        $sysmonlocation = $currentpath + "\sysmon.exe"
        Write-Verbose "Sysmonlocation now set to: $sysmonlocation"
    }
    # Now we definately have a path to sysmon.exe (either provided or assumed), lets try and verify sysmon.exe actually exists.
    try {
        Write-Verbose "Testing if we can find sysmon.exe at $sysmonlocation"
        $null = Test-Path $sysmonlocation -Include 'sysmon.exe'
    }
    catch {
        Write-Verbose "Contents of sysmonlocation are: $sysmonlocation"
        Write-Error "Unable to find sysmon.exe, verify it is in the same folder as this script or the path is passed via -sysmonlocation"
    }
    

    # We know $config is a valid file thanks to parameter validation, now lets quickly test if it is an xml file.
    Write-Verbose "Testing if the given config file is xml"
    if ((Test-Path $config -Include '*.xml') -eq $false) {
        Write-Verbose "Contents of config are: $config"
        Write-Error "Unable to verify that provided config is a valid xml file."
     }

    # This is only really needed for older powershell versions, if you are running this from PS 4.0 or newer you can remove the next two if statements as these checks are handled
    # by the #requires statements at the start of the function. Likewise to allow this script to run on older PS versions, remove the #requires statements at the beginning of each function.
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "You do not have Administrator rights to run this script! Please re-run this script as an Administrator!"
        Break
    }
    if(-not (Get-Process -id $pid).MainWindowTitle -Like "Administrator:*") {
        Write-Warning "Please run this script via an Administrative Powershell session!"
        Break
    }


    # Before we attempt to install, lets test to see if sysmon might already be installed by checking the registry and Windows folder
    if((Test-Path HKLM:\System\CurrentControlSet\Services\Sysmon) -or (Test-Path HKLM:\System\CurrentControlSet\Services\SysmonDrv) -or (Test-Path $env:windir\sysmon.exe -PathType 'Leaf')) {
        Write-Warning "An existing Sysmon install has been detected, please uninstall fully before running again."
        Break
    }

    # Install sysmon
    $sysmoninstallcmd = "-i $config -accepteula"
    Write-Verbose "Install command: $sysmonlocation $sysmoninstallcmd"
    Start-Process $sysmonlocation -ArgumentList $sysmoninstallcmd -Wait -WindowStyle Hidden
}

Function Get-AbsolutePath {

    [CmdletBinding()]
    Param(
        [parameter(
            Mandatory=$false,
            ValueFromPipeline=$true
        )]
        [String]$relativePath=".\"
    )

    if (Test-Path -Path $relativePath) {
        return (Get-Item -Path $relativePath).FullName -replace "\\$", ""
    } else {
        Write-Error -Message "'$relativePath' is not a valid path" -ErrorId 1 -ErrorAction Stop
    }

}