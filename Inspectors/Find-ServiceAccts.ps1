$path = @($out_path)

Function Find-ServiceAccts{
    $SPN = get-aduser -filter * -pr ServicePrincipalNames | Where-Object {($_.ServicePrincipalNames -like "*") -and ($_.samaccountname -notlike "krbtgt")} | Select-Object SamAccountName, ServicePrincipalNames
    
    if ($SPN.count -ne 0){
        $SPN | Out-File "$path\ServiceAccounts.txt"
        Return $SPN.Count
    }
}

Return Find-ServiceAccts