$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling


Function Inspect-GPO_UAC {
    Try {
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

Return Inspect-GPO_UAC
