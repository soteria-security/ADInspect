$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


Function Inspect-GPO_SMBv1{
    Try {
        #Get Domain
        $domain = Get-ADDomain

        #Get the GPO information and generate reports
        $GPOs = Get-GPO -All -Domain $domain.DNSRoot -Server $domain.PDCEmulator

        $mitigatingPolicies = @()

        $strings = @('key="\SYSTEM\CurrentControlSet\services\mrxsmb10" name="Start" Type="REG_DWORD" value="00000004"', 'key="SYSTEM\CurrentControlSet\Services\LanmanWorkstation" name="DependOnService" type="REG_MULTI_SZ" value="Bower MRxSMB20 NSI"','key="SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" name="SMB1" type="REG_DWORD" value="00000000"')

        Foreach ($string in $strings){
            Foreach ($gpo in $GPOs){
                $result = Get-GPOReport -Guid $gpo.Id -ReportType XML

                $str = [regex]::Escape($string)

                if ($result -match $str) {
                    $mitigatingPolicies += $gpo.DisplayName
                    }
                }
            }

        If ($mitigatingPolicies.count -eq 0){
            Return "No GPO to disable SMBv1"
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

Return Inspect-GPO_SMBv1
