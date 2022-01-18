Function Inspect-NTLMv1{
    $Domains = (Get-ADForest).Domains
    $count = 0
    
    Foreach ($domain in $Domains) {
        $DCs = Get-ADDomainController -Filter *
        Foreach ($dc in $DCs){
            Try {
                $events = Invoke-Command -ComputerName $dc.HostName -ScriptBlock {Get-WinEvent -FilterHashtable @{logname='Security';ID=4624} | Where-Object {$_.Message -like "*NTLM V1*"}} -ErrorAction SilentlyContinue

                If ($events.count -ne 0){
                    $count += $events.count
                }
            }
            Catch{
                "Skipping $($DC.Hostname)"
            }
        }

        If ($count -ne 0){
            Return "NTLM V1 is enabled on $domain"
        }
    }
    Return $null
}

Return Inspect-NTLMv1