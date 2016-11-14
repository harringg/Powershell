function Get-PA3060DhcpServerv4Lease {
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
		    NAME: Get-PA3060DhcpServerv4Lease
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 2/11/2016 7:48 PM
			LASTEDIT: 2/11/2016 7:48 PM
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
		[ValidateSet('REVIEW', 'LIVE')]
		[string]$PRODUCTION = 'REVIEW'
	)
	
	BEGIN {
		$Date = Get-Date -format yyMMdd
        $ImportedDHCP = Import-Csv 'C:\Users\grant.harrington\Documents\GitHub\Powershell\DHCP\PA3060DHCP.csv'
        
        # CSV Format
        # DHCPServer,BRLScope,NCSLScope
        # ARSNDFAR3xxx,xx.xxx.x.x,xx.xxx.x.x

	} #end BEGIN
	
	PROCESS {
		
		
		Switch ($PRODUCTION) {
			LIVE {
            $BRLDHCP = Get-DhcpServerv4Lease -ComputerName $ImportedDHCP.DHCPServer -ScopeId $ImportedDHCP.BRLScope | where {$_.HostName -notlike "ARSND*"} 
            $NCSLDHCP = Get-DhcpServerv4Lease -ComputerName $ImportedDHCP.DHCPServer -ScopeId $ImportedDHCP.NCSLScope | where {$_.HostName -notlike "ARSND*"}

            if ($BRLDHCP -or $NCSLDHCP ) {
                    $BRLDHCP | Sort HostName | Select IpAddress,ClientID,HostName,LeaseExpiryTime | ft -AutoSize
                    $NCSLDHCP | Sort HostName | Select IpAddress,ClientID,HostName,LeaseExpiryTime| ft -AutoSize
                } else {
                Write-Host "There are no DHCP entries for non-ARS Computers"
                }
            
			} # end LIVE
			REVIEW {
			} #end REVIEW
		} #end Switch-Production
		
	} #end PROCESS
	
	END {
		
	} #end END
} #end Get-PA3060DhcpServerv4Lease

Get-PA3060DhcpServerv4Lease -PRODUCTION LIVE