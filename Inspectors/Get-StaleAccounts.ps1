<#
.SYNOPSIS
    Gather information about Active Directory stale accounts
.DESCRIPTION
    This script checks Active Directory Accounts for stale accounts and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory stale accounts
#>

$path = @($out_path)

Function Get-StaleAccounts{
    $stale_accounts = Get-ADUser -filter {Enabled -eq $true} -properties LastLogonDate | Where-Object { $_.lastlogondate -lt (Get-Date).adddays(-120)}
    
    if ($stale_accounts.count -ne 0){
        $stale_accounts | Export-Csv "$path\StaleAccounts.csv" -NoTypeInformation
        Return $stale_accounts.count
    }
}

Return Get-StaleAccounts