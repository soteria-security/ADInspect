Function Inspect-AllSPNs{
    $SPNs = @()

    $query = New-Object DirectoryServices.DirectorySearcher([ADSI]"")

    $query.Filter = "(serviceprincipalname=*)"

    $results = $query.FindAll()

    Foreach ($result in $results){
        $entity = $result.GetDirectoryEntry()
        $SPNs += $entity.Name, $entity.ServicePrinicpalName
    }

    if ($SPNs.count -ne 0){
        Return $SPNs
    }
}

Return Inspect-AllSPNs