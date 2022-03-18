<#
HUGE thanks to @ChrisDent and @cofl from various Discord communities for helping me nail this one down.
#>


$path = @($out_path)

function Inspect-EveryoneGPO {
    $ErrorActionPreference = "SilentlyContinue"

    $affectedGPOs = @()

    $GPOs = Get-GPO -All

    Foreach ($GPO in $GPOs) {
        [xml]$gpoReport = Get-GPOReport -Guid $GPO.Id -ReportType XML

        $gpPath = @("NetworkShares", "FileSettings", "RegistrySettings", "MsiApplication")

        Foreach ($x in $gpPath) {
            $file = $gpoReport.gpo.computer.extensiondata.extension.$x.path
            $permissions = $gpoReport.gpo.computer.extensiondata.extension.$x.securitydescriptor.permissions.trusteepermissions

            $ace = ($permissions | Where-Object { $_.trustee.name.'#text' -eq 'Everyone' }).standard.SoftwareInstallationGroupedAccessEnum
    
            if ($ace) {
                $affectedGPO = [pscustomobject]@{
                    Name                  = $GPO.DisplayName
                    LinksTo               = $GPO.LinksTo.SOMPath
                    'Affected File'       = $file
                    'Trustee Name'        = $name
                    'Trustee Permissions' = $ace
                }
                $affectedGPOs += $affectedGPO
            }
        }
    }

    $affectedGPOs | Out-File -FilePath "$path\GPOAssignmentsExcessivePermissions.txt"

    return $affectedGPOs.Name
}

Return Inspect-EveryoneGPO
