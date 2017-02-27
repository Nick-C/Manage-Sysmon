Function Install-Sysmon {

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
    [Parameter(Mandatory = $true, ParameterSetName = 'config')][string]$config,
    [string]$sysmonlocation
    )

    # TODO: Test sysmon path.


    # TODO: Test config path.


    # TODO: Check for admin ps session.


    # TODO: Check for existing install via registry.


    # TODO: Install sysmon

}