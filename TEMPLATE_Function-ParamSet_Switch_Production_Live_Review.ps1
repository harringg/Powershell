# Place in function head
	param
	(
		[Parameter(Mandatory = $TRUE)]
		[ValidateSet('REVIEW', 'LIVE')]
		[string]$PRODUCTION = 'REVIEW'
	)

#Place in PROCESS section

			Switch ($PRODUCTION) {
				LIVE { <# SCRIPT ACTION #> }
				REVIEW { <# SCRIPT REVIEW #> }
				} #end Switch-Production
