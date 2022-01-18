<#
.SYNOPSIS
    Gather information about software installed on Active Directory Domain Controllers
.DESCRIPTION
    This script checks software installed on Active Directory Domain Controllers
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to connect to Domain Controllers
.ROLE
    Domain Admin
.FUNCTIONALITY
    Gather information about software installed on Active Directory Domain Controllers
#>


$path = @($out_path)
Function Get-DCSoftware{
    $DCs = Get-ADDomainController

    Foreach ($DC in $DCs) {
        $software = Get-WmiObject -Class Win32_Product -ComputerName $DC.Hostname
        $software | Export-Csv "$path\$($DC.name)_Software.csv" -NoTypeInformation
        Return $software.count
    }
}

Return Get-DCSoftware