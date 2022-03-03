$path = @($out_path)

Function Inspect-AllSPNs{
    $results = @()

    $SPNs = Get-ADUser -filter {ServicePrincipalName -like "*"} -Properties ServicePrincipalName | Where-Object {$_.samaccountname -notlike "krbtgt"}

    Foreach ($SPN in $SPNs){
        $results += "$($SPN.Name), $($SPN.ServicePrincipalName)"
    }

    if ($results.count -ne 0){
        $SPNs | Export-Csv "$path\AllSPNs.csv" -NoTypeInformation
        Return $results
    }
}

Return Inspect-AllSPNs