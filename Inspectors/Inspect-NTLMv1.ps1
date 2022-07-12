Function Inspect-NTLMv1{
    #Get Domain
    $domain = Get-ADDomain

    #Get the GPO information and generate reports
    $GPOs = Get-GPO -All -Domain $domain.DNSRoot -Server $domain.PDCEmulator

    $mitigatingPolicies = @()

    $auditingPolicies = @()

    $strings = $gporeport.gpo.computer.extensiondata.extension.securityoptions.keyname

    Foreach ($string in $strings){
        Foreach ($gpo in $GPOs){
            $result = Get-GPOReport -Guid $gpo.Id -ReportType XML

            If (($string -match "RestrictNTLM") -or ($string -match "RestrictReceivingNTLMTraffic") -or ($string -match "RestrictSendingNTLMTraffic")){
                $str = [regex]::Escape($string)

                if ($result -match $str) {
                    $mitigatingPolicies += $gpo.DisplayName
                    }
                }


            If (($string -match "AuditNTLM") -or ($string -match "AuditReceivingNTLMTraffic")){
                $str = [regex]::Escape($string)

                if ($result -match $str) {
                    $auditingPolicies += $gpo.DisplayName
                    }
                }
            }
        }

    If ((($mitigatingPolicies | Measure-Object).count -eq 0) -and (($auditingPolicies | Measure-Object).Count -eq 0)){
        Return "No GPO to disable or audit NTLMv1"
        }
    If ((($mitigatingPolicies | Measure-Object).count -eq 0) -and (($auditingPolicies | Measure-Object).Count -gt 0)){
        Return "GPO exists to audit NTLMv1 events"
        }
    Return $null
}

Return Inspect-NTLMv1