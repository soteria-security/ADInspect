$path = @($out_path)
function Inspect-ADUserACLs{
    $users = Get-ADUser -filter *
    
    $results = @()

    foreach($user in $users){
        $result = (Get-ACL "AD:$((get-aduser $user).distinguishedname)").access | Select-Object identityreference,  accesscontroltype, activedirectoryrights
        $results += $result
    }

    $results | Export-Csv -Path "$path\UserObject_ACLs.csv" -NoTypeInformation
}

Return Inspect-ADUserACLs
