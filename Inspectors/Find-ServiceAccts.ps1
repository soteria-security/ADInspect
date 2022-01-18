Function Find-ServiceAccts{
    $SPN = get-aduser -filter * -pr ServicePrincipalNames | Where-Object {($_.ServicePrincipalNames -like "*") -and ($_.samaccountname -notlike "krbtgt")} | Select-Object ServicePrincipalNames
    
    if ($SPN.count -ne 0){
        Return $SPN
    }
}

Return Find-ServiceAccts