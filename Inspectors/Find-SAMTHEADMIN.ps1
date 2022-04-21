Function Find-SAMTHEADMIN{
    #Get a list of all domain controllers
    $exploitedComputers = Get-ADComputer -Filter * | Where-Object {$_.Name -like "SAMTHEADMIN*"}

    Return $exploitedComputers.Name
}

Return Find-SAMTHEADMIN