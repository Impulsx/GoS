dim script, account
set script = wscript.CreateObject("WScript.Shell")

set service = GetObject ("winmgmts:")
For Each Process In Service.InstancesOf("Win32_Process")
    If Process.Name = "RiotClientServices.exe" Then
        MsgBox("League seems to be currently open, plz close it and try again")
        'WScript.Echo "League client running"
        WScript.Quit
    End If
Next


account=InputBox("League of Legends Multiple Account Auto Login Tool v1.1 by Austin56" & vbCrLf & vbCrLf & "Select main or smurf (1 for main, 2 for smurf, 3 for another smurf, pbe for PBE):")
'Wscript.Echo "Print to terminal"
if account = "1"   Then
    Eval(Main)
ElseIf account = "2" Then
    Eval(Alt)
ElseIf account = "3" Then
    Eval(Kiwi)
ElseIf account = "pbe"  Then
    Eval(Pbe)
End if

Function Main()                                                         'Change for main account
    set oExec = script.Exec("C:\League of Legends\LeagueClient.exe")
    Do
        WScript.Sleep 10
    Loop Until oExec.Status = 1
    script.AppActivate "Riot Client"
    WScript.Sleep 5000
    script.sendkeys "Put your username here"
    script.sendkeys "{TAB}"
    script.sendkeys "Put your password here"
    script.sendkeys "{ENTER}"
End Function

Function Alt()                                                          'Change for smurf account
    set oExec = script.Exec("C:\League of Legends\LeagueClient.exe")
    Do
        WScript.Sleep 10
    Loop Until oExec.Status = 1
    script.AppActivate "Riot Client"
    WScript.Sleep 5000
    script.sendkeys "Put your username here"
    script.sendkeys "{TAB}"
    script.sendkeys "Put your password here"
    script.sendkeys "{ENTER}"
End Function

Function Kiwi()                                                         'Change for another smurf account
    set oExec = script.Exec("C:\League of Legends\LeagueClient.exe")
    Do
        WScript.Sleep 100
    Loop Until oExec.Status = 1
    script.AppActivate "Riot Client"
    WScript.Sleep 5000
    script.sendkeys "Put your username here"
    script.sendkeys "{TAB}"
    script.sendkeys "Put your password here"
    script.sendkeys "{ENTER}"
End Function

Function Pbe()                                                          'Change for PBE account
    set oExec = script.Exec("C:\League of Legends\LeagueClient.exe")
    Do
        WScript.Sleep 100
    Loop Until oExec.Status = 1
    script.AppActivate "Riot Client"
    WScript.Sleep 5000
    script.sendkeys "Put your username here"
    script.sendkeys "{TAB}"
    script.sendkeys "Put your password here"
    script.sendkeys "{ENTER}"
End Function

'If you have more accounts, just add more functions and be sure to add more conditions in line 23/24