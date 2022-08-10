$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


<#
.SYNOPSIS
    Gather information about Active Directory accounts vulnerable to AS-REP Roasting
.DESCRIPTION
    This script checks Active Directory Accounts that are vulnerable to AS-REP Roasting and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory accounts vulnerable to AS-REP Roasting
#>

Function Get-ASREPRoastable{
    Try {
        $ASREP = get-aduser -filter * -pr DoesNotRequirePreAuth | Where-Object {($_.DoesNotRequirePreAuth -eq $true) -and ($_.Enabled -eq $true)} | Select-Object samaccountname
        
        if ($ASREP.count -ne 0){
            Return $ASREP.samaccountname
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

Return Get-ASREPRoastable
