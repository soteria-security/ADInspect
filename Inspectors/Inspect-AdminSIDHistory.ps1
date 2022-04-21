$path = @($out_path)
Function Inspect-AdminSIDHistory{
    $affectedUsers = Get-ADUser -Filter * -Properties SIDHistory | Where-Object {$_.SIDHistory -like "*-500"}
    
    if (($affectedUsers | Measure-Object).count -le 6){
        if (($affectedUsers | Measure-Object).count -gt 6){
            $affectedUsers | Export-Csv "$path\Users-with-ADMIN-SID-History.csv" -NoTypeInformation
        }
        Return $affectedUsers.samaccountname
    }
}

Return Inspect-AdminSIDHistory