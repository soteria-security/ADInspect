function Inspect-EveryoneGPO {
    $ErrorActionPreference = “silentlycontinue”

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
    
    $affectedGPOs
}

Return Inspect-EveryoneGPO