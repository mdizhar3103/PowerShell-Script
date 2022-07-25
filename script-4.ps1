
# Using Type accelerator and foreach-object
dir ".\" -file | 
foreach-object {
    [pscustomobject]@{
        Name = $_.name
        Modified = $_.LastWriteTime
        Size = $_.length
        Age = (Get-Date) - $_.lastwritetime
    }
}
