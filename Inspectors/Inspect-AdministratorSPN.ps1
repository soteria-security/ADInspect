Function Inspect-AdministratorSPN {
    $administrator = Get-ADUser -Filter * -Properties SID, PasswordLastSet, LastLogonDate, ServicePrincipalName -Server (Get-ADDomain).PDCEmulator | Where-Object {$_.SID -like "S-1-5-*-500"}

    If ($administrator.ServicePrincipalName){
        Return "Administrator account has the following ServicePrinicpalName assignment: $($administrator.ServicePrincipalName)"
    }
    Return $null
}
Return Inspect-AdministratorSPN