$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


Function Get-ManagedServiceAccounts {
    Try {
        $domainMode = (Get-ADDomain).DomainMode

        $flag = $false

        If (($domainMode -match "201") -or ($domainMode -match "202")){
            $flag = $true
        }

        If ($flag -eq $true) {
            If (Get-ADObject -Filter "Name -eq 'Managed Service Accounts'"){
                $MSAs = Get-ADServiceAccount -filter *
                if ($MSAs.count -eq 0){
                    Return "No Managed Service Accounts"
                }
            }
            Return $null
        }
        Else {
            Return "Domain Functional Level is Unsupported"
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

Return Get-ManagedServiceAccounts
