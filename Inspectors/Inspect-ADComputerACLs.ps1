$path = @($out_path)
function Inspect-ADComputerACLs{
    $computers = Get-ADComputer -filter *
    
    $results = @()

    foreach($computer in $computers){
        $result = (Get-ACL -Path "Microsoft.ActiveDirectory.Management.dll\ActiveDirectory:://RootDSE/$((get-adcomputer $computer).distinguishedname)").access | Select-Object identityreference,  accesscontroltype, activedirectoryrights
        $results += $result
    }

    $results | Export-Csv -Path "$path\ComputerObject_ACLs.csv" -NoTypeInformation
    Return $true
}

Return Inspect-ADComputerACLs
