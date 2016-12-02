Item01 - PathTest

#region Item01-Test
if (Item01 -eq true) {
	ScriptContinues - RE: Item01 is True
	Print Results of Item01
	Item02 - RemGroupTest
	#region Item02-Test
	if (Item02 -eq True) {
		ScriptContinues - RE: Item01 and Item02 are True
		Print Results of Item02
		Item03 - AddGroupTest
		#region Item03-Test
		if (Item03 -eq True) {
			ScriptContinue - RE: All Items are True
			Print Results of Item03
		} <#end Item03 if#>
		else {
			ScriptsEnds - RE: Item03 = False
		}<#end Item03 else#>
		#endregion	
	} <#end Item02 if#>
	else {
		ScriptsEnds - RE: Item02 = False
	}<#end Item02 else#>
	#endregion
} <#end Item01 if#>
else {
	ScriptsEnds - RE: Item01 = False
} <#end Item01 else#>
#endregion