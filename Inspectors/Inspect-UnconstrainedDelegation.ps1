$path = @($out_path)
Function Inspect-UnconstrainedDelegation{
    <#
        Primary Group ID's - https://adsecurity.org/?p=873
        Domain Controllers = 516
        Read-only Domain Controllers = 521
    #>

    $Computers = Get-ADComputer -Filter {(TrustedForDelegation -eq $True) -AND (PrimaryGroupID -ne '516') -AND (PrimaryGroupID -ne '521')}
    if ($Computers.count -gt 0){
        Export-Csv "$path\UnconstrainedDelegation.csv" -NoTypeInformation
        Return $Computers.Name
    }
}

Return Inspect-UnconstrainedDelegation