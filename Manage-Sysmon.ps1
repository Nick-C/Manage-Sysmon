#requires -version 4.0
#requires -runasadministrator
function Install-Sysmon {
    <#

    .SYNOPSIS

    Installs a given Sysmon Configuration file to the local PC.

    .DESCRIPTION

    This will install the Sysmon tool and a specified configuration file onto the currently running PC.

    .PARAMETER config

    This should be the path to the Sysmon configuration file to install.

    .PARAMETER sysmonpath

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
    $sysmonpath
    )
    
    # Debug: dump the variables we got passed.
    Write-Verbose "Sysmon path: $($sysmonpath)"
    Write-Verbose "Config path: $($config)"

    # Lets figure out what the likely path to sysmon.exe is.
    $sysmonpath = Get-SysmonPath $sysmonpath  

    # We know $config is a valid file thanks to parameter validation, now lets quickly test if it is an xml file.
    Write-Verbose "Testing if the given config file is xml"
    if ((Test-Path $config -Include '*.xml') -eq $false) {
        Write-Verbose "Contents of config are: $config"
        Write-Warning "Unable to verify that provided config is a valid xml file."
        [System.Environment]::Exit(1)
     }

    # This is only really needed for older powershell versions, if you are running this from PS 4.0 or newer you can remove the next two if statements as these checks are handled
    # by the #requires statements at the start of the function. Likewise to allow this script to run on older PS versions, remove the #requires statements at the beginning of each function.
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "You do not have Administrator rights to run this script! Please re-run this script as an Administrator!"
        [System.Environment]::Exit(1)
    }
    if(-not (Get-Process -id $pid).MainWindowTitle -Like "Administrator:*") {
        Write-Warning "Please run this script via an Administrative Powershell session!"
        [System.Environment]::Exit(1)
    }


    # Before we attempt to install, lets test to see if sysmon might already be installed by checking the registry and Windows folder
    if((Test-Path HKLM:\System\CurrentControlSet\Services\Sysmon) -or (Test-Path HKLM:\System\CurrentControlSet\Services\SysmonDrv) -or (Test-Path $env:windir\sysmon.exe -PathType 'Leaf')) {
        Write-Warning "An existing Sysmon install has been detected, please uninstall fully before running again."
        [System.Environment]::Exit(1)
    }

    # Install sysmon
    $sysmoninstallcmd = "-i $config -accepteula"
    Write-Verbose "Install command: $sysmonpath $sysmoninstallcmd"
    Start-Process $sysmonpath -ArgumentList $sysmoninstallcmd -Wait -WindowStyle Hidden
    [System.Environment]::Exit(0)
}

function Update-Sysmon {
    <#

    .SYNOPSIS

    Updates an existing Sysmon install.

    .DESCRIPTION

    This will attempt to update both the sysmon exe and configuration of an existing install.

    .PARAMETER config

    This should be the path to the Sysmon configuration file to update.

    .PARAMETER sysmonpath

    This is an optional path to the Sysmon.exe file (default is to use the current folder).

    .EXAMPLE

  

    

    .NOTES

    As the Sysmon tool installs a device driver this script needs to be run from an administrative powershell session.

    If the installed sysmon.exe is older than the one passed to this script it will updated.

    This script does not attempt to validate the config file schema, if you update sysmon.exe be sure the config file is updated to a matching schema too.

    #>


}
function Get-AbsolutePath {
    <#

    .SYNOPSIS

    Gets the path to where the script is executing from.

    .DESCRIPTION

    This will return the full path to where the script is executing from.

    #>
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

function Get-SysmonPath {
    <#

    .SYNOPSIS

    Returns the path to sysmon.exe

    .DESCRIPTION

    Takes an input and attempts to validate if sysmon.exe is present, if the input is null it tries to find sysmon.exe in the current folder.

    #>
    Param(
        [parameter(
            Mandatory=$false,
            ValueFromPipeline=$true
        )]
        [String]$sysmon
    )

    # If a sysmon.exe location wasn't passed via a parameter, lets assume it exists in the current directory for now.
    if(!(Test-Path variable:global:sysmon)) {
        Write-Verbose "No sysmonpath passed, detecting via current directory"
        $currentpath = Get-AbsolutePath
        $sysmon = $currentpath + "\sysmon.exe"
        Write-Verbose "sysmon now set to: $sysmon"
    }
    # Now we definately have a path to sysmon.exe (either provided or assumed), lets try and verify sysmon.exe actually exists.
    try {
        Write-Verbose "Testing if we can find sysmon.exe at $sysmon"
        $null = Test-Path $sysmon -Include 'sysmon.exe'
    }
    catch {
        Write-Verbose "Contents of sysmonpath are: $sysmonpath"
        Write-Warning "Unable to find sysmon.exe, verify it is in the same folder as this script or the path is passed via -sysmonpath"
        [System.Environment]::Exit(1)
    }
    return $sysmon
}