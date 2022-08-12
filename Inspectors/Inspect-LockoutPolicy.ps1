$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


<#
.SYNOPSIS
    Gather information about the Active Directory Domain Account Lockout Policy
.DESCRIPTION
    This script checks Active Directory Active Directory Domain Account Lockout Policy
.COMPONENT
    PowerShell, Active Directory PowerShell Module
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory Active Directory Domain Account Lockout Policy
#>


$path = @($outpath)
Function Inspect-LockoutPolicy{
    Try {
        $domain = Get-ADRootDSE 
        $AccountPolicy = Get-ADObject $domain.defaultNamingContext -Property lockoutDuration, lockoutObservationWindow, lockoutThreshold
        $Info = $AccountPolicy | Select-Object lockoutDuration,lockoutObservationWindow,lockoutThreshold

        return "Lockout Duration: $($Info.lockoutDuration / -600000000) minutes; Lockout Observation Window: $($Info.lockoutDuration / -600000000) minutes; Lockout Threshold: $($Info.lockoutThreshold)"
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

Return Inspect-LockoutPolicy
