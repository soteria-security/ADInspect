<#
.SYNOPSIS
    Gather information about Active Directory High-value target accounts
.DESCRIPTION
    This script checks Active Directory Accounts that are High-value targets and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory high-value target accounts
#>


$path = @($out_path)
Function Inspect-PasswordNeverChanged{
    $Users = Get-ADUser -Filter * -Properties WhenCreated, PasswordLastSet 

    $pwdNeverchanged = @()

    foreach ($user in $users){
        $created = $user.WhenCreated
        $pwllastset = $user.PasswordLastSet
        If ($created -eq $pwllastset) {
            $pwdNeverchanged += $user
        }
    }
    
    if ($pwdNeverchanged.count -ne 0){
        $pwdNeverchanged | Export-Csv "PWDNeverChanged.csv" -NoTypeInformation
        Return $pwdNeverchanged.count
    }
}

Return Inspect-PasswordNeverChanged