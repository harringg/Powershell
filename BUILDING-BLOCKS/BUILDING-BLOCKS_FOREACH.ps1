<# BUILDING BLOCK
Get-Service -Name B* | ForEach { $_.Pause() }
#> #end BUILDING BLOCK

<# BUILDING BLOCK
$services = Get-Service -Name B*

ForEach ($service in $services) {
    $service.Pause()
    }
#> #end BUILDING BLOCK

<# EXAMPLE #>
foreach ($service in $services)
    {
    $service | select Name,Displayname,Status | sort Status
    }

#####
$files = Get-ChildItem C:\Temp -File

Add-content -path merged_file.txt -Value ''

foreach ($file in $files) {
        Add-Content -Value (Get-Content $file.FullName) -Path merged_file.txt
}

ii merged_file.txt