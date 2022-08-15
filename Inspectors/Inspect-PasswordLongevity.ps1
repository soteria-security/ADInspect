$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


<#
.SYNOPSIS
    Gather information about Active Directory accounts with long-lived passwords
.DESCRIPTION
    This script checks Active Directory Accounts for long-lived passwords and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory accounts with long-lived passwords
#>


$path = @($outpath)
Function Inspect-PasswordLongevity{
    Try {
        $Date = (Get-Date).adddays(-120) | Get-Date -Format MM/dd/yyyy
        $pwdNotchanged = Get-ADUser -filter {(PasswordLastSet -lt $Date) -and (PasswordNeverExpires -eq $false)} -Properties PasswordLastSet
        
        if ($pwdNotchanged.count -gt 0 -and $pwdNotchanged.enabled -eq $true){
            Return $pwdNotchanged.count
            $pwdNotchanged | Export-Csv "$path\PWD-Longetivity.csv" -NoTypeInformation
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

Return Inspect-PasswordLongevity
