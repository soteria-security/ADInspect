<#
.SYNOPSIS
    Gather information about services running on Active Directory Domain Controllers
.DESCRIPTION
    This script checks services running on Active Directory Domain Controllers
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to connect to Domain Controllers
.ROLE
    Domain Admin
.FUNCTIONALITY
    Gather information about services running on Active Directory Domain Controllers
#>


$path = @($out_path)
Function Get-Services{
    $DCs = Get-ADDomainController
    
    Foreach ($DC in $DCs) {
        $services = Get-Service -ComputerName $DC.Hostname
        $services | Export-Csv "$path\$($DC.name)_Services.csv" -NoTypeInformation
        Return $services.Count
    }
}

Return Get-Services