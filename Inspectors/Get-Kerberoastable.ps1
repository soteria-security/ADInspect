$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


<#
.SYNOPSIS
    Gather information about Active Directory accounts vulnerable to Kerberoasting
.DESCRIPTION
    This script checks Active Directory Accounts for ServicePrincipalNames vulnerable to Kerberoasting and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory accounts vulnerable to Kerberoasting
#>

Function Get-Kerberoastable{
    Try {
        $SPN = get-aduser -filter * -pr ServicePrincipalNames | Where-Object {($_.ServicePrincipalNames -like "*") -and ($_.samaccountname -notlike "krbtgt")} | Select-Object samaccountname
        
        if ($SPN.count -ne 0){
            Return $SPN.samaccountname
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

Return Get-Kerberoastable
