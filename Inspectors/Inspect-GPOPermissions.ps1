$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


$path = @($outpath)

Function Inspect-GPOPermissions {
    Try {
        $results = @()

        Foreach ($GPO in (Get-GPO -All)){
            Foreach ($Perm in (Get-GPPermissions $GPO.DisplayName -All)) {
                $result = New-Object PSObject -property @{GPO=$GPO.DisplayName;Trustee=$Perm.Trustee.Name;Permission=$Perm.Permission}
                
                $results += $result | Where-Object {($_.Trustee -eq 'Everyone') -or ($_.Trustee -eq 'Authenticated Users')  -or ($_.Trustee -eq 'Domain Users') -and ($_.Permission -like "GpoEdit*")}
                }
            }
            
        If ($results){
            $results | Select-Object GPO,Trustee,Permission | Export-CSV -Path "$path\GPOsWithExcessivePermissions.csv" -NoTypeInformation

            Return $results.GPO | Select-Object -Unique
        }

        Return $null
        
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

Inspect-GPOPermissions
