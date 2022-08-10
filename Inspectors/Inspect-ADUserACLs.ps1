$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


$path = @($outpath)
function Inspect-ADUserACLs{
    Try{
        $users = Get-ADUser -filter *
        
        $path = New-Item -ItemType Directory -Force -Path "$($path)\AD_User_ACLs"

        foreach($user in $users){
            $perms = (Get-ACL "AD:$($user.DistinguishedName)").Access | Where-Object {($_.AccessControlType -eq "Allow") -and ($_.ActiveDirectoryRights -like "GenericAll") -or ($_.ActiveDirectoryRights -like "*Write*")} | Select @{n="samaccountname";e={$user.samaccountname}},@{n="enabled";e={$user.enabled}},ActiveDirectoryRights,InheritanceType,AccessControlType,IdentityReference,IsInherited 
            
            $perms | Export-CSV -Path "$path\$($user.Name)_DelegatedRights.csv" -NoTypeInformation -Delimiter '^'
           <# $perms = dsacls $user.DistinguishedName 
            $perms | Out-File -FilePath "$path\$($user.Name)_DelegatedRights.txt"#>
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

Return Inspect-ADUserACLs

