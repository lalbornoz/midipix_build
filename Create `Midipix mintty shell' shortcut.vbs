Set WshShell = CreateObject("WScript.Shell")
LinkPath = WshShell.CurrentDirectory + "\Midipix mintty shell.lnk"
If WScript.Arguments.Count = 0 Then
	MinttyPath = "C:\cygwin64\bin\mintty.exe"
Else
	MinttyPath = WScript.Arguments(0)
End If

Set fso = CreateObject("Scripting.FileSystemObject")
If not (fso.FileExists(LinkPath)) Then
	Set oMyShortCut = WshShell.CreateShortcut(LinkPath)
	oMyShortCut.WindowStyle = 4
	oMyShortcut.IconLocation = MinttyPath
	oMyShortCut.TargetPath = MinttyPath
	oMyShortCut.Arguments = "-i /Cygwin-Terminal.ico -e sh midipix.sh"
	oMyShortCut.WorkingDirectory = WshShell.CurrentDirectory
	oMyShortCut.Save
End If
