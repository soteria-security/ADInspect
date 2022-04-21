Function Inspect-AdminsProtectedUsers{
    $adminGroups = Get-ADGroup -ResultSetSize $null -Filter * -Properties GroupType | Where-Object {$_.SID -like "S-1-5-32-*"} | Select-Object Name 

    $usersToBeRemediated = @()

    foreach ($group in $adminGroups.Name){
        if ((Get-ADGroupMember $group).count -ne 0){
            $members = Get-ADGroupMember $group -Recursive
            foreach ($member in $members.samaccountname){
                $memberOf = Get-ADPrincipalGroupMembership -Identity $member
                if ($memberOf.Name -notcontains 'Protected Users'){
                    $usersToBeRemediated += "$member is a member of $group and not a member of Protected Users"
                }
            }
        }
    }
    Return $usersToBeRemediated
}

Return Inspect-AdminsProtectedUsers