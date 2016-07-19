# [Modified, 7/18/2016 3:08 PM, Grant Harrington]
# [Modified, 7/18/2016 4:06 PM, Grant Harrington]
# Modifed from source: https://gallery.technet.microsoft.com/Get-GPO-informations-b02e0fdf#content

Function Get-GPOInfo {
 <# 
.SYNOPSIS 
    This function retrieves some informations about all the GPO's in a given domain. 
.DESCRIPTION 
    This function uses the GroupPolicy module to generate an XML report, parse it, analyse it, and put all the useful informations in a custom object. 
.PARAMETER DomainName 
    You can choose the domain to analyse. 
    Defaulted to current domain. 
.EXAMPLE 
    Get-GPOInfo -Verbose | Out-GridView -Title "GPO Report" 
 
    Display a nice table with all GPO's and their informations. 
.EXAMPLE 
    Get-GPOInfo | ? {$_.HasComputerSettings -and $_.HasUserSettings} 
 
    GPO with both settings. 
.EXAMPLE 
    Get-GPOInfo | ? {$_.HasComputerSettings -and ($_.ComputerEnabled -eq $false)} 
 
    GPO with computer settings configured, but disabled. 
.EXAMPLE 
    Get-GPOInfo | ? {$_.HasUserSettings -and ($_.UserEnabled -eq $false)} 
 
    GPO with user settings configured, but disabled. 
.EXAMPLE 
    Get-GPOInfo | ? {$_.ComputerSettings -eq 'NeverModified' -and $_.UserSettings -eq 'NeverModified'} 
 
    Never modified GPO. 
.EXAMPLE 
    Get-GPOInfo | ? {$_.LinksTO -eq $null} 
 
    Unlinked GPO. 
.EXAMPLE 
    Get-GPOInfo -DomainName Contoso.com 
         
    Query an other domain. 
.EXAMPLE 
    Get-GPOInfo | Select-Object Name -ExpandProperty ACLs | Out-GridView 
     
    Export the GPO's ACL's. 
.INPUTS 
.OUTPUTS 
.NOTES 
.LINK 
    Http://ItForDummies.net 
#>	
	[cmdletbinding()]
	Param (
		[Parameter(Mandatory = $false)]
		[ValidateScript({ Test-Connection $_ -Count 1 -Quiet })]
		[String]$DomainName = $env:USERDNSDOMAIN
	)
	
	Begin {
		Write-Verbose -Message "Importing Group Policy module..."
		try { Import-Module -Name GroupPolicy -Verbose:$false -ErrorAction stop }
		catch { Write-Warning -Message "Failed to import GroupPolicy module"; continue }
		$GPOName = $RSGPOAll | where { $_.Displayname -like "*SPB*" }
	}
	Process {
		$GPOPermissions_Array = @()
		$GPOInfo_Array = @()
		ForEach ($GetGPOName in $GPOName) {
			ForEach ($GPO in (Get-GPO -ID "$($GetGPOName.Id)" -Domain $DomainName)) {
				$GPOPermissions_Array = @()
				$GPOInfo_Array = @()
				
				Write-Verbose -Message "Processing $($GPO.DisplayName)..."
				[xml]$XmlGPReport = $GPO.generatereport('xml')
				#GPO version 
				if ($XmlGPReport.GPO.Computer.VersionDirectory -eq 0 -and $XmlGPReport.GPO.Computer.VersionSysvol -eq 0) { $ComputerSettings = "NeverModified" }
				else { $ComputerSettings = "Modified" }
				if ($XmlGPReport.GPO.User.VersionDirectory -eq 0 -and $XmlGPReport.GPO.User.VersionSysvol -eq 0) { $UserSettings = "NeverModified" }
				else { $UserSettings = "Modified" }
				#GPO content 
				if ($XmlGPReport.GPO.User.ExtensionData -eq $null) { $UserSettingsConfigured = $false }
				else { $UserSettingsConfigured = $true }
				if ($XmlGPReport.GPO.Computer.ExtensionData -eq $null) { $ComputerSettingsConfigured = $false }
				else { $ComputerSettingsConfigured = $true }
				#Output
				
				
				
				
				$GPOInfoProperties = [ORDERED] @{
					'LinksTO' = ($XmlGPReport.GPO.LinksTo | Select-Object -ExpandProperty SOMPath) -join ','
					'Name' = $XmlGPReport.GPO.Name
					'ComputerSettings' = $ComputerSettings
					'UserSettings' = $UserSettings
					'UserEnabled' = $XmlGPReport.GPO.User.Enabled
					'ComputerEnabled' = $XmlGPReport.GPO.Computer.Enabled
					'SDDL' = $XmlGPReport.GPO.SecurityDescriptor.SDDL.'#text'
					'HasComputerSettings' = $ComputerSettingsConfigured
					'HasUserSettings' = $UserSettingsConfigured
					'CreationTime' = $GPO.CreationTime
					'ModificationTime' = $GPO.ModificationTime
					'GpoStatus' = $GPO.GpoStatus
					'GUID' = $GPO.Id
					'WMIFilter' = $GPO.WmiFilter.name, $GPO.WmiFilter.Description
					'Path' = $GPO.Path
					'Id' = $GPO.Id
					'Description' = $GPO.Description
					'ACLs' = ($XmlGPReport.gpo.SecurityDescriptor.Permissions.TrusteePermissions |
					# This is creating the data for the ACLs output
					ForEach-Object - Process {
						
						
						$GPOPermissionsProperties = [ORDERED] @{
							'User' = $_.trustee.name.'#Text'
							'PermissionType' = $_.type.PermissionType
							'Inherited' = $_.Inherited
							'Permissions' = $_.Standard.GPOGroupedAccessEnum
						} #end New-Object ACLs
						
						
						$GPOPermissions = New-Object -TypeName PSCustomObject -Property $GPOPermissionsProperties
						$GPOPermissions_Array += $GPOPermissions
						
					}) #end ForEach-Object, ACLs
				} #end New-Object All
				
				$GPOInfo = New-Object -TypeName PSCustomObject -Property $GPOInfoProperties
				$GPOInfo_Array += $GPOInfo
				
				$GPOInfo_Array
				$GPOPermissions_Array | ft
				
				$GPOInfo_Array | Out-File "C:\temp\GPOACL.txt" -Append
				$GPOPermissions_Array | Out-File "C:\temp\GPOACL.txt" -Append
			} #end ForEach GPO in Get-GPO...
		} #end ForEach $GetGPOName
	} # End Process
	End { }
}