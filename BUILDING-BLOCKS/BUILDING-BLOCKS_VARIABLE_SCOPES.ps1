Function f1 {
    $Function01 = "Grant"
    $function01
    }

Function f2 {
    $Function01
    f1
    }

Function f3 {
    $script:Function1 = "Created in the Script Scope"
    $Funtion2 = "Created in the scope of the function"
    }
f3
$Function1
$Funtion2

$myVariable = "Defined in the Script Scope"
Function f4 {
    $myVariable = "Defined in the function's Scope"
    Write-Host "The local version of myVariable: $Local:myvariable"
    Write-Host "The script level version of myVariable: $Script:myvariable"
    }

#$myVariable = "Defined in the Script Scope"
#Set-Variable -Name myVariable -Option AllScope
Function f5 {
    $myVariable = "Changed at the Function Level"
    }

#######################################################
$global:MyVar
$script:MyVar
$local:MyVar


Function FunctionScope
{
    ''
    'Changing $MyVar in the local function scope...'
    $local:MyVar = "This is MyVar in the function's local scope."
    'Changing $MyVar in the script scope...'
    $script:MyVar = 'MyVar used to be set by a script. Now set by a function.'
    'Changing $MyVar in the global scope...'
    $global:MyVar = 'MyVar was set in the global scope. Now set by a function.'
    ''
    'Checking $MyVar in each scope...'
    "Local: $local:MyVar"
    "Script: $script:MyVar"
    "Global: $global:MyVar"
    ''
}
''
'Getting current value of $MyVar.'
"MyVar says $MyVar"
''
'Changing $MyVar by script.'
$MyVar = 'I got set by a script!'
"MyVar says $MyVar"

FunctionScope

'Checking $MyVar from script scope before exit.'
"MyVar says $MyVar"
''



###########################

$global:arg1
$global:arg2
$global:arg3

function Cool {
        $global:arg1 = Read-Host "Put value arg1 here"
        $global:arg2 = Read-Host "Put value arg2 here"

        Switch  ($global:arg1) {
                1 {$global:arg3 = "Person01"}
                2 {$global:arg3 = "Person02"}
                3 {$global:arg3 = "Person03"}
        } #end Switch

} #end function cool
cool
# running 'cool' Function takes input for $arg1 and $arg2
# Entering 1,2, or 3 for $arg1 places a value of "Person01', "Person02", or "Person03 into variable $arg3
# Entering anything in $arg2 places that value in $arg2

Start-Job -ScriptBlock {param($param0,$param1)
$i = 1
while ($i -lt 10){
Write-Output "Read $param0"
Write-Output "Read $param1"
$i++}
} -ArgumentList $arg2,$arg3


########
$global:EMP_NAME = 'First01.First01', 'First02.Last02'

foreach ($name in $EMP_NAME) {
start-job -ScriptBlock {param($param0)
write-host "Hello World"
write-host "FindFile $param0"     } -ArgumentList $name <# END START-JOB SCRIPTBLOCK #>
        }


####
# This will allow input for more than one user name and run multiple jobs in parallel
$global:EMP_NAME = 'First01.First01', 'First02.Last02','First01.Last01'
foreach ($FindFile in $EMP_NAME) {

start-job -InitializationScript $FunctionScriptMoveEMPtoSUP -ScriptBlock {param($USER)
            Move-EMPtoSUP -PRODUCTION REVIEW -FileDir TEMP -Employee_Name $USER -Verbose
        } -ArgumentList $FindFile <# END START-JOB SCRIPTBLOCK #>
        } # END foreach
