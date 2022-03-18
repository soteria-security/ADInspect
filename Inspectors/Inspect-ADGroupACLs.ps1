$path = @($out_path)
function Inspect-ADGroupACLs{
    $groups = Get-ADGroup -filter *
    
    $results = @()

    foreach($group in $groups){
        $permissions = (Get-ACL -Path "Microsoft.ActiveDirectory.Management.dll\ActiveDirectory:://RootDSE/$((get-adgroup $group).distinguishedname)").access | Select-Object identityreference,  accesscontroltype, activedirectoryrights
        
        $result = New-Object psobject
        $result | Add-Member -MemberType NoteProperty -Name 'Name' -Value $group.Name
        $result | Add-Member -MemberType NoteProperty -Name 'Delegate' -Value ($permissions.identityreference | Out-String)
        $result | Add-Member -MemberType NoteProperty -Name 'AccessControlType' -Value ($permissions.accesscontroltype | Out-String)
        $result | Add-Member -MemberType NoteProperty -Name 'ActiveDirectoryRights' -Value ($permissions.activedirectoryrights | out-string)
        
        $results += $result
    }

    $results | Export-Csv -Path "$path\SecurityGroup_ACLs.csv" -NoTypeInformation
    return $true
}

Return Inspect-ADGroupACLs
