:: 2015-04-21 - determination of 32 v 64, pro v enterprise

@echo off
setlocal EnableDelayedExpansion

for /f "tokens=3-4" %%i in ('wmic os get caption /value ^| find "="') do set version=%%i & set flavor=%%j

#CMD: wmic os get caption /value
#POSH: Get-CimInstance Win32_OperatingSystem | select Caption
#RESULT: Microsoft Windows 8.1 Pro

SET UNATTENDSOURCE=w%version:~0,1%%flavor:~0,1%_%processor_architecture%_Kimberly_unattend.xml
$UNATTENDSOURCE "w%version:~0,1%%flavor:~0,1%_%processor_architecture%_Kimberly_unattend.xml"

SET UNATTENDTARGET=unattend.xml

#CMD: SET UNATTENDTARGET=unattend.xml
#POSH: $UNATTENDTARGET = 'unattend.xml'

SET FQFN=%~d0%~p0%UNATTENDSOURCE%
SET SYSPREP=%windir%\system32\sysprep

if exist %SYSPREP%\%UNATTENDTARGET% del /f %SYSPREP%\%UNATTENDTARGET% 
cls

echo ***Copy***
echo from: %UNATTENDSOURCE%
echo to:   %SYSPREP%\%UNATTENDTARGET% 
copy %FQFN% %SYSPREP%\%UNATTENDTARGET% || echo FAILED TO COPY 'unattend.xml' - Aborting && pause && goto :EOF
if not exist %SYSPREP%\%UNATTENDTARGET% (
	echo Very strange - copy worked, but the file's not here! 
	goto :EOF
)

echo. 
echo This box will be SYSPREPPED to ANY hardware and placed in OOBE MODE
echo This is your only chance to abort - press CTRL-C to abort!
echo.
pause

cd /d %SYSPREP%
sysprep /generalize /oobe /shutdown /unattend:%SYSPREP%\%UNATTENDTARGET%

pause
