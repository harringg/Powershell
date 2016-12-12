#TODO
# If Federal, add to Federal list Done 161212
# If BLDG = NCSL, add to NCSL list Done 161212

function New-LocalADUser {
<#
            .SYNOPSIS 
                Creates a new AD user, enables the account and set the default password.

            .DESCRIPTION
                Creates a new AD user, enables the account and set the default password.
                           
            .NOTES
            NAME: New-LocalADUser
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 3/12/2015 7:53 AM
            LASTEDIT: 10/11/2016 8:29 PM 
            KEYWORDS: ADUC 

            .EXAMPLE
            C:\PS> New-LocalADUser
            
            #>
	[CMDLETBINDING(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	param (

		[Parameter(Mandatory = $TRUE)]
		[ValidateSet('REVIEW', 'LIVE')]
		[string]$PRODUCTION = 'REVIEW'
	)
	
	BEGIN {
		$NewEmployee = Import-Csv 'C:\Users\grant.harrington\Documents\GitHub\Powershell\EAD\ADUC\USER\NewEmployee_SingleEntry.csv'
        # NewEmployee_SingleEntry.csv format
        # GivenName,Initials,SurName,Telephone,BLDG,ROOM,RU,Title,Manager,IsFederal
        # First,M,Last,701-239-5555,BRL,154,OCD,MyTitle,My.Manager,N

		Switch ($NewEmployee.RU) {
			ANS  { $Department = "Animal Metabolism Agricultural Chemicals"; $OUPath = 'ANS'; $GRP = 'Animals'}
			CER  { $Department = "Cereal Crops Research"; $OUPath = 'CER'; $GRP = 'Cereals'}
			IGB  { $Department = "Insect Genetics and Biochemistry Research"; $OUPath = 'IGB'; $GRP = 'Insects'}
			OCD  { $Department = "Office of Center Director"; $OUPath = 'OCD'; $GRP = 'OCD'}
			SPB  { $Department = "Sunflower and Plant Biology Research"; $OUPath = 'SPB'; $GRP = 'SUNFLOWER-PLANT-BIOLOGY'}
			SUG  { $Department = "Sugarbeet and Potato Research"; $OUPath = 'SUG'; $GRP = 'Potatoes'}
		} #end $RU Switch
		
		$GivenName = (Get-Culture).TextInfo.ToTitleCase($NewEmployee.GivenName.ToLower()) #General: First name
		$Initials = $NewEmployee.Initials.ToUpper() #General: Initials
		$Surname = (Get-Culture).TextInfo.ToTitleCase($NewEmployee.SurName.ToLower()) #General: Last name
		$Global:sAMAccountName = "{0}.{1}" -f $GivenName, $Surname
		$LogonName = "{0}@usda.net" -f $sAMAccountName #General: Logon Name
		$LogonNamePre2000 = "USDA\{0}" -f $sAMAccountName #General: Logon Name Pre-Windows 2000
		$FullName = "{0}, {1} - ARS" -f $Surname, $GivenName #General: Full name
        #displayName - <sn>+, +<givenName>+ - ARS
		$DisplayName = $FullName #General: Display name
		$Description = $NewEmployee.Title #General: Description
		$BLDG = $NewEmployee.BLDG
		$ROOM = $NewEmployee.ROOM
		$Office = "{0} {1}" -f $BLDG, $ROOM #General: Office
		$TelephoneNumber = $NewEmployee.Telephone #General: Telephone number
		$Email = "{0}@ARS.USDA.GOV" -f $sAMAccountName #General: E-mail
		$Container = "OU=Users,OU={0},OU=Units,OU=3060,OU=PA,OU=ARS,OU=Agencies,DC=usda,DC=net" -f $OUPath #General: Select Container
        $Company = 'Agricultural Research Service'
		$Manager = $NewEmployee.Manager #sAMAccountName of first-line supervisor
		$NASDrive = "10.170.180.2"
		$Title = $NewEmployee.Title #This the REE spelling of the title
		
		#region Set-ADUser -Add array
		$proxyAddressesSMTPARS = "SMTP:{0}@ARS.USDA.GOV" -f $sAMAccountName
		$proxyAddressessmtpMGD = "smtp:{0}-ARS@MGD.USDA.GOV" -f $sAMAccountName
		$targetAddressSMTPMGD = "SMTP:{0}-ARS@MGD.USDA.GOV" -f $sAMAccountName
        #mailNickname - <sn>+,+<givenName>+- ARS  (Same as cn, but no spaces)
		$mailNickName = "{0}-ARS" -f $sAMAccountName
		$EmailAddress = "{0}@ARS.USDA.GOV" -f $sAMAccountName
		$AmerilertPrimaryGroup = 'ND, Fargo' #Amerilert Primary Group
		#endregion Set-ADUser -Add array
		
        $NetworkResourcesGroup = "ARSGNDFAR-{0}-GROUP-ALL" -f $OUPath
        $EmailDistributionListRU = "ARS-PA-3060-{0}" -f $GRP
        $EmailDistributionListBLDG = "ARS-PA-3060-{0}" -f $BLDG
        
        $ImportedPW = Import-Csv 'C:\Users\grant.harrington\Documents\GitHub\Powershell\EAD\ADUC\USER\DefaultPassword.csv'
		$DefaultPassword = ConvertTo-SecureString -string $ImportedPW.DefaultPassword -AsPlainText -force
	} #end BEGIN
	
	PROCESS {
		
		$NewADUserparams = @{
			
			#GUI Tab: GENERAL
			'GivenName' = $GivenName;
			'Initials' = $Initials;
			'Surname' = $Surname;
			'Name' = $DisplayName;
			'Description' = $Description;
			'DisplayName' = "{0}, {1} - ARS" -f $Surname, $GivenName;
			'Office' = "{0} {1}" -f $BLDG, $ROOM;
			'OfficePhone' = $OfficePhone;
			'Email' = "{0}@ars.usda.gov" -f $sAMAccountName;
			
			#GUI Tab: Address
			
			#GUI Tab: Account
			'UserPrincipalName' = "$sAMAccountName@usda.net";
			'SamAccountName' = $sAMAccountName;
			
			#GUI Tab: PROFILE
			'HomeDrive' = "X:"
			'HomeDirectory' = "\\{0}\USERS\{1}" -f $NASDrive, $sAMAccountName;
			
			#GUI Tab: ORGANIZATION
			'Title' = $Title; #Job Title
			'Department' = $Department; #Department
			'Company' = $Company; #Company
            'Manager' = $Manager; #Manager
			
			#Account Settings
			'ChangePasswordAtLogon' = $TRUE;
			'Enabled' = $TRUE;
			'AccountPassword' = $DefaultPassword;
			'Path' = $Container
		} #end NewADUserparams
		
		$SetADUserparams = @{
			
			#GUI Tab: Exchange
            #proxyAddresses - SMTP:<samAccountName@ARS.USDA.GOV, smtp:<samAccountName-ARS@MGD.USDA.GOV
			proxyaddresses = $proxyAddressesSMTPARS, $proxyAddressessmtpMGD;
            #targetAddress – SMTP:<samAccountName>-ARS@MGD.USDA.GOV			
            targetAddress = $targetAddressSMTPMGD;
            #mailNickname - <sn>+,+<givenName>+- ARS  (Same as cn, but no spaces)		
        	mailNickname = $mailNickName;
            #extensionAttribute3 - ARS
            extensionAttribute3 = 'ARS';
            #extensionAttribute12 - MBX=50GB\;TYPE=EP2D\;PA=1;
			extensionAttribute12 = 'MBX=50GB;TYPE=EP2D;PA=1';
            #extentionAttribute13 – 3
			extensionAttribute13 = '3';
			o = $AmerilertPrimaryGroup;
		} #end SetADUserparams		
		
		$ReviewNewADUserObj = New-Object –TypeName PSObject –Prop $NewADUserparams
		$ReviewSetADUserObj = New-Object –TypeName PSObject –Prop $SetADUserparams
		
		Switch ($PRODUCTION) {
			LIVE {
				New-ADUser @NewADUserParams
				Set-ADUser -Identity $sAMAccountName -Add $SetADUserparams -Replace @{ extensionAttribute1 = 'RSA SecurID' }
                #Step 02 - Add User to Location specific SecurityGroup

                $SamAccountName | Add-ADPrincipalGroupMembership -MemberOf $NetworkResourcesGroup
                $SamAccountName | Add-ADPrincipalGroupMembership -MemberOf $EmailDistributionListRU
                $SamAccountName | Add-ADPrincipalGroupMembership -MemberOf $EmailDistributionListBLDG
                if ($NewEmployee.IsFederal -eq 'Y') {
                $SamAccountName | Add-ADPrincipalGroupMembership -MemberOf 'ARS-PA-3060-FEDERAL'
                } else {
                $SamAccountName | Add-ADPrincipalGroupMembership -MemberOf 'ARS-PA-3060-ALL'
                }

			} #end LIVE
			REVIEW {
				Write-Output $ReviewNewADUserObj
				write-output $ReviewSetADUserObj
                Write-Output "Security Group: $NetworkResourcesGroup"
                Write-Output "Email Distribution Group: $EmailDistributionListRU"
                Write-Output "Email Distribution Group: $EmailDistributionListBLDG"
                                if ($NewEmployee.IsFederal -eq 'Y') {
                Write-Output "Email Distribution Group: ARS-PA-3060-FEDERAL"
                } else {
                Write-Output "Email Distribution Group: ARS-PA-3060-ALL"
                }
                
			} #end REVIEW
		} #end Switch-Production
		
	} #end PROCESS
	
	END {
		
		
	} #end END
	
} #end New-LocalADUser

$OpenCSV = Read-Host "Do you need to update the Employee input worksheet?"
if ($OpenCSV -eq 'Y') {
ii 'C:\Users\grant.harrington\Documents\GitHub\Powershell\EAD\ADUC\USER\NewEmployee_SingleEntry.csv'
}

<#
mail                                 : Willie.Wonka@ARS.USDA.GOV
mailNickname                         : Willie.Wonka-ARS 
proxyAddresses                       : {SMTP:Willie.Wonka@ARS.USDA.GOV, smtp:Willie.Wonka-ARS@MGD.USDA.GOV} 
targetAddress                        : SMTP:Willie.Wonka-ARS@MGD.USDA.GOV 
#>

<#
161012_1318 From Rob Butler
                givenName – First name of user (ARS permits use of customer’s preferred name, regardless of first/middle) (Initial Case)
                initials – Middle initial of user
                sn – Last name of user (Initial Case)
                samAccountName - <givenName>+.+<sn>    (<= 20 characters.  Truncate givenName as necessary. No spaces or special characters beyond periods are permitted.  See resolving name collisions below)
                userPrincipalname - <samAccountName>@USDA.NET   (12001000xxxxxx@FEDIDCARD.GOV permitted if already known)
                cn - <sn>+, +<givenName>+ - ARS
mail - <samAccountName>@ARS.USDA.GOV
targetAddress – SMTP:<samAccountName>-ARS@MGD.USDA.GOV
proxyAddresses -            SMTP:<samAccountName@ARS.USDA.GOV
smtp:<samAccountName-ARS@MGD.USDA.GOV
mailNickname - <sn>+,+<givenName>+- ARS  (Same as cn, but no spaces)
#displayName - <sn>+, +<givenName>+ - ARS
extensionAttribute3 - ARS
extensionAttribute12 - MBX=50GB\;TYPE=EP2D\;PA=1;
extentionAttribute13 – 3
o – Amerilert Primary Group  (This is a requirement which you’ll receive notice on next week.)

For naming collisions, first add middle initial to reach uniqueness.  If still not unique, add sequential numbers (1,2,3…) at end of samAccountName until unique name is found.
#>