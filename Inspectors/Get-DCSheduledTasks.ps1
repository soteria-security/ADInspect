$path = @($out_path)

Function Get-DCSheduledTasks{
    #Get a list of all domain controllers
    $DCs = Get-ADDomainController -Filter *

    $allTasks = 0

    foreach ($dc in $DCs){
        Invoke-Command -ComputerName $dc.name -ScriptBlock {
            $tasks = Get-ScheduledTask | Get-ScheduledTaskInfo
            If ($tasks.count -gt 0){
                $tasks | Export-Csv -Path "$path\$($DC.name)_ScheduledTasks.csv" -NoTypeInformation
                $allTasks += $tasks.count
            }
        }
    }
    If ($allTasks -ne 0){
        Return $allTasks
    }
    Else {
        Return $null
    }
}

Return Get-DCSheduledTasks