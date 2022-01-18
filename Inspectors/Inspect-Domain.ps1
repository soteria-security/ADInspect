<#
.SYNOPSIS
    Gather information about Active Directory Domain
.DESCRIPTION
    This script checks Active Directory Domain and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory Domain
#>


Function Inspect-Domain{
    $Domain = Get-ADDomain

    $currentMode = $Domain.DomainMode

    $minimum = 2016

    $value = ($currentMode) -replace '\D+([0-9]*).*','$1'

    If ($value -lt $minimum) {
        Return "$($Domain.NetBIOSName) is $currentMode"
    }
    Return $null
}

Return Inspect-Domain