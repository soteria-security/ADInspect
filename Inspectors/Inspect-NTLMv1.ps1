$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


Function Inspect-NTLMv1{
    Try {
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
        Return $null
    }
    Catch {
    Write-Warning "Error message: $_"
    $message = $_.ToString()
    $exception = $_.Exception
    $strace = $_.ScriptStackTrace
    $failingline = $_.InvocationInfo.Line
    $positionmsg = $_.InvocationInfo.PositionMessage
    $pscmdpath = $_.InvocationInfo.PSCommandPath
    $failinglinenumber = $_.InvocationInfo.ScriptLineNumber
    $scriptname = $_.InvocationInfo.ScriptName
    Write-Verbose "Write to log"
    Write-ErrorLog -message $message -exception $exception -scriptname $scriptname -failinglinenumber $failinglinenumber -failingline $failingline -pscmdpath $pscmdpath -positionmsg $positionmsg -stacktrace $strace
    Write-Verbose "Errors written to log"
    }
}

Return Inspect-NTLMv1
