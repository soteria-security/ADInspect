<#
.SYNOPSIS
    Checks the Kerberos Account for long-lived passwords
.DESCRIPTION
    This script checks the Kerberos Account for long-lived passwords and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Checks the Kerberos Account for long-lived passwords
#>

Function Inspect-KerberosPassword{
    $krbtgt = Get-ADUser krbtgt -Properties PasswordLastSet
    
    if ($krbtgt.PasswordLastSet -lt ((Get-Date).adddays(-180))){
        Return $krbtgt.PasswordLastSet
    }
}

Return Inspect-KerberosPassword