takeown /?

$ParentDirectory = 'C:\Users'
$ChildDirectory = 'first.last'
$FilenameOrDirectory = '/f'
$Recurse = '/r'
$GiveOwnershipToAdministrators = '/a'
$DefaultAnswer = '/d'
$TakeOwnership = 'y'
$Skip = 'n'
Push-Location
cd $ParentDirectory

takeown $FilenameOrDirectory $ChildDirectory $Recurse $GiveOwnershipToAdministrators $DefaultAnswer $TakeOwnership

takeown /f $ChildDirectory /r /a /d y
