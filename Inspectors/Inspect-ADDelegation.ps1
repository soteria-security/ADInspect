$path = @($out_path)
Function Inspect-Delegation{
    $count = 0

    $OUs = Get-ADOrganizationalUnit -Filter {Name -like '*'} 

    If ((Test-Path -Path $path\ActiveDirectoryDelegation) -eq $false){
        New-Item -Path $path -Name "ActiveDirectoryDelegation" -ItemType "directory"
        }

    $path = "$($path)\ActiveDirectoryDelegation"
    
    Foreach ($OU in $OUs){
        $perms = dsacls $OU.DistinguishedName 
        $perms | Out-File -FilePath "$path\$($OU.Name)_DelegatedRights.txt" 
        If ($perms){
            $count ++
        }
    }

    Return "Delegation found on $($count) Organizational Units."

}

Return Inspect-Delegation