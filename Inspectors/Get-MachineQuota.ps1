

Function Get-MachineQuota{
    $Warning = "Machine Quota is not Restricted"

    $quota = Get-ADDomain | Get-ADObject -Properties 'ms-DS-MachineAccountQuota'
     If ($quota.'ms-DS-MachineAccountQuota' -gt 0){
         Return $Warning
     }
     Else {
         Return $null
     }
}

Return Get-MachineQuota