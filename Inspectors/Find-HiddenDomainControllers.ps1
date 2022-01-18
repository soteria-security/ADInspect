Function Find-HiddenDomainControllers{
    #Get a list of all domain controllers
    $HiddenDCs = Get-ADComputer -Filter * -Properties UserAccountControl | Where-Object {$_.UserAccountControl -eq 8192}

    Return $HiddenDCs.Name
}

Return Find-HiddenDomainControllers