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
    $pwdNotchanged = @($allUsers) | Where-Object {($_.PasswordLastSet -lt $Date) -and ($_.PasswordNeverExpires -eq $false) -and ($_.enabled -eq "true")}
    
    if ($pwdNotchanged.count -gt 0){
        $pwdNotchanged | Export-Csv "$path\PWD-Longetivity.csv" -NoTypeInformation
        Return $pwdNotchanged.SamAccountName
    }
}

Return Inspect-PasswordLongevity