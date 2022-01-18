<#
.SYNOPSIS
    Gather information about Active Directory accounts with non-expiriing passwords
.DESCRIPTION
    This script checks Active Directory Accounts for the PasswordNeverExpires attribute and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory accounts with non-expiring passwords
#>


$path = @($out_path)
Function Inspect-PasswordExpiry{
    $pwdNeverexpires = Get-ADUser -filter {Enabled -eq $true} -properties Name, SAMAccountName, PasswordNeverExpires, Description, Title, Department | Where-Object { $_.passwordNeverExpires -eq "true" }
    
    if ($pwdNeverexpires.count -gt 0){
        Return $pwdNeverexpires.count
        $pwdNeverexpires | Export-Csv "$path\PWDNeverExpires.csv" -NoTypeInformation
    }
}

Return Inspect-PasswordExpiry