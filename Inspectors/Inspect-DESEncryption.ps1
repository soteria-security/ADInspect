$path = @($out_path)
Function Inspect-DESEncryption{
    $Users = Get-ADUser -Filter 'userAccountControl -band 0x200000'
    if ($users.count -gt 0){
        Return $Users.count
        Export-Csv "$path\UserswithDESEncryption.csv" -NoTypeInformation
    }
}

Return Inspect-DESEncryption