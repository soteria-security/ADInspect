$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


$path = @($outpath)
function Inspect-ADComputerACLs{
    Try {
        $computers = Get-ADComputer -filter *

        $path = New-Item -ItemType Directory -Force -Path "$($path)\Computer_ACLs"

        foreach($computer in $computers){
            $perms = (Get-ACL "AD:$($computer.DistinguishedName)").Access | Where-Object {($_.AccessControlType -eq "Allow") -and ($_.ActiveDirectoryRights -like "GenericAll") -or ($_.ActiveDirectoryRights -like "*Write*")} | Select @{n="samaccountname";e={$computer.samaccountname}},ActiveDirectoryRights,InheritanceType,AccessControlType,IdentityReference,IsInherited 
            $perms | Export-CSV -Path "$path\$($computer.Name)_DelegatedRights.csv" -NoTypeInformation -Delimiter '^'
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

Return Inspect-ADComputerACLs
