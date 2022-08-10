$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


<#
.SYNOPSIS
    Gather information about Active Directory High-value target accounts
.DESCRIPTION
    This script checks Active Directory Accounts that are High-value targets and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory high-value target accounts
#>

Function Get-HighValueTargets{
    try {
        $adminGroups = Get-ADGroup -ResultSetSize $null -Filter * -Properties GroupType | Where-Object {$_.SID -like "S-1-5-32-*"} | Select-Object Name 

        $HVT = @()

        foreach ($group in $adminGroups.Name){
            if ((Get-ADGroupMember $group).count -ne 0){
                $members = Get-ADGroupMember $group -Recursive
                foreach ($member in $members.samaccountname){
                    $HVT += "$member is a member of $group"
                }
            }
        }
        Return $HVT
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

Return Get-HighValueTargets
