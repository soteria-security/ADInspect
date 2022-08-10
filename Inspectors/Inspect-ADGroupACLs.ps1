$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


$path = @($outpath)
function Inspect-ADGroupACLs{
    Try {
        $groups = Get-ADGroup -filter *
        
        $path = New-Item -ItemType Directory -Force -Path "$($path)\AD_Group_ACLs"

        foreach($group in $groups){
            $perms = (Get-ACL "AD:$($group.DistinguishedName)").Access | Where-Object {($_.AccessControlType -eq "Allow") -and ($_.ActiveDirectoryRights -like "GenericAll") -or ($_.ActiveDirectoryRights -like "*Write*")} | Select-Object @{n="samaccountname";e={$group.samaccountname}},ActiveDirectoryRights,InheritanceType,AccessControlType,IdentityReference,IsInherited

            $name = $group.Name
            
            $pattern = '[\\\[\]\{\}/():;\*\"]'

            $name = $name -replace $pattern, '-'
            
            $perms | Export-CSV -Path "$path\$($name)_DelegatedRights.csv" -NoTypeInformation -Delimiter '^'
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

Return Inspect-ADGroupACLs

