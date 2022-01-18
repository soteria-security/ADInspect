$path = @($out_path)
function Inspect-ADComputerACLs{
    $computers = Get-ADComputer -filter *
    
    $results = @()

    foreach($computer in $computers){
        $result = (Get-ACL "AD:$((get-adcomputer $computer).distinguishedname)").access | Select-Object identityreference,  accesscontroltype, activedirectoryrights
        $results += $result
    }

    $results | Export-Csv -Path "$path\ComputerObject_ACLs.csv" -NoTypeInformation
}

Return Inspect-ADComputerACLs
