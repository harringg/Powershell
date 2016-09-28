# Source: http://www.adamtheautomator.com/active-directory-auditing-user-logon-logoff/
# Date viewed: 160212

# GH Note: Fails getting these error codes

## Find all computers in the My Desktops OU

$DesktopOU = 'OU=Desktops,OU=DomainComputers,DC=Fargo,DC=local'

$Computers = (Get-ADComputer -SearchBase $DesktopOU -Filter * | Select-Object Name).Name
$computer = 'localhost'
## Build the Xpath filter to only retrieve event IDs 4647 or 4648
$EventFilterXPath = "(Event[System[EventID='4647']] or Event[System[EventID='4648']])"

## Build out all of the calculated properties ahead of time to pull the computer name, the event of "Logon" or "Logoff", the time the event was generated and the account in the message field.  If the ID is 4647, we need to find the first instance of "Account Name:" but if it's 4648 we need to find the second instance.  Regex groupings are ugly but powerful.

$SelectOuput = @(
    @{n='ComputerName';e={$_.MachineName}},
    @{n='Event';e={if ($_.Id -eq '4648') { 'Logon' } else { 'LogOff'}}},
    @{n='Time';e={$_.TimeCreated}},
    @{n='Account';e={if ($_.Id -eq '4647') { $i = 1 } else { $i = 3 } [regex]::Matches($_.Message,'Account Name:\s+(.*)\n’).Groups[$i].Value.Trim()}}
)

## Query all the computers and output all the information we need

foreach ($Computer in $Computers) {
    Get-WinEvent -ComputerName $Computer -LogName Security -FilterXPath $EventFilterXPath | Select-Object $SelectOuput | Format-Table -AutoSize
}

 Get-WinEvent -ComputerName localhost -LogName Security -FilterXPath $EventFilterXPath | Select-Object $SelectOuput | Format-Table -AutoSize
