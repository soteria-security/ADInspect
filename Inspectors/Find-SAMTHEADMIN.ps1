$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


Function Find-SAMTHEADMIN{
    Try {
        #Get a list of all domain controllers
        $exploitedComputers = Get-ADComputer -Filter * | Where-Object {$_.Name -like "SAMTHEADMIN*"}

        Return $exploitedComputers.Name
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

Return Find-SAMTHEADMIN
