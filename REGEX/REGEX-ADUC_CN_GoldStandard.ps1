$Regex = 'CN=Last\, First - ARS,OU=Users,OU=OCD,OU=Units,OU=3060,OU=PA,OU=ARS,OU=Agencies,DC=usda,DC=net','CN=First  Last,OU=Users,OU=OCD,OU=Units,OU=3060,OU=PA,OU=ARS,OU=Agencies,DC=usda,DC=net'

($regex | ForEach-Object {
						if (($_ -match [regex]"CN=.*\\") -eq $TRUE) {
							$DN_FIRST = $_ -creplace '(^.*\\,\s|\s-.*$)', ''
							$DN_LAST = $_ -creplace '(CN=|\\.*$)', ''
							$Employee = "{0} {1}" -f $DN_FIRST, $DN_LAST;
							$Employee
						} #end if CN=.*\\
						elseif (($_ -match [regex]"(CN=|,OU.*$)") -eq $TRUE) {
							$_ -replace [regex]"(CN=|,OU.*$)", ''
						} #end elseif (CN=|,OU.*$)
					} #end foreach-object
					) -join ','


#First Last, First Last