#Include Lib_Globals.ahk
#Include Lib_BaseFunctions.ahk

Class Links{
	Static My_Documents()
	{
		Run A_MyDocuments
		
	}
		
	Static Desktop()
	{
		Run A_Desktop
		
	}
		
	Static Drop_Ins()
	{
		; _FullPath:="\\Dfaairs-fil-t01\AIRS Project\Drop-In\"
		; _FullPath.=_UserFullname
		; if (FileExist(_FullPath)) {
			; RUN %_FullPath%
		; }
		strFullPath := Globals.GetGeneralConfigValue("Misc","Dropins")
		if (FileExist(strFullPath)) {
			RUN strFullPath
		}
		
	}
			
	Static Clipboard_Run()
	{
		BaseFunctions.ClipboardSaved := ClipboardAll
		SendInput "^c"
		ClipWait
		IF A_Clipboard != ""
		{
			Run A_Clipboard
		}
		A_Clipboard := ClipboardSaved
	}
			
	Static Script_Folder()
	{
		RUN A_ScriptDir
	}
		
	Static Google_Something()
	{
		A_Clipboard := "" ; Empty the clipboard
		SendInput "^c" ;Copy the current text that is highlighted
		ClipWait
		RUN "http://www.google.com/search?q=" A_Clipboard
	}
}