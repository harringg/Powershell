$ComputerName = 'localhost'
$UserName = 'first.last'
Get-GPResultantSetOfPolicy -Computer $ComputerName -User $UserName -ReportType Html -Path c:\temp\GYgpresult.html