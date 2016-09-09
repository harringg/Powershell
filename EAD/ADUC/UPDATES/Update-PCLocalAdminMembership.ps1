function UPDATE-PCLocalAdminMembership {
	<#
	.SYNOPSIS
	
	.DESCRIPTION
	
	.PARAMETER REPORTTYPE

	.PARAMETER PRODUCTION
		This is used to review your results before actually running the script
        REVIEW run the script to review results before running live in production enviroment
        Verb-Noun -PRODUCTION REVIEW
        LIVE Will run the script live in production enviroment
        Verb-Noun -PRODUCTION LIVE
	
	.EXAMPLE
				PS C:\> Export-GPOReports -ReportType HTML -PRODUCTION REVIEW
	            PS C:\> Export-GPOReports -ReportType HTML -PRODUCTION LIVE
	.NOTES
		    NAME: Export-GPOReports
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 9/9/2016 2:30 PM
			LASTEDIT: 9/9/2016 2:30 PM
            KEYWORDS:
	.LINK
		EAD Scripts
#>
	[CmdletBinding(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	[OutputType([array])]
	param
	(
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet('REVIEW', 'ADD', 'REMOVE')]
		[string]$PRODUCTION = 'REVIEW',
		[Parameter(Mandatory = $TRUE)]
		[string]$COMPUTERNAME,
		[Parameter(Mandatory = $TRUE)]
		[string]$UserName,
		[ValidateSet('Administrators', 'Remote Desktop Users')]
		[Parameter(Mandatory = $TRUE)]
		[string]$GROUPS
	)
	
	BEGIN {
		$Date = Get-Date -format yyMMdd
		$DomainName = 'USDA'
		
		Switch ($Groups) {
			'Administrators' { [string]$GroupName = 'Administrators' }
			'Remote Desktop Users' { [string]$GroupName = 'Remote Desktop Users' }
		}
	} #end BEGIN
	
	PROCESS {
		
		Switch ($PRODUCTION) {
			REVIEW {
				FOREACH ($PC in $COMPUTERNAME) {
					WRITE-HOST $PC
					[string]$strComputer = $PC
					$computer = [ADSI]("WinNT://" + $strComputer + ",computer")
					$Group = $computer.psbase.children.find("$GroupName")
					#$members= $Group.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)} 
					$members = $Group.psbase.invoke("Members") |
					foreach {
                                                  # Use "Name" or "ADsPath" as desired
						$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
					} #end $Members | FOREACH
					
					FOREACH ($user in $members) {
						$objUser = [ADSI]("WinNT://$strComputer/$user")
						[string]$output = $strComputer + "," + $user + "," + $objUser.SchemaClassName + "," + $ObjUser.Description
						write-host $output
						#$output |out-file -append .\L_out.txt
						Remove-Variable objUser
					} # end FOREACH ($user in $members)
				} #end FOREACH ($PC in $COMPUTERNAME)
			} #end REVIEW
			ADD {
				$AdminGroup = [ADSI]"WinNT://$ComputerName/$GroupName,group"
				$User = [ADSI]"WinNT://$DomainName/$UserName,user"
				$AdminGroup.Add($User.Path)
			} # end ADD
			REMOVE {
				$AdminGroup = [ADSI]"WinNT://$ComputerName/$GroupName,group"
				#$User = [ADSI]"WinNT://$DomainName/$UserName,user"
                $User = [ADSI]"WinNT://S-1-5-21-2670568672-578679464-3423941738-4665,user"
                
				$AdminGroup.Remove($User.Path)
			} #end REMOVE
		} #end Switch-Production
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end UPDATE-PCLocalAdminMembership