Param(
    [string[]]$Computername = $env:COMPUTERNAME
)

foreach ($computer in $Computername){
    if (Test-Connection -ComputerName $Computer -Count 2 -Quiet){
        Try {
            Write-Host "Getting volume data from $($computer.toUpper())" -Foreground Yellow
            Get-Volume -CimSession $computer -ErrorAction Stop | Where-Object {$_.DriveLetter} | Select-Object @{Name="Computername";Expression={$_.PSComputername.ToUpper()}}, @{Name="Drive";Expression = {$_.DriveLetter}},
            FileSystem,
            @{Name="SizeGB"; Expression = {$_.size / 1gb -as [int32]}},
            @{Name="FreeGB"; Expression={[math]::Round($_.SizeRemaining / 1gb,2)}},
            @{Name="PctFree"; Expression = {[math]::Round(($_.SizeRemaining / $_.Size) * 100, 2)}}
        }
        Catch {
            Write-Warning "Can't get volume data from $($computer.ToUpper()). %($_.Exception.Message)"
        }
    }
    else {
        Write-Warning "Can't ping $($computer.ToUpper())."
    }
}
