$path = @($out_path)
Function Inspect-SIDHistory{
    $affectedUsers = Get-ADUser -Filter * -Properties SIDHistory | Where-Object {$_.SIDHistory -like "*"}
    
    if ($affectedUsers.count -ne 0){
        $affectedUsers | Export-Csv "$path\Users-with-SID-History.csv" -NoTypeInformation
        Return "$(($affectedUsers | Where-Object {$_.enabled -eq $true}).count) of $($affectedUsers.count) enabled with SID History. Refer to output file for a full list of affected users."
    }
}

Return Inspect-SIDHistory