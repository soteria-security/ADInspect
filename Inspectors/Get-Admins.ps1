$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


<#
.SYNOPSIS
    Gather information about Active Directory Admin accounts raise resolve any issues. Conforms to Best Practice and PingCastle reports.
.DESCRIPTION
    This script checks Active Directory Accounts for the adminCount attribute, AccountnotDelegated attribute, active status, and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin
.FUNCTIONALITY
    Gather information about Active Directory Admin accounts and raise any issues
#>

Function Get-Admins{
    Try {
        $admins = Get-ADUser -Filter {adminCount -gt 0} -Properties adminCount

        If ($admins.count -gt 0){
            Return $admins.samaccountname
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

Return Get-Admins
