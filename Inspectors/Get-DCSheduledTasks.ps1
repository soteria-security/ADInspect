$path = @($out_path)

Function Get-DCSheduledTasks{
    #Get a list of all domain controllers
    $DCs = Get-ADDomainController -Filter *

    $allTasks = @()

    foreach ($dc in $DCs.Name){
        $tasks = Get-ScheduledTask -CimSession $dc | Where-Object {$_.state -match "Running"} | Get-ScheduledTaskInfo
        If ($tasks.count -gt 0){
            $tasks | Export-Csv -Path "$path\$($DC)_ScheduledTasks.csv" -NoTypeInformation
            foreach ($task in $tasks) {
                $allTasks += $task.TaskName
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