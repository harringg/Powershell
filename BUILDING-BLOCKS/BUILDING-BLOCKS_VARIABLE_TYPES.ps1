$a = 5
$b = "5"
$b + $a # Answer 55 (both treated as [string] and are concatonated)
$a + $b # Answer 10 (both treated as [int] and are added)

[int]$integer = 5
$integer+1 # Answer 6 (added 5 + 1)

[string]$integer = 5
$integer+1 # Answer 51 (concatonated 5 & 1)