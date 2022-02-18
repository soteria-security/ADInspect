Function Inspect-GPOPermissions {
    $perms = Foreach ($GPO in (Get-GPO -All)){
        Foreach ($Perm in (Get-GPPermissions $GPO.DisplayName -All)) {
           New-Object PSObject -property @{GPO=$GPO.DisplayName;Trustee=$Perm.Trustee.Name;Permission=$Perm.Permission}
        }
     }
     $perms | Where-Object {($_.Trustee -eq 'Everyone') -or ($_.Trustee -eq 'Authenticated Users')} | Select-Object GPO, Trustee, Permission    
}

Inspect-GPOPermissions



