<#
.SYNOPSIS
    Gather information about Active Directory accounts vulnerable to AS-REP Roasting
.DESCRIPTION
    This script checks Active Directory Accounts that are vulnerable to AS-REP Roasting and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory accounts vulnerable to AS-REP Roasting
#>

Function Get-ASREPRoastable{
    $ASREP = get-aduser -filter * -pr DoesNotRequirePreAuth | Where-Object {($_.DoesNotRequirePreAuth -eq $true) -and ($_.Enabled -eq $true)}
    
    if ($ASREP.count -ne 0){
        $ASREP | Export-Csv "$path\ASREPRoastableUsers.csv" -NoTypeInformation
        Return $ASREP.samaccountname
    }
}

Return Get-ASREPRoastable