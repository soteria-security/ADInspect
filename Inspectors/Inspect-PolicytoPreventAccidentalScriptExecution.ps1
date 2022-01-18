Function Inspect-PolicytoPreventAccidentalScriptExecution{
    #Get Domain
    $domain = Get-ADDomain

    #Get the GPO information and generate reports
    $GPOs = Get-GPO -All -Domain $domain.DNSRoot -Server $domain.PDCEmulator

    $mitigatingPolicies = @()

    $extensions = @("js","jse", "cjs", "mjs", "iced", "liticed", "iced.md", "cs", "coffee", "litcoffee", "coffee.md", "ts", "tsx", "ls", "es6", "es", "jsx", "sjs", "eg")

    $missingExtensions = @()

    Foreach ($extension in $extensions){
        #Options to check for
        $replace = "Properties action=`"R`" fileExtension=`"$extension`" applicationPath=`"C:\\Windows\\System32\\Notepad.exe`" default=`"1`""
        $update = "Properties action=`"U`" fileExtension=`"$extension`" applicationPath=`"C:\\Windows\\System32\\Notepad.exe`" default=`"1`""

        Foreach ($gpo in $GPOs){
            $result = Get-GPOReport -Guid $gpo.Id -ReportType XML

            if (($result -match $replace) -or ($report -match $update)) {
                $mitigatingPolicies += $gpo.DisplayName
                }
            Else {
                $missingExtensions += $extension
                }
            }
        }

    If ($mitigatingPolicies.count -eq 0){
        Return $missingExtensions
        }
}

Return Inspect-PolicytoPreventAccidentalScriptExecution