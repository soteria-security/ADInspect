$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


<#
.SYNOPSIS
    Gather information about Active Directory stale accounts
.DESCRIPTION
    This script checks Active Directory Accounts for stale accounts and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory stale accounts
#>

$path = @($outpath)

Function Get-StaleAccounts{
    Try {
        $stale_accounts = Get-ADUser -filter {Enabled -eq $true} -properties LastLogonDate | Where-Object { $_.lastlogondate -lt (Get-Date).adddays(-120)}
        
        if ($stale_accounts.count -ne 0){
            $stale_accounts | Export-Csv "$path\StaleAccounts.csv" -NoTypeInformation
            Return $stale_accounts.count
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

Return Get-StaleAccounts
