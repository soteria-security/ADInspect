$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


<#
.SYNOPSIS
    Gather information about Active Directory Group Policy Objects
.DESCRIPTION
    This script analyzes Active Directory Group Policy Objects and outputs an HTML report for review
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to read Group Policy
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory Group Policy Objects
#>


$path = @($outpath)

Function Get-DomainGPOs{
    Try {
        #Get Domain
        $domain = Get-ADDomain

        #Get the GPO information and generate reports
        Get-GPOReport -All -Domain $domain.DNSRoot -Server $domain.PDCEmulator -ReportType HTML -Path "$path\$($domain.DNSRoot)_GPOReportsAll.html"
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

Return Get-DomainGPOs
