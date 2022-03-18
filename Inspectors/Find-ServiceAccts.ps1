$path = @($out_path)

Function Find-ServiceAccts{
    $SPN = @() #get-aduser -filter * -pr ServicePrincipalNames | Where-Object {($_.ServicePrincipalNames -like "*") -and ($_.samaccountname -notlike "krbtgt")} | Select-Object SamAccountName, ServicePrincipalNames
    
    foreach ($user in @($allUsers)) {
        $SPN += ($user | Where-Object {($_.ServicePrincipalNames -notlike "") -and ($_.Name -notlike "krbtgt")})
    }

    if ($SPN.count -ne 0){
        #$SPN | Out-File "$path\ServiceAccounts.txt"
        Return $SPN.SamAccountName
    }
}

Return Find-ServiceAccts