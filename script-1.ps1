$computername = $env:computername

$data = Get-Eventlog System -EntryType Error -Newest 1000 -ComputerName $computername | Group -Property Source -NoElement

$title = "System Log Analysis"

$footer = "<h5>report run $(Get-Date)</h5>" 

$css = "http://jdhitsolutions.com/sample.css"

$data | Sort -Property Count,Name -Descending | Select Count,Name | ConvertTo-Html -Title $Title -PreContent "<H1>$Computername</H1>" -PostContent $footer -CssUri $css | Out-File c:\path_to_file.html

invoke-item c:\path_to_html_file
