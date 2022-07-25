# -- Parameterizing script


Param(
    [string]$Log = "System",
    [string]$Computername = $env:computername,
    [int32]$Newest = 500,
    [string]$ReportTitle = "Event Log Report",
    [Parameter(Mandatory,HelpMessage = "Enter the path for the HTML file.")]
    [string]$Path
)

$data = Get-Eventlog -logname $Log -EntryType Error -Newest $Newest -ComputerName $Computername | Group-object -Property Source -NoElement

$footer = "<h5>report run $(Get-Date)</h5>" 
$css = "http://jdhitsolutions.com/sample.css"
$precontent="<H1>$Computername</H1><H2>last $newest error sources from $Log</H2>"

$data | Sort -Property Count,Name -Descending | Select Count,Name | ConvertTo-Html -Title $ReportTitle -PreContent $precontent  -PostContent $footer -CssUri $css | Out-File -FilePath $Path
