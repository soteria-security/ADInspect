<#
.SYNOPSIS
    Gather information about Active Directory accounts with long-lived passwords
.DESCRIPTION
    This script checks Active Directory Accounts for long-lived passwords and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory accounts with long-lived passwords
#>


$path = @($out_path)
Function Inspect-PasswordLongevity{
    $Date = (Get-Date).adddays(-120) | Get-Date -Format MM/dd/yyyy
    $pwdNotchanged = Get-ADUser -filter {(PasswordLastSet -lt $Date) -and (PasswordNeverExpires -eq $false)} -Properties PasswordLastSet
    
    if ($pwdNotchanged.count -gt 0 -and $pwdNotchanged.enabled -eq $true){
        $pwdNotchanged | Export-Csv "$path\PWD-Longetivity.csv" -NoTypeInformation
        Return $pwdNotchanged.count
    }
}

Return Inspect-PasswordLongevity