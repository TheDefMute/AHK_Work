;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;SetTitleMatchMode 2
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
#SingleInstance force  ; Ensures that only the last executed instance of script is running
#NoTrayIcon

#Include Lib\Lib_Globals.ahk

CapsLock & A:: ;Default - Site Address
{
	strT_Address := Globals.GetGeneralConfigValue("Testing","Address")		
	KeyWait "Capslock"
	Send strT_Address
	Return
}		

CapsLock & M:: ;Default - Testing Email
{
	strT_Email := Globals.GetGeneralConfigValue("Testing","Email")		
	KeyWait "Capslock"
	Send strT_Email
	Return
}		
