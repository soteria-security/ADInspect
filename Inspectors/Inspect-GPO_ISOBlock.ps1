$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


Function Inspect-GPO_ISOBlock{
    Try {
        #Get Domain
        $domain = Get-ADDomain

        #Get the GPO information and generate reports
        $GPOs = Get-GPO -All -Domain $domain.DNSRoot -Server $domain.PDCEmulator

        $mitigatingPolicies = @()

        $strings = @('hive="HKEY_CLASSES_ROOT" key="Windows.IsoFile\shell" name="" type="REG_SZ" value=""','hive="HKEY_CLASSES_ROOT" key="Windows.IsoFile\shell\mount" name="ProgrammaticAccessOnly" type="REG_SZ" value=""')

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
            Return "No GPO to block ISO file launch"
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

Return Inspect-GPO_ISOBlock
