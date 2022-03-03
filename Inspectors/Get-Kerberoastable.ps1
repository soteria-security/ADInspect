<#
.SYNOPSIS
    Gather information about Active Directory accounts vulnerable to Kerberoasting
.DESCRIPTION
    This script checks Active Directory Accounts for ServicePrincipalNames vulnerable to Kerberoasting and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory accounts vulnerable to Kerberoasting
#>

$path = @($out_path)

Function Get-Kerberoastable{
    $SPN = get-aduser -filter * -pr ServicePrincipalNames | Where-Object {($_.ServicePrincipalNames -like "*") -and ($_.samaccountname -notlike "krbtgt")}
    
    if ($SPN.count -ne 0){
        $SPN | Export-Csv "$path\KerberoastableAccounts.csv" -NoTypeInformation
        Return $SPN.samaccountname
    }
}

Return Get-Kerberoastable