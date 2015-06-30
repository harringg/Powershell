param
(
	[Parameter(Mandatory = $TRUE)]
	[ValidateSet("Array", "TextFile", "StaticList", "SinglePC")]
	[string]$InputType
)

BEGIN {
	
	$StaticList = 'SOME_PC_NAME'
	
	switch ($InputType) {
		Array { $ArrayToRead = Read-Host "Enter Array"; $GV = Get-Variable -name $ArrayToRead; $PCList = $GV.Value }
		TextFile { $TextFile = Read-Host "Enter Text File path"; $PCList = Get-Content $TextFile }
		StaticList { $PCList = $StaticList }
		SinglePC { $SinglePCToRead = Read-Host "Enter PC Name"; $PCList = $SinglePCToRead }
	} #end switch InputType
