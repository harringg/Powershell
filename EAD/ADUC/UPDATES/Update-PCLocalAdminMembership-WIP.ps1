$COMPUTERNAME = 'localhost'
$GroupName = 'Administrators'
#$GroupName = 'Remote Desktop Users'

				FOREACH ($PC in $COMPUTERNAME) {
					WRITE-HOST $PC
					[string]$strComputer = $PC
                    #Use ADSI Adapter to format PC Name
					$computer = [ADSI]("WinNT://" + $strComputer + ",computer")

					$Group = $computer.psbase.children.find("$GroupName")

					$members = $Group.psbase.invoke("Members") |
					foreach {
                                                  # Use "Name" or "ADsPath" as desired
						$_.GetType().InvokeMember("ADsPath", 'GetProperty', $null, $_, $null)
					} #end $Members | FOREACH
					
                    $MembersAll_All = @()
					FOREACH ($user in $members) {
						$objUser = [ADSI]("WinNT://$strComputer/$user")
                        $SchemaClassName = $objUser.SchemaClassName
                        $Description = $ObjUser.Description
                        
                        $MembersProperties = [ORDERED]@{
                                'strComputer' = ($strComputer)
                                'user' = ($user)
                                'SchemaClassName' = ($SchemaClassName)
                                'Description' = ($Description)
                                }
                        $MembersAll = New-Object -TypeName PSCustomObject -Property $MembersProperties
                        $MembersAll_All += $MembersAll

	                    [string]$output = "{0},{1},{2},{3}" -f $strComputer,$user,$SchemaClassName,$Description
    					#[string]$output = $strComputer + "," + $user + "," + $objUser.SchemaClassName + "," + $ObjUser.Description
						#write-host $output
                        #$output |out-file -append .\L_out.txt
						Remove-Variable objUser
					} # end FOREACH ($user in $members)
				} #end FOREACH ($PC in $COMPUTERNAME)


# This loops through the WinNT:// accounts and "groups them"                
ForEach ($MembershipUser in $membersall_all.user) {
	
	if ($MembershipUser -like "*sv.rs*") {
		$MembershipUser | group -AsHashTable | sort Name
        }
	elseif ($MembershipUser -like "*arsndfar5*") {
		$MembershipUser | group -AsHashTable | sort Name
	}
    else {$MembershipUser | group -AsHashTable | sort Name
    }
}  