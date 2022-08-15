$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


$path = @($outpath)
Function Inspect-AdminSIDHistory{
    Try {
        $affectedUsers = Get-ADUser -Filter * -Properties SIDHistory | Where-Object {$_.SIDHistory -like "*-500"}
        
        if (($affectedUsers | Measure-Object).count -le 6){
            if (($affectedUsers | Measure-Object).count -gt 6){
                $affectedUsers | Export-Csv "$path\Users-with-ADMIN-SID-History.csv" -NoTypeInformation
            }
            Return $affectedUsers.samaccountname
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

Return Inspect-AdminSIDHistory
