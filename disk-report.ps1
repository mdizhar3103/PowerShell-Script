$filename = "$(Get-Date -Format "yyyyddMM")-VolumeReport.txt"
$report = Join-Path -path . -ChildPath $filename

$serverlist = ".\server-lists.txt"
if (Test-Path -Path $serverlist) {
    $computers = Get-Content -Path $serverlist
    $data = .\disk-check.ps1 -Computername $computers
    if ($data) {
        "Volume Report: $(Get-Date)" | Out-File -FilePath $filename
        "Run by: $($env:USERNAME)" | Out-File -FilePath $filename -append
        "================================================" | Out-File -FilePath $filename -Append

        $data | Sort-Object -Property Computername, Drive | Format-Table -GroupBy Computername -Property Drive, FileSystem, SizeGB, FreeGB, PctFree | Out-File -FilePath $report -Append

        $found = $data.computername | Select-Object -Unique
        $missed = $computers | where-object {$found -notcontains $_}
        $missed | Out-File -filepath .\offline.txt

        "Missed Computers" | Out-File -FilePath $filename -append
        $missed | foreach-object {$_.toUpper()} | Out-File -FilePath $filename -append

        Write-Host "Report finished. See $report." -ForegroundColor Green 
    }
    else {
        Write-Warning "Failed to capture any volume information. Check the disk report script."
    }
}
else {
    Write-Warning "Can't find $serverlist"
}
