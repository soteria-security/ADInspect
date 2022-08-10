$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


$path = @($outpath)
Function Inspect-SIDHistory{
    Try {
        $affectedUsers = Get-ADUser -Filter * -Properties SIDHistory | Where-Object {$_.SIDHistory -like "*"}
        
        if ($affectedUsers.count -ne 0){
            $affectedUsers | Export-Csv "$path\Users-with-SID-History.csv" -NoTypeInformation
            Return "$(($affectedUsers | Where-Object {$_.enabled -eq $true}).count) of $($affectedUsers.count) enabled with SID History. Refer to output file for a full list of affected users."
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

Return Inspect-SIDHistory
