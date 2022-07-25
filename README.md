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
