## Getting Started with Powershell Script

- ***Execution Policy***: Run in an elevated session (run as admin), needs to be set once per machine, can be set via group policy.
- ***Restricted:*** By Default Powershell policy, means you can't run powershell script
- ***RemoteSigned:*** User default policy for local
- ***AllSigned:*** Don't run script unless it is digitally signed
- ***Unrestricted:*** Not recommended, just to run without restrictions
- ***ByPass:*** This policy takes care of secruity outside powershell world.

**Commands for Execution Policy** 
```powershell
>>> Set-ExecutionPolicy RemoteSigned
>>> Get-ExecutionPolicy
>>> Set-ExecutionPolicy allsigned -Force
>>> Set-ExecutionPolicy unrestricted -Force
>>> help about_Execution_Policies
```

### Working with Powershell
```powershell
>>> get-content my-script-1.ps1
get-eventlog -LogName System -Newest 100 | Group-Object -Property source -NoElement | Sort-Object -Property count,Name -Descending

# Running the script
>>> .\my-script-1.ps1
>>> .\my-script-1.ps1 | Format-Table -AutoSize

# open currect directory
>>> invoke-item .
```

**Scope of Powershell Scripts**
- Global
- Script
- Private
- Number Scopes

> Powershell can only write or create in current scope

```powershell
>>> write-host "Hello! from Izhar" -ForegroundColor Green
>>> [int32]$x = Read-host "Enter a new value for X"
>>> write-host "Setting `$x to $x" -ForegroundColor Green
>>> $x+$x

# Setting Global reference
>>> $global:x+$global:x

# Creating Profile scripts
>>> $profile                                # get current profile
>>> $profile.CurrentUserCurrentHost         # applies to specific Host
>>> $profile.CurrentUserAllHost             # applies to all Hosts like (console, ISE, VSCode and other hosted by powershell)
>>> $profile.AllUsersAllHosts               # Requires local admin rights to create or modify
>>> $profile.AllUsersCurrentHost            # Requires admin rights

>>> $profile | select *host* | format-list

# Creating new profile directory
>>> new-item $profile -Force
>>> add-content -Value 'cd c:\scripts' -Path $profile
>>> add-content -Value '$var = 7299' -Path $profile
>>> add-content -Value '$host.privatedata.errorforegroundcolor="green"' -Path $profile
>>> add-content -Value 'Write-Host "Hello Art. Have a nice day."' -foregroundcolor magenta- -Path $profile
>>> powershell
    # You will get output of above commands
>>> throw "oops"
    # display error color as specified in profile

# Setting some more profiles attributes
>>> new-item $profile.CurrentUserAllHosts -Force
>>> add-content -value "set-alias np Notepad" -Path $profile.CurrentUserAllHosts
>>> ise $profile
>>> help about_profiles


# Get Event Logs
>>> Get-Eventlog System -EntryType Error -Newest 1000
>>> $computername = $env:computername
>>> Get-Eventlog System -EntryType Error -Newest 1000 -ComputerName $computername
>>> Get-Eventlog System -EntryType Error -Newest 1000 -ComputerName $computername | Group -Property Source -NoElement
```


#### Using array
```powershell
>>> $num = 1..10
>>> $num.count
>>> $num -is [array]
>>> $num | Get-Member
>>> $num | foreach-object { $_ * 5}
>>> $num | foreach-object { $_ * 5} | measure-object -sum

>>> get-process | where starttime |  select Name,ID,@{Name='Run';Expression={(Get-Date)-$_.starttime}} | sort Run -Descending | Select -first 5
```

#### Working with String 
```powershell
>>> $s = "Mohd Izhar"
>>> $s | Get-Member
>>> $s.length
>>> $s.toUpper()
>>> $s.substring(4)
>>> $s.substring(1,4)
>>> $s.IndexOf("o")
>>> $s.LastIndexOf("h")
>>> $s.replace("o", "0")
>>> $s.split(" ")
```

#### Using Datetime
```powershell

>>> $now = Get-Date
>>> $now | get-member | more
>>> $now | select *
>>> $now.ToShortDateString()
>>> $now.ToShortTimeString()
>>> $now.ToUniversalTime()
>>> Get-Date -Format ddMMyyyy
>>> Get-Date -Format ddMMyyyy_hhmmss
>>> $now.AddDays(42)
>>> $now.AddHours(500)
>>> "3/31/2022 9:30pm" -as [datetime]

# list file created after 45 days ago
>>> $lastdate = (Get-Date).AddDays(-45).Date
>>> dir .\ -File | where {$_.LastWriteTime -le $lastdate}
```

#### Using Math functions
```powershell
>>> [math]
>>> [math].GetMembers() | Select Name,MemberType -unique | sort MemberType,Name | more
>>> [math]::PI
>>> [math]::E
>>> [math]::pow.OverloadDefinitions
>>> [math]::pow(3, 2)
>>> [math]::sqrt(9)
>>> $num = 12345.6789
>>> [math]::Round($num, 2)
>>> [math]::Truncate($num)
>>> $num -as [int]              # treat this number as int

>>> Get-CimInstance win32_operatingsystem | Select *memory*
>>> Get-CimInstance win32_operatingsystem -ComputerName $env:computername | Select PSComputername,@{Name="TotalMemGB";Expression={$_.totalvisiblememorysize/1MB -as [int]}}, @{Name="FreeMemGB";Expression={ [math]::Round(($_.freephysicalmemory/1Mb),4)}}, @{Name="PctFreeMem";Expression = { [math]::Round(($_.freephysicalmemory/$_.totalvisiblememorysize)*100, 2)}}

```

#### Working with other available function
```powershell
>>> $wsh = new-object -com wscript.shell
>>> $wsh.Popup.OverloadDefinitions
>>> $wsh.Popup("Press the key to continue.", 10, "Powershell Automation", 0+64) 
>>> $wsh.Popup("Wrong Key Pressed. Do you want to try again", -1, "Script Error", 4+32)

# window title
>>> $host.ui.RawUI.WindowTitle

# script.ps1

"Server-1", "Server-2", "Server-3" | foreach-object {
    $host.ui.RawUI.WindowTitle = "Querying uptime from $($_.toUpper())"
    start-sleep -Seconds 2
    Get-CimInstance win32_OperatingSystem -computername $_ | Select PSComputername, LastBootUpTime, @{Name="Uptime";Expression={(Get-Date) - $_.LastBootUpTime }}
}

>>> $host.ui.RawUI

# Get-Services
>>> $fg = $host.ui.RawUI.ForegroundColor
>>> get-service | foreach {
    if ($_.status -eq 'stopped'){
        $host.ui.RawUI.ForegroundColor = "red"
    } else {
        $host.ui.RawUI.ForegroundColor = $fg
    }
    $_
}

>>> $bg = $host.ui.RawUI.BackgroundColor
>>> $host.ui.RawUI.BackgroundColor = "black"

# Default PS parameters values
>>> $PSDefaultParameterValues.Add("get-eventlog:logname","system")
>>> $PSDefaultParameterValues.Add("get-ciminstance:verbose",$True)
>>> $PSDefaultParameterValues
>>> get-eventlog -Newest 10
>>> get-eventlog -LogName application -Newest 10
>>> get-ciminstance Win32_NetworkAdapter

>>> $PSDefaultParameterValues.remove("get-ciminstance:verbose")
>>> $PSDefaultParameterValues.clear()           # to clear all default values
```

### Controller Script
Powershell Script that orchestrates or runs other Powershell commands, functions and scripts
```powershell
>>> Get-Volume -DriveLetter C -CimSession $env:computername | Select-object PSComputername,DriveLetter,Size,SizeRemaining,@{Name="PctFree";Expression={($_.SizeRemaining/$_.size)*100}}

# See: disk-check.ps1
# See: disk-report.ps1
```

### Testing Remote Connection
```powershell
Test-NetConnection -ComputerName ipaddress/hostname -Port specific_port_number
Ex: Test-NetConnection -ComputerName 1.2.1.2 -Port 1521
```

### Net config
```powershell
get-netipconfiguration
sconfig
```
