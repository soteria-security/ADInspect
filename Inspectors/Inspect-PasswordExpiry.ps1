$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


<#
.SYNOPSIS
    Gather information about Active Directory accounts with non-expiriing passwords
.DESCRIPTION
    This script checks Active Directory Accounts for the PasswordNeverExpires attribute and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory accounts with non-expiring passwords
#>


$path = @($outpath)
Function Inspect-PasswordExpiry{
    Try {
        $pwdNeverexpires = Get-ADUser -filter {Enabled -eq $true} -properties Name, SAMAccountName, PasswordNeverExpires, Description, Title, Department | Where-Object { $_.passwordNeverExpires -eq "true" }
        
        if ($pwdNeverexpires.count -gt 0){
            $pwdNeverexpires | Export-Csv "$path\PWDNeverExpires.csv" -NoTypeInformation
            Return $pwdNeverexpires.count
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

Return Inspect-PasswordExpiry
