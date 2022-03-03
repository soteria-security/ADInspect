Function Inspect-GPO_BlockAdminLogon{
    #Get Domain
    $domain = Get-ADDomain

    #Get the GPO information and generate reports
    $GPOs = Get-GPO -All -Domain $domain.DNSRoot -Server $domain.PDCEmulator

    $mitigatingPolicies = @()

    $strings = @("SeDenyBatchlogonRight","SeDenyInteractiveLogonRight","SeDenyNetworkLogonRight","SeDenyRemoteInteractiveLogonRight","SeDenyServiceLogonRight")

    Foreach ($string in $strings){
        Foreach ($gpo in $GPOs){
            $result = Get-GPOReport -Guid $gpo.Id -ReportType XML

            $str = [regex]::Escape($string)

            if (($result -match $str) -and ($result -match "Domain Admins")) {
                $mitigatingPolicies += $gpo.DisplayName
                }
            }
        }

    If ($mitigatingPolicies.count -eq 0){
        Return "No GPO to prevent Domain Admin Accounts from logging on to Workstations or Servers"
        }
    Return $null
}

do {
	Write-Progress -Activity "Gathering Information" -Status "Gathering..." -PercentComplete -1
} while (Inspect-GPO_BlockAdminLogon)