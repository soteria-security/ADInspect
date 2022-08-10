$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


<#
.SYNOPSIS
    Gather information about Active Directory Domain Controllers.
.DESCRIPTION
    This script gathers a list of Active Directory Domain Controllers for validation. Ensuring the list matches expected Domain Controllers can help detect rogue DC's used in an attack known as DCShadow.
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights
.ROLE
    Domain User
.FUNCTIONALITY
    Gather information about Active Directory Domain Controllers
#>

Function Get-DomainControllers{
    try {
        #Get a list of all domain controllers
        $DCs = (Get-ADForest).Domains | ForEach-Object {Get-ADDomainController -Filter * -Server $_}

        Return $DCs.Name
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

Return Get-DomainControllers
