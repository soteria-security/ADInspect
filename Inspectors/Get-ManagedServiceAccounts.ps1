Function Get-ManagedServiceAccounts {
    $versions = @("2012","2016","2019","202")

    foreach ($version in $versions){
        If ((Get-ADDomain).DomainMode -match $version){

            If (Get-ADObject -Filter "Name -eq 'Managed Service Accounts'"){
                $MSAs = Get-ADServiceAccount -filter *

                if ($MSAs.count -eq 0){
                    Return "No Managed Service Accounts"
                }
            }
            Return $null
        }
        Return "Domain Funtional Level is Unsupported"
    }
}

Return Get-ManagedServiceAccounts