Function Inspect-GPOLogPolicies{
    $domain = Get-ADDomain

    #Get the GPO information and generate reports
    $GPOs = Get-GPO -All -Domain $domain.DNSRoot -Server $domain.PDCEmulator

    $mitigatingPolicies = @()

    $strings = @('Maximum application log size','Maximum security log size','Maximum system log size')

    Foreach ($gpo in $GPOs){
        Foreach ($string in $strings){
            $result = Get-GPOReport -Guid $gpo.Id -ReportType XML

            if ($result -match $string) {
                $mitigatingPolicies += $gpo.DisplayName
                #Write-Output "$($gpo.DisplayName)`n$($result.category)`n$($result.name; $result.state; $result.numeric.name; $result.numeric.value)"
                }
            }
        }
    
    If ($mitigatingPolicies.count -eq 0){
        Return "No GPO defining log size or retention"
        }
    Return $null
}

do {
	Write-Progress -Activity "Gathering Information" -Status "Gathering..." -PercentComplete -1
} while (Inspect-GPOLogPolicies)