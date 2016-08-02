# This will take a list of PCs from the clipboard
# and allow you to quickly create an array from them

$computers = @"
ARSNDFAR573525G
ARSNDFAR541P062
ARSNDFAR5W1JTK1
"@ -split '\r\n'

$computers.Length
3 # 3 objects

$c1 = @"
ARSNDFAR573525G
ARSNDFAR541P062
ARSNDFAR5W1JTK1
"@

$c1.Length
49 # 15x3 char, + @,@,","

$computers = @"
ARSNDFAR573525G   
ARSNDFAR541P062
ARSNDFAR5W1JTK1
"@ -split '\r'

$computers.Length
3 # 3 objects

$computers = @"
ARSNDFAR573525G   
ARSNDFAR541P062
ARSNDFAR5W1JTK1
"@ -split '\n'

$computers.Length
3 # 3 objects

$Fruits = "Apple","Pear","Banana","Orange"

$Fruits.GetType()

$Fruits.Add("Kiwi")
$Fruits.Remove("Apple")
$Fruits.IsFixedSize

[System.Collections.ArrayList]$ArrayList = $Fruits
$ArrayList.GetType()

$ArrayList.Add("Kiwi")
$ArrayList
$ArrayList.Remove("Apple")
$ArrayList

$New = $Fruits += "Kiwi"
$New
$New.GetType()

$New2 = $Fruits -= "Apple"

$New3 = $Fruits -ne "Apple"
$New3

$Collection = {$Fruits}.Invoke()
$Collection
$Collection.GetType()

$Collection.Add("Melon")
$Collection
$Collection.Remove("Apple")
$Collection

$Machines = 'item01','item02'
[System.Collections.ArrayList]$Target= @()
$Collections = {$Target}.Invoke()

foreach ($Machine in $Machines)
{
$Machine += $Target
}