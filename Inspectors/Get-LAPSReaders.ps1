$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


<#
    $url = "https://adsecurity.org/?p=3164#:~:text=Since%20the%20LAPS%20computer%20attribute,aren't%20actively%20LAPS%20managed."
    This is a placeholder file
#>

$path = @($outpath)

function Get-LAPSReaders{
    Try {
        $OUs = Get-ADOrganizationalUnit -Filter *

        $objects = @()

        $users = @()

        Foreach ($ou in $OUs){
            try {
                $objects += Find-AdmPwdExtendedRights -Identity $ou.distinguishedname | Select-Object -ExpandProperty ExtendedRightHolders -Unique
            }
            catch {
                return $null
            }

        }

        $objects = $objects | Where-Object {$_ -notlike "NT Authority\*"} | Select-Object -Unique

        foreach ($object in $objects){
            $obj = $object.IndexOf("\")
            $name = $object.substring($obj+1)
            $users += Get-ADObject -filter {name -like $name}
        }

        If ($users.count -gt 0){
            $users | Export-Csv "$path\LAPSReaders.csv" -NoTypeInformation
            return $users.count
        }

        return $null
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

Return Get-LAPSReaders
