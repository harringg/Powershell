
cd HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.pdf
get-childitem


    Hive: HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.pdf


Name                           Property                                                                                                                                                                                                  
----                           --------                                                                                                                                                                                                  
OpenWithList                   a       : Acrobat.exe                                                                                                                                                                                     
                               MRUList : ahbgcfed                                                                                                                                                                                        
                               b       : IEXPLORE.EXE                                                                                                                                                                                    
                               c       : firefox.exe                                                                                                                                                                                     
                               d       : Skype.exe                                                                                                                                                                                       
                               e       : student.exe                                                                                                                                                                                     
                               f       : AcroRd32.exe                                                                                                                                                                                    
                               g       : FormDesigner.exe                                                                                                                                                                                
                               h       : HELPMAN.EXE                                                                                                                                                                                     
OpenWithProgids                Acrobat.Document.11  : {}                                                                                                                                                                                 
                               AcroExch.Document.11 : {}                                                                                                                                                                                 
UserChoice                     Progid : Acrobat.Document.11                                                                                                                                                                              
                               Hash   : 4HB/Q7FmX5I=    

                               PS C:\Users\grant.harrington\Documents\SCRIPTS\POSH> cd HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.pdf
get-childitem



    Hive: HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.pdf


Name                           Property                                                                                                                                                                                                  
----                           --------                                                                                                                                                                                                  
OpenWithList                   a       : Acrobat.exe                                                                                                                                                                                     
                               MRUList : a                                                                                                                                                                                               
OpenWithProgids                AcroExch.Document.11 : {}                                                                                                                                                                                 
UserChoice                     Hash   : 1os+xI6ATOg=                                                                                                                                                                                     
                               ProgId : Acrobat.Document.11                 



cd HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html
get-childitem

PS C:\Users\grant.harrington\Documents\SCRIPTS\POSH> cd HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.htm
get-childitem



    Hive: HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.htm


Name                           Property                                                                                                                                                                                                  
----                           --------                                                                                                                                                                                                  
OpenWithList                   a       : iexplore.exe                                                                                                                                                                                    
                               MRUList : ba                                                                                                                                                                                              
                               b       : NOTEPAD.EXE                                                                                                                                                                                     
OpenWithProgids                FirefoxHTML : {}                                                                                                                                                                                          
UserChoice                     Hash   : zQDrQObKMUc=                                                                                                                                                                                     
                               ProgId : IE.AssocFile.HTM                                                                                                                                                                                 



PS HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.htm> 

1. Existing (post-migration) values in .html REGEDIT GUI

cd HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html
get-childitem



    Hive: HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html


Name                           Property                                                                                                                                                                                                  
----                           --------                                                                                                                                                                                                  
OpenWithList                   a       : IEXPLORE.EXE                                                                                                                                                                                    
                               MRUList : aefcdb                                                                                                                                                                                          
                               b       : WINWORD.EXE                                                                                                                                                                                     
                               c       : komodo.exe                                                                                                                                                                                      
                               d       : DrExplain.exe                                                                                                                                                                                   
                               e       : firefox.exe                                                                                                                                                                                     
                               f       : HELPMAN.EXE                                                                                                                                                                                     
OpenWithProgids                htmlfile    : {}                                                                                                                                                                                          
                               FirefoxHTML : {}                                                                                                                                                                                          
UserChoice                     Hash   : qyMNahn6zgw=                                                                                                                                                                                     
                               ProgId : FirefoxHTML                                                                                                                                                                                      



PS HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html> 

2. Delete Registry .html in regedit GUI
3. Logout
4. Login
5. Run POSH script (result below)
PS C:\Users\grant.harrington\Documents\SCRIPTS\POSH> cd HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html
get-childitem


    Hive: HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html


Name                           Property                                                                                                                                                                                                  
----                           --------                                                                                                                                                                                                  
OpenWithList                                                                                                                                                                                                                             
OpenWithProgids                FirefoxHTML : {}                                                                                                                                                                                          



PS HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html> 

6. Launch App and choose IE
7. Re-run POSH Script (results below)
PS HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html> Get-ChildItem


    Hive: HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html


Name                           Property                                                                                                                                                                                                  
----                           --------                                                                                                                                                                                                  
OpenWithList                   a       : iexplore.exe                                                                                                                                                                                    
                               MRUList : a                                                                                                                                                                                               
OpenWithProgids                FirefoxHTML : {}                                                                                                                                                                                          
UserChoice                     Hash   : sLcFB7hckY0=                                                                                                                                                                                     
                               ProgId : IE.AssocFile.HTM                                                                                                                                                                                 



PS HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html> 

8. Build GPO with these settings and apply once to other WIN 8.1 PCs