$path = @($out_path)
function Inspect-ADComputerACLs{
    $computers = Get-ADComputer -filter *
    
    $results = @()

    foreach($computer in $computers){
        $permissions = (Get-ACL -Path "Microsoft.ActiveDirectory.Management.dll\ActiveDirectory:://RootDSE/$((get-adcomputer $computer).distinguishedname)").access | Select-Object identityreference,  accesscontroltype, activedirectoryrights
        
        $result = New-Object psobject
        $result | Add-Member -MemberType NoteProperty -Name 'Name' -Value $computer.Name
        $result | Add-Member -MemberType NoteProperty -Name 'Delegate' -Value ($permissions.identityreference | Out-String)
        $result | Add-Member -MemberType NoteProperty -Name 'AccessControlType' -Value ($permissions.accesscontroltype | Out-String)
        $result | Add-Member -MemberType NoteProperty -Name 'ActiveDirectoryRights' -Value ($permissions.activedirectoryrights | out-string)
        
        $results += $result
    }

    $results | Export-Csv -Path "$path\ComputerObject_ACLs.csv" -NoTypeInformation
    Return $true
}

Return Inspect-ADComputerACLs
