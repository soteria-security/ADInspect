Function Inspect-AdministratorSPN {
    $administrator = Get-ADUser Administrator -Properties PasswordLastSet, LastLogonDate, ServicePrincipalName -Server (Get-ADDomain).PDCEmulator

    If ($administrator.ServicePrincipalName){
        Return "Administrator account has the following ServicePrinicpalName assignment: $($administrator.ServicePrincipalName)"
    }
    Return $null
}
Return Inspect-AdministratorSPN