<#
.SYNOPSIS
    Gather information about Active Directory Admin accounts raise resolve any issues. Conforms to Best Practice and PingCastle reports.
.DESCRIPTION
    This script checks Active Directory Accounts for the adminCount attribute, AccountnotDelegated attribute, active status, and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin
.FUNCTIONALITY
    Gather information about Active Directory Admin accounts and raise any issues
#>

Function Get-Admins{
    $admins = Get-ADUser -Filter {adminCount -gt 0} -Properties adminCount

    If ($admins.count -gt 0){
        Return $admins.samaccountname
    } 

}

Return Get-Admins