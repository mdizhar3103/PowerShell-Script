# Get file details in current folder

$fl = dir .\ -file
$dt = Get-Date
foreach ($file in $fl) {
    $h=@{
        Name = $file.name
        Modified = $file.LastWriteTime
        Size = $file.length
        Age = $dt - $file.lastwritetime
    }

New-Object psobject -Property $h            # write custom object to pipeline
} 
