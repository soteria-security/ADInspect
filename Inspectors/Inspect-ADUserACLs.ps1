$path = @($out_path)
function Inspect-ADUserACLs{
    $users = Get-ADUser -filter * | select -First 100
    
    $results = @()

    foreach($user in $users){
        $permissions = (Get-ACL "AD:$((get-aduser $user).distinguishedname)").access | Where-Object {($_.ActiveDirectoryRights -like "GenericAll") -or ($_.ActiveDirectoryRights -like "*Write*") -or ($_.ActiveDirectoryRights -like "*create*")} | Select-Object identityreference,  accesscontroltype, activedirectoryrights


        $result = New-Object psobject
        $result | Add-Member -MemberType NoteProperty -Name 'Name' -Value $user.Name
        $result | Add-Member -MemberType NoteProperty -Name 'Delegate' -Value ($permissions.identityreference | Out-String)
        $result | Add-Member -MemberType NoteProperty -Name 'AccessControlType' -Value ($permissions.accesscontroltype | Out-String)
        $result | Add-Member -MemberType NoteProperty -Name 'ActiveDirectoryRights' -Value ($permissions.activedirectoryrights | out-string)
        
        $results += $result
        
    }

    $results | Export-Csv "$path\UserObject_ACLs.csv" -notypeinformation 
}

Return Inspect-ADUserACLs