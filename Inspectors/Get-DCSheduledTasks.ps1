$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


$path = @($outpath)

Function Get-DCSheduledTasks{
    Try {
        #Get a list of all domain controllers
        $DCs = Get-ADDomainController -Filter *

        $allTasks = 0

        foreach ($dc in $DCs.Name){
            $tasks = Get-ScheduledTask -CimSession $dc | Where-Object {$_.state -match "Running"} | Get-ScheduledTaskInfo
            If ($tasks.count -gt 0){
                $tasks | Export-Csv -Path "$path\$($DC)_ScheduledTasks.csv" -NoTypeInformation
                $allTasks += $tasks.count
            }
        }
        If ($allTasks -ne 0){
            Return $allTasks
        }
        Else {
            Return $null
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

Return Get-DCSheduledTasks
