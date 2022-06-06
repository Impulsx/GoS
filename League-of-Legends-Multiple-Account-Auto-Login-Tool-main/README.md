# League of Legends Multiple Account Auto Login Tool
![GitHub](https://img.shields.io/badge/license-MIT-green) ![GitHub](https://img.shields.io/badge/language-VBScript-blue) [![ytlink](https://img.shields.io/youtube/views/EcbEzoVseSI?label=Tutorial%20Video&style=social)](https://www.youtube.com/watch?v=EcbEzoVseSI&ab_channel=Austin56)

Forked from ![austinyen56](https://github.com/austinyen56/League-of-Legends-Multiple-Account-Auto-Login-Tool)

Allows you to quickly login using multiple accounts in League of Legends

## How to use this file
1. Download the vbs file
2. Right click and edit the file
3. At the line ```set oExec = script.Exec("Your League directory\LeagueClient.exe") ``` replace and change it to your directory for LeagueClient.exe  Ex: C:\League of Legends\LeagueClient.exe
4. For lines that have ```script.sendkeys "Put your username here"``` replace it with your username
5. For lines that have ```script.sendkeys "Put your password here"``` replace it with your password
6. If you have additional accounts, change it below as well.
7. Optional: For those who have slower client boot times, change ```WScript.Sleep 10``` to a different value Ex: WScript.Sleep 1000
(Number in milliseconds)

After running the vbs file, you should be able to select which account you want to log into. 
* *PLEASE Don't switch to other programs before auto logging in! It also doesnt account for updates (the ones where update isnt prompted in client). So if the client is updating, try it again or wait for it to finish updating before logging in!* 

* *ALL ACCOUNT DATA ARE STORED LOCALLY AND SENT TO RIOT ONLY*
