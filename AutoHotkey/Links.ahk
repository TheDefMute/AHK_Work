#SingleInstance force  ; Ensures that only the last executed instance of script is running
;SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#NoTrayIcon

#Include Lib\Lib_Links.ahk

; ^+M::	; My Documents
	; Links_My_Documents()
	; RETURN
	
; ^+k::  ; Desktop
	; Links_Desktop()
	; RETURN
	
^+D:: ;Folder - Drop-ins
{
	Links.Drop_Ins()
	
}		
^+O::	;Run clipboard
{
	Links.Clipboard_Run()
	
}
		
^+S:: ;Folder - AHK Scripts
{
	Links.Script_Folder()
	
}
	
^+G:: ;Google something
{
	Links.Google_Something()
	
}
