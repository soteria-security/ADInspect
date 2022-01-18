<#
.SYNOPSIS
    Gather information about Active Directory Domain Controllers.
.DESCRIPTION
    This script gathers a list of Active Directory Domain Controllers for validation. Ensuring the list matches expected Domain Controllers can help detect rogue DC's used in an attack known as DCShadow.
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights
.ROLE
    Domain User
.FUNCTIONALITY
    Gather information about Active Directory Domain Controllers
#>

Function Get-DomainControllers{
    #Get a list of all domain controllers
    $DCs = (Get-ADForest).Domains | ForEach-Object {Get-ADDomainController -Filter * -Server $_}

    Return $DCs.Name
}

Return Get-DomainControllers