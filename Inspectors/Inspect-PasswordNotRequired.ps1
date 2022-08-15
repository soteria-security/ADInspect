$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


<#
.SYNOPSIS
    Gather information about Active Directory accounts with the PasswordNotRequired flag set
.DESCRIPTION
    This script checks Active Directory Accounts for the PasswordNnotRequired attribute and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory accounts with PasswordNotRequired flag set
#>


$path = @($outpath)
Function Inspect-PasswordNotRequired{
    Try {
        $pwdNotrequired = Get-ADUser -Filter {PasswordNnotRequired -eq $true}
        
        if ($pwdNotrequired.count -gt 0){
            Return $pwdNotrequired.count 
            $pwdNotrequired | Export-Csv "$path\PWDNotRequired.csv" -NoTypeInformation
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

Return Inspect-PasswordNotRequired
