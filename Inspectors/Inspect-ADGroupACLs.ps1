$path = @($out_path)
function Inspect-ADGroupACLs{
    $groups = Get-ADGroup -filter *
    
    $results = @()

    foreach($group in $groups){
        $result = (Get-ACL -Path "Microsoft.ActiveDirectory.Management.dll\ActiveDirectory:://RootDSE/$((get-adgroup $group).distinguishedname)").access | Select-Object identityreference,  accesscontroltype, activedirectoryrights
        $results += $result
    }

    $results | Export-Csv -Path "$path\SecurityGroup_ACLs.csv" -NoTypeInformation
    return $true
}

Return Inspect-ADGroupACLs
