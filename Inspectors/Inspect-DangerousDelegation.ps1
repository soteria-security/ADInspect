$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


$path = @($outpath)

Function Inspect-DangerousDelegation {
    Try {
        $data = (Get-ChildItem -Recurse -Path $path | Where-Object {$_ -like "*_DelegatedRights.csv"}).FullName

        $DangerousDelegation = $data | ForEach-Object {Import-CSV -Path $_  -Delimiter '^' | Where-Object {($_.AccessControlType -eq "Allow") -and ($_.ActiveDirectoryRights -like "GenericAll") -or ($_.ActiveDirectoryRights -like "*Write*")}}

        $results = $DangerousDelegation.samaccountname | Get-Unique

        If ($DangerousDelegation.Count -ne 0){
            $DangerousDelegation | Export-CSV "$($path)\DangerousDegelationPermissions.csv" -NoTypeInformation -Delimiter '^'
            return $results
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

Return Inspect-DangerousDelegation
