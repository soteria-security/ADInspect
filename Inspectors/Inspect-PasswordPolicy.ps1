$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


<#
.SYNOPSIS
    Gather information about the Active Directory Domain Password Policy
.DESCRIPTION
    This script checks Active Directory Active Directory Domain Password Policy
.COMPONENT
    PowerShell, Active Directory PowerShell Module
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory Active Directory Domain Password Policy
#>

$path = @($outpath)
Function Inspect-PasswordPolicy {
    Try {
        $ADRoot = Get-ADRootDSE

        $PasswordPolicy = Get-ADObject $ADRoot.defaultNamingContext -Property minPwdAge, maxPwdAge, minPwdLength, pwdHistoryLength, pwdProperties 

        $data = $PasswordPolicy | Select-Object @{n="minPwdAge";e={"$($_.minPwdAge / -864000000000) days"}},@{n="maxPwdAge";e={"$($_.maxPwdAge / -864000000000) days"}},minPwdLength,pwdHistoryLength,`
            @{n="pwdProperties";e={Switch ($_.pwdProperties) {
                0 {"Passwords can be simple and the administrator account cannot be locked out"} 
                1 {"Passwords must be complex and the administrator account cannot be locked out"}
                8 {"Passwords can be simple, and the administrator account can be locked out"}
                9 {"Passwords must be complex, and the administrator account can be locked out"}
                Default {$_.pwdProperties}
                }
            }
        }

        $flag = $false

        If ($null -ne $data){
            $flag = $true
        }

        Return [string]$data
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

Return Inspect-PasswordPolicy

