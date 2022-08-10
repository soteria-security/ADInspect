$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


Function Inspect-GPOLogPolicies{
    Try {
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

Return Inspect-GPOLogPolicies
