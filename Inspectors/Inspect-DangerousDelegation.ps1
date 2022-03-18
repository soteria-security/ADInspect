$path = @($out_path)

Function Inspect-DangerousDelegation {
    $DangerousDelegation = Import-CSV -Path (Get-ChildItem -Path $path -Filter "*_ACLs.csv").FullName | Where-Object {($_.AccessControlType -eq "Allow") -and ($_.ActiveDirectoryRights -like "GenericAll") -or ($_.ActiveDirectoryRights -like "*Write*")} 
    If ($DangerousDelegation.Count -ne 0){
        $DangerousDelegation | Export-CSV "$($path)\DangerousDegelationPermissions.csv" -NoTypeInformation
        Return $true
    }
    Return $null
}

Return Inspect-DangerousDelegation