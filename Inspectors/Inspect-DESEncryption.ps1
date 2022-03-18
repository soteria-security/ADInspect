$path = @($out_path)
Function Inspect-DESEncryption{
    $Users = Get-ADUser -Filter 'userAccountControl -band 0x200000'
    if ($users.count -gt 0){
        Export-Csv "$path\UserswithDESEncryption.csv" -NoTypeInformation
        Return $Users.count
    }
}

Return Inspect-DESEncryption