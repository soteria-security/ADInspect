Function Inspect-GPO_UAC {
    #Get Domain
    $domain = Get-ADDomain

    #Get the GPO information and generate reports
    $GPOs =  Get-GPO -All -Domain $domain.DNSRoot

    $mitigatingPolicies = @()

    $Strings = @("FilterAdministratorToken", "EnableUIADesktopToggle", "ConsentPromptBehaviorAdmin", "ConsentPromptBehaviorUser", "EnableInstallerDetection", "ValidateAdminCodeSignatures", "EnableSecureUIAPaths", "EnableLUA", "PromptOnSecureDesktop", "EnableVirtualization")

    #Go through each Object and check its XML against $String
    Foreach ($GPO in $GPOs)  {
        #Get Current GPO Report (XML)
        $CurrentGPOReport = Get-GPOReport -All -Domain $domain.DNSRoot -Server $domain.PDCEmulator -ReportType XML
        
        Foreach ($string in $strings){
            If ($CurrentGPOReport -match $String)  {
                $mitigatingPolicies += $CurrentGPOReport
            }
        }
    }

    If ($mitigatingPolicies.Count -eq 0) {
        Return "No GPO found enforcing UAC prompt for elevation"
    }
}

do {
	Write-Progress -Activity "Gathering Information" -Status "Gathering..." -PercentComplete -1
} while (Inspect-GPO_UAC)