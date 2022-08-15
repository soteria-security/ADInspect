$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


Function Inspect-AdminsProtectedUsers{
    Try {
        $adminGroups = Get-ADGroup -ResultSetSize $null -Filter * -Properties GroupType | Where-Object {$_.SID -like "S-1-5-32-*"} | Select-Object Name 

        $usersToBeRemediated = @()

        foreach ($group in $adminGroups.Name){
            if ((Get-ADGroupMember $group).count -ne 0){
                $members = Get-ADGroupMember $group -Recursive
                foreach ($member in $members){
                    $memberOf = Get-ADPrincipalGroupMembership -Identity $member.DistinguishedName
                    if ($memberOf.Name -notcontains 'Protected Users'){
                        $usersToBeRemediated += "$($member.samaccountname) is a member of $group and not a member of Protected Users"
                    }
                }
            }
        }
        Return $usersToBeRemediated
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

Return Inspect-AdminsProtectedUsers
