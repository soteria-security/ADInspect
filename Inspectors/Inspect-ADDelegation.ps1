$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


$path = @($outpath)
Function Inspect-Delegation{
    Try {
        $count = 0

        $OUs = Get-ADOrganizationalUnit -Filter {Name -like '*'} 

        If ((Test-Path -Path $path\ActiveDirectoryDelegation) -eq $false){
            New-Item -Path $path -Name "ActiveDirectoryDelegation" -ItemType "directory"
            }

        $path = "$($path)\ActiveDirectoryDelegation"
        
        Foreach ($OU in $OUs){
            $perms = dsacls $OU.DistinguishedName 
            $perms | Out-File -FilePath "$path\$($OU.Name)_DelegatedRights.txt" 
            If ($perms){
                $count ++
            }
        }

        Return "Delegation found on $($count) Organizational Units."
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

Return Inspect-Delegation
