$First = 'Grant'
$FirstLen = $First.Length
$Last = 'Harrington'
$LastLen = $Last.Length
$Total = ($FirstLen + $LastLen + 1)

If (($FirstLen + $LastLen + 1) -le 20) {
$Global:sAMAccountName = "{0}.{1}" -f $First,$Last
} else
{ $FirstTrimLen = ($Total - 20)
$First = $First.Substring(0,$FirstLen-$FirstTrimLen)
$Global:sAMAccountName = "{0}.{1}" -f $First,$Last
}

$sAMAccountName
Get-aduser $sAMAccountName

#samAccountName - <givenName>+.+<sn>    (<= 20 characters.  Truncate givenName as necessary. No spaces or special characters beyond periods are permitted.  See resolving name collisions below)
#For naming collisions, first add middle initial to reach uniqueness.  If still not unique, add sequential numbers (1,2,3…) at end of samAccountName until unique name is found.