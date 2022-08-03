Function Inspect-GPO_ISOBlock{
    #Get Domain
    $domain = Get-ADDomain

    #Get the GPO information and generate reports
    $GPOs = Get-GPO -All -Domain $domain.DNSRoot -Server $domain.PDCEmulator

    $mitigatingPolicies = @()

    $strings = @('hive="HKEY_CLASSES_ROOT" key="Windows.IsoFile\shell" name="" type="REG_SZ" value=""','hive="HKEY_CLASSES_ROOT" key="Windows.IsoFile\shell\mount" name="ProgrammaticAccessOnly" type="REG_SZ" value=""')

    Foreach ($string in $strings){
        Foreach ($gpo in $GPOs){
            $result = Get-GPOReport -Guid $gpo.Id -ReportType XML

            $str = [regex]::Escape($string)

            if ($result -match $str) {
                $mitigatingPolicies += $gpo.DisplayName
                }
            }
        }

    If ($mitigatingPolicies.count -eq 0){
        Return "No GPO to block ISO file launch"
        }
    Return $null
}

Return Inspect-GPO_ISOBlock