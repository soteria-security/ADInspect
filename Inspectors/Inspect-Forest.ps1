<#
.SYNOPSIS
    Gather information about Active Directory Forest
.DESCRIPTION
    This script checks Active Directory Forest and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to query the Forest
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory Forest
#>


Function Inspect-Forest{
    $Forest = Get-ADForest

    $currentMode = $Forest.ForestMode

    $minimum = 2016

    $value = ($currentMode) -replace '\D+([0-9]*).*','$1'

    If ($value -lt $minimum) {
        Return "$Forest is $currentMode"
    }
    Return $null
}

Return Inspect-Forest