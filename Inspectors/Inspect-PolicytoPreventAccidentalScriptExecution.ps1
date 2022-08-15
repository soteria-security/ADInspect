$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


Function Inspect-PolicytoPreventAccidentalScriptExecution{
    Try {
        #Get Domain
        $domain = Get-ADDomain

        #Get the GPO information and generate reports
        $GPOs = Get-GPO -All -Domain $domain.DNSRoot -Server $domain.PDCEmulator

        $mitigatingPolicies = @()

        $extensions = @("js","jse", "cjs", "mjs", "iced", "liticed", "iced.md", "cs", "coffee", "litcoffee", "coffee.md", "ts", "tsx", "ls", "es6", "es", "jsx", "sjs", "eg")

        $missingExtensions = @()

        Foreach ($extension in $extensions){
            #Options to check for
            $replace = "Properties action=`"R`" fileExtension=`"$extension`" applicationPath=`"C:\\Windows\\System32\\Notepad.exe`" default=`"1`""
            $update = "Properties action=`"U`" fileExtension=`"$extension`" applicationPath=`"C:\\Windows\\System32\\Notepad.exe`" default=`"1`""

            Foreach ($gpo in $GPOs){
                $result = Get-GPOReport -Guid $gpo.Id -ReportType XML

                if (($result -match $replace) -or ($report -match $update)) {
                    $mitigatingPolicies += $gpo.DisplayName
                    }
                Else {
                    $missingExtensions += $extension
                    }
                }
            }

        If ($mitigatingPolicies.count -eq 0){
            Return "No GPO to block accidental execution of $($missingExtensions | Select-Object -Unique)"
            }
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

Return Inspect-PolicytoPreventAccidentalScriptExecution
