$path = @($out_path)

Function Inspect-GPOPermissions {
   $results = @()

   Foreach ($GPO in (Get-GPO -All)){
      Foreach ($Perm in (Get-GPPermissions $GPO.DisplayName -All)) {
         $result = New-Object PSObject -property @{GPO=$GPO.DisplayName;Trustee=$Perm.Trustee.Name;Permission=$Perm.Permission}
         
         $results += $result | Where-Object {($_.Trustee -eq 'Everyone') -or ($_.Trustee -eq 'Authenticated Users')  -or ($_.Trustee -eq 'Domain Users') -and ($_.Permission -like "GpoEdit*")}
        }
     }
     
     $results | Out-File -FilePath "$path\GPOsWithExcessivePermissions.txt"

     Return $results.GPO | Select-Object -Unique
}

Inspect-GPOPermissions