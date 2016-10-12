function Create-Password
{
	<#
	.SYNOPSIS
        Usage:

        The Size parameter defines the length of the password.
        The CharSets parameter define the complexity where the character U, L, N and S stands for Uppercase, Lowercase, Numerals and Symbols. If supplied in lowercase (u, l, n or s) the returned string might contain any of character in the concerned character set, If supplied in uppercase (U, L, N or S) the returned string will contain at least one of the characters in the concerned character set.
        The Exclude parameter lets you exclude specific characters that might e.g. lead to confusion like an alphanumeric O and a numeric 0 (zero).

	.DESCRIPTION


	
	.PARAMETER param1
		param1 Description
	
	.EXAMPLE

        To create a password with a length of 8 characters that might contain any uppercase characters, lowercase characters and numbers:

        Create-Password 8 uln

        To create a password with a length of 12 characters that that contains at least one uppercase character, one lowercase character, one number and one symbol and does not contain the characters OLIoli01:

        Create-Password 12 ULNS "OLIoli01"
	
	.NOTES
		    NAME: Create-Password
            AUTHOR: Grant Harrington
            EMAIL: grant.harrington@ars.usda.gov
            CREATED: 10/12/2016 3:49 PM
			LASTEDIT: 10/12/2016 3:49 PM
            KEYWORDS:
	.LINK
        [Modified, 10/12/2016 3:58 PM, Grant Harrington]
        Source Script:
		http://stackoverflow.com/questions/37256154/powershell-password-generator-how-to-always-include-number-in-string
#>
	[CmdletBinding(SupportsPaging = $true,
				   SupportsShouldProcess = $true)]
	[OutputType([array])]
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidateSet("12", "18", "24")]
        [Int]$Size = 12,
		[Parameter(Mandatory = $true)]
        [Char[]]$CharSets = "ULNS",
        [Char[]]$Exclude
	)
	
	BEGIN
	{
		
	} #end BEGIN
	
	PROCESS
	{
		$Chars = @(); $TokenSet = @()
    If (!$TokenSets) {$Global:TokenSets = @{
        U = [Char[]]'ABCDEFGHIJKLMNOPQRSTUVWXYZ'                                #Upper case
        L = [Char[]]'abcdefghijklmnopqrstuvwxyz'                                #Lower case
        N = [Char[]]'0123456789'                                                #Numerals
        S = [Char[]]'!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~'                         #Symbols
    }}
    $CharSets | ForEach {
        $Tokens = $TokenSets."$_" | ForEach {If ($Exclude -cNotContains $_) {$_}}
        If ($Tokens) {
            $TokensSet += $Tokens
            If ($_ -cle [Char]"Z") {$Chars += $Tokens | Get-Random}             #Character sets defined in upper case are mandatory
        }
    }
    While ($Chars.Count -lt $Size) {$Chars += $TokensSet | Get-Random}
       ($Chars | Sort-Object {Get-Random}) -Join ""                                #Mix the (mandatory) characters and output string
	} #end PROCESS
	
	END
	{
		
	} #end END
} #end Create-Password
$Global:RandomPassword = Create-Password -Size 12 -CharSets ULNS