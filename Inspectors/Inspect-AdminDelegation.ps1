<#
.SYNOPSIS
    Gather information about Active Directory misconfigured admin accounts
.DESCRIPTION
    This script checks Active Directory Accounts misconfigured admin accounts and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory misconfigured admin accounts
#>

Function Inspect-AdminDelegation{
    $admins = Get-ADUser -filter {admincount -gt 0} -pr AccountNotDelegated | Where-Object {$_.AccountNotDelegated -eq $false} 
    
    if ($admins.count -ne 0){
        Return $admins.samaccountname
    }
}

Return Inspect-AdminDelegation