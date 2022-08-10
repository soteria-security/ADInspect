$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


$path = @($outpath)

Function Inspect-Description{
    Try {
        $Users = @()

        #Define objects and patterns to match
        $SSN = "(\d{3}-\d{2}-\d{4})"
        $phone = "(\d{3}-\d{3}-\d{4})"
        $unc = '.*(\\{2}[^\\"]+\\[^\\"]+\\{^"]+).*'
        $pattern = '[\\\[\]\{\}/():;\*\@\$\!\?_-]'
        $ip = '(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
        $strings = @("creds","pass\s","password","username","credential","VNC","remote","un\s","acct\s","actt\s","name","pw\s","pwd",$SSN,$phone,$unc,$ip,$pattern)

        foreach ($string in $strings){
            $Users += Get-ADUser -Filter * -Property Description | Where-Object {$_.Description -match $string}
        }

        $uniqueUsers = $Users | Select-Object -Unique
        
        if ($uniqueUsers.count -ne 0){
            $uniqueUsers | Export-Csv "$path\UserswithSensitiveInformationinDescription.csv" -NoTypeInformation
            Return $uniqueUsers.count
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

Return Inspect-Description
