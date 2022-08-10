$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


$path = @($outpath)

function Inspect-EveryoneGPO {
    Try {
        $ErrorActionPreference = "SilentlyContinue"

        $GPOs = Get-GPO -All
        
        $affectedGPOs = @()
        
        $results = @()
        
        Foreach ($GPO in $GPOs) {
            [xml]$gpoReport = Get-GPOReport -Guid $GPO.Id -ReportType XML
        
            $perms = $gpoReport.gpo.computer.extensiondata.extension.msiapplication.securitydescriptor.permissions.trusteepermissions
            $file = $gpoReport.gpo.computer.extensiondata.extension.msiapplication.path
            $trusteeName = $perms.trustee.name.'#text'
            $trusteePermissions = $perms.standard.SoftwareInstallationGroupedAccessEnum
        
            $result = New-Object psobject
            $result | Add-Member -MemberType NoteProperty -Name 'Trustee Name' -Value $trusteeName
            $result | Add-Member -MemberType NoteProperty -Name 'Trustee Permissions' -Value $trusteePermissions
        
            $results += $result
        
            $index = [array]::indexof($results.'Trustee Name','Everyone')
            $name = $results.'Trustee Name'[$index]
            $everyonePermissions = $results.'Trustee Permissions'[$index]
        
            $affectedGPO = New-Object psobject
        
            $affectedGPO | Add-Member -MemberType NoteProperty -name 'Name' -Value $GPO.DisplayName
            $affectedGPO | Add-Member -MemberType NoteProperty -name 'LinksTo' -Value $gpoReport.GPo.LinksTo.SOMPath
            $affectedGPO | Add-Member -MemberType NoteProperty -Name 'Affected File' -Value $file
            $affectedGPO | Add-Member -MemberType NoteProperty -Name 'Trustee Name' -Value $name
            $affectedGPO | Add-Member -MemberType NoteProperty -Name 'Trustee Permissions' -Value $everyonePermissions
        
            $affectedGPOs += $affectedGPO
        }
        
        $affectedGPOs | Out-File -FilePath "$path\GPOAssignmentsExcessivePermissions.txt"

        return $affectedGPOs.Name
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

Return Inspect-EveryoneGPO
