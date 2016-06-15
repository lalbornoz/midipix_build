Set WshShell = CreateObject("WScript.Shell")
If WScript.Arguments.Count = 0 Then
	CygwinPath = "C:\cygwin64"
Else
	CygwinPath = WScript.Arguments(0)
End If
Set fso = CreateObject("Scripting.FileSystemObject")
Set oMyShortCut = WshShell.CreateShortcut(WshShell.CurrentDirectory + "\Midipix shell.lnk")
oMyShortCut.Arguments = "midipix.sh"
oMyShortcut.IconLocation = CygwinPath + "\Cygwin-Terminal.ico"
oMyShortCut.TargetPath = CygwinPath + "\bin\sh.exe"
oMyShortCut.WindowStyle = 4
oMyShortCut.WorkingDirectory = WshShell.CurrentDirectory
oMyShortCut.Save
