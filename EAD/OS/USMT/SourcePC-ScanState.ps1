$ScriptName = SourcePC-ScanState.ps1

#region ScanState USMT
$PCName = $env:COMPUTERNAME
$LoggedInUser = $env:USERNAME

$StorPath = 'C:\User State Migration Tool\{0}_{1}\' -f $PCName,$LoggedInUser
$MigApp = '/i:migapp.xml'
$MigDocs = '/i:migdocs.xml' #Read in this documents configuration file
$MigUser = '/i:miguser.xml' #Read in this user configuration file
$UserExclude = '/ue:*\*' #Exclude Domain\User
$PrimaryUser = 'first.last'
$UserInclude = "/ui:usda\{0}" -f $PrimaryUser #Include Domain\User
$ContinueOnNonFatalErrors = '/c' #Continue on non-fatal errors
$Overwrite = '/o' #Overwrite
$LocalOnly = '/localonly' #exclude the data from removable drives and network drives mapped on the source computer
$All = '/all' #Migrates all of the users on the computer.

& scanstate $StorPath $MigApp $MigDocs $MigUser $UserExclude $UserInclude $LocalOnly $ContinueOnNonFatalErrors $Overwrite
C:\User State Migration Tool\x86\> 

#C:\User State Migration Tool\x86\> scanstate "C:\User State Migration Tool\store\" /i:migapp.xml /i:migdocs.xml /i:miguser.xml /ue:*\* /ui:usda\lucas.brandt /c /o
#endregion

#region Get Profile ID using Registry ProfileList
$FargoSIDPattern = 'S-1-5-21-2670568672'
$USDASIDPattern = 'S-1-5-21-2443529608'

Push-Location #Records the current network path
$ProfileListPath = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
Set-Location $ProfileListPath
$ProfileToRemove = Get-ChildItem -Path $ProfileListPath | % { Get-ItemProperty $_.pspath} | select ProfileImagePath,PSChildName | Where {$_.PSChildName -like "$FargoSIDPattern*"}

Get-ChildItem -Path $ProfileListPath | % { Get-ItemProperty $_.pspath} | select ProfileImagePath,PSChildName | Where {$_.PSChildName -like "$FargoSIDPattern*"}
Pop-Location #Restores the network path recorded in Push-Location

Push-Location #Records the current network path
$ProfileGuidPath = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileGuid'
Set-Location $ProfileGuidPath
Get-ChildItem -Path $ProfileGuidPath | % { Get-ItemProperty $_.pspath} | select SidString,PSChildname | Where {$_.SidString -like "$FargoSIDPattern*"}
Pop-Location #Restores the network path recorded in Push-Location
#endregion

#https://social.technet.microsoft.com/Forums/windowsserver/en-US/73c6ca2b-2f7f-4a35-9895-07eac0de1456/powershell-delete-profiles-from-registry?forum=winserverpowershell

Get-ChildItem ’HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList’ |
    ForEach-Object{
        $profilepath=$_.GetValue('ProfileImagePath')    
        if($profilepath -notmatch 'administrator|Ctx_StreamingSvc|NetworkService|Localservice|systemprofile|grant.harrington'){
            Write-Host "Removing item: $profilepath" -ForegroundColor green
            #Remove-Item $_.PSPath -Whatif
        }else{
            Write-Host "Skipping item:$profilepath" -Fore blue -Back white
	    }
    }

$First = 'Bill'
$Last = 'Kemp'
$LastSixChar = ("$Last"[0..6] -join "").ToLower()     # "Harrington" returns the string 'harring'
$FirstOneChar = ("$First"[0..0] -join "").ToLower()   # "Grant" returns the string 'g'
$ModernProfile = "{0}.{1}" -f $First,$Last
$HistoricProfile = "{0}{1}" -f $LastSixChar,$FirstOneChar

$ModernProfile
$HistoricProfile

$objectpath = "C:\Users\"

Remove-Item -path "$objectpath*" -Exclude Administrator, Default, Public -Confirm

Get-Childitem -path "$objectpath*" | Out-Gridview -Title "REMAINING USER ACCOUNTS ON YOUR COMPUTER"
Get-Childitem -path "$objectpath*" | select FullName

##################### 160923 ################################


$FargoProfilePath = "C:\Users\rs.grant.harrington-"
$ProfileDirectory = $FargoProfilePath -replace [regex]"^C:\\Users\\",''
$FileName = '/f'
$Recurse = '/r'
$GiveOwnershipToAdmins = '/a'
$Prompt = '/d'
$TakeOwnership = 'y' # Y = Take Ownership, N = Skip
Push-Location #Records the current network path
$ProfileRoot = 'C:\Users'
Set-Location $ProfileRoot #Set Session Path to ProfileRoot
# Take Ownership of $ProfileDirectory (required to allow removal of Fargo SID Profile Directory)
# takeown /f "$ProfileDirectory" /r /a /d y
takeown $FileName "$ProfileDirectory" $Recurse $GiveOwnershipToAdmins $Prompt $TakeOwnership
#If errors occur, rerun TakeOwn

Remove-Item -path "$FargoProfilePath" -Force
#If errors (Access Denied) occur, rerun takeown

icacls "CSC-Recovery" /grant "Everyone:(F)" /t /l /q

Remove-Item -path "$RemovePath" -Force

Get-Childitem -path "$objectpath*" | Select * | ft

###
# What this is doing
# Getting
$DetermineDomainProfiles = Get-CimInstance Win32_UserProfile | Select SID, LastUseTime, LocalPath, Loaded | sort SID
($DetermineDomainProfiles | ForEach-Object {
	if (($_.SID -match [regex]"^$FargoSIDPattern.*") -eq $TRUE) {
		
        (($_) | ForEach-Object {
			$global:FargoDomainAccountsAll_Array = @()
			
			$FargoDomainAccountsProperties = [ORDERED]@{
				'LocalPath' = ($_.LocalPath)
				'SID' = ($_.SID)
				
			} #end $FargoDomainAccountsProperties
			
			$FargoDomainAccountsAll = New-Object -TypeName PSCustomObject -Property $FargoDomainAccountsProperties
			$global:FargoDomainAccountsAll_Array += $FargoDomainAccountsAll
			$FargoDomainAccountsAll_Array
		}) -split ','
	} #end if CN=.*\\
	elseif (($_.SID -match [regex]"^$USDASIDPattern.*") -eq $TRUE) {
		($_) | ForEach-Object { $_.LocalPath, $_.SID }
	} #end elseif (CN=|,OU.*$)
} #end foreach-object
) -Split ','###

# What do I want to do?
# Get Name,LastWrite of C:\Users Dirctory
# Remove "Fargo" Profiles
# -Determine by SID and create Fargo or USDA String
# Remove "Extra" (Fargo/USDA) Profiles Folders, helpdesk, non-active users, etc..
# Identify Profiles to be removed in Registry (based on folders removed above)
# Remove Registry values
# -ProfileList
# -ProfieGUID