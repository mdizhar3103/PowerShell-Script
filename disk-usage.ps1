# Disk Usage Script
Param(
    [string[]]$Computername = $env:COMPUTERNAME 
)

$CSV = ".\disk_usage.csv"

# initializing an empty array
$data = @()

$cimParams = @{
    Classname = "Win32_LogicalDisk"
    Filter = "drivetype = 3"
    ErrorAction = "Stop"
}

Write-Host "Getting disk information from $Computername" -ForegroundColor Cyan
foreach ($computer in $Computername) {
    Write-Host "Getting disk information from $Computername" -ForegroundColor Cyan
    $cimParams.Computername = $Computer
    Try {
        $disks = Get-CimInstance @cimparams
        $data += $disks | Select-Object @{Name = "Computername"; Expression = {$_.SystemName}}, DeviceID, Size, FreeSpace, @{Name = "PctFree"; Expression = { ($_.FreeSpace / $_.size) * 100}}, @{Name = "Date"; Expression = {Get-Date}}
    }
    Catch {
        Write-Warning "Failed to get disk data from $($computer.toUpper()). $($_.Exception.message)"
    }
}

# export only if there is some data init
if ($data) {
    $data | Export-Csv -Path $csv -Append -NoTypeInformation
    Write-Host "Disk Report Complete. See $CSV." -ForegroundColor Green
}
else {
    Write-Host "No disk data found." -ForegroundColor Yellow
}

#-------------
# script - to use previous script output 
Param (
    [string]$path = ".\disk_usage.csv",
    [string]$report_path = ".\"
)

    # import csv data
    # verify file exists
if (Test-Path -path $path) {
    $data = Import-CSV -Path $path | foreach-object {
        [pscustomobject]@{
            Computername = $_.Computername
            DeviceID = $_.DeviceID
            SizeGB = ($_.size / 1GB) -as [int32]
            FreeGB =($_.freespace / 1GB)
            PctFree = $_.PctFree -as [double]
            Date = $_.Date -as [datetime]
        }
    }
    $grouped = $data | Group-Object -Property Computername
}
else {
    Write-Warning "Can't find $path."
    return
}

    # save the result to text-file
$header = @"
Disk History Report $((Get-Date).ToShortDateString())
=====================================================
Data Source = $path

==============
Latest Check
==============
"@

$timestamp = Get-Date -format yyyyMMdd
$outputFile = "diskreport-$timestamp.txt"
$outputPath = Join-Path -path $report_path -ChildPath $outputFile

$outParams = @{
    FilePath = $outputPath
    Encoding = "ASCII"
    Append = $True
    Width = 120
}

$header | Out-File @outParams
$latest = foreach($computer in $grouped) {
    $devices = $computer.Group | Group-Object -Property DeviceID
    $devices | foreach-object {
        $_.Group | Sort-Object Date -Descending | Select-object -first 1
    }
}

$latest | Sort-object -property Computername | Format-Table -AutoSize | Out-file @outParams

$header = @"
====================
Low Diskspace <= 30
====================
"@

$header | Out-File @outParams
$latest | Where-Object {$_.PctFree -le 30} | Sort-Object -Property Computername | Format-Table -AutoSize | Out-File @outParams

Get-Item -Path $OutputPath
