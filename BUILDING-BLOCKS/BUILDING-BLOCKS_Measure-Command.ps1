Measure-Command {Get-ADUser -Filter {GivenName -like 'j*' -and Surname -like 'W*'}}
 
Measure-Command {Get-ADUser -Filter * | Where-Object {$_.GivenName -like 'j*' -and $_.Surname -like 'W*'}}