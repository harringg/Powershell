# Place in Help Section Header
	.PARAMETER PRODUCTION
		This is used to review your results before actually running the script
        REVIEW run the script to review results before running live in production enviroment
        Verb-Noun -PRODUCTION REVIEW
        LIVE Will run the script live in production enviroment
        Verb-Noun -PRODUCTION LIVE

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
