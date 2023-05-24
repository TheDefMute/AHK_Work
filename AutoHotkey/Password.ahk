SendMode "Input" ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
#NoTrayIcon
#SingleInstance force  ; Ensures that only the last executed instance of script is running

#Include Lib\Lib_Globals.ahk
#Include Lib\Lib_BaseFunctions.ahk
;--------------------------------------------
;| Password Sender AHK script
;--------------------------------------------
;|
;|   - Next time you log on, a dialog box will pop up prompting for the password, enter it in, and ok.
;| To Use:
;|   - Use CapsLock + P to just send the raw Password
;|   - Use CapsLock + L to send your UserName, {Tab}, and the Password for login boxes.
;--------------------------------------------
 
 ;Set default password used for e-services
GLOBAL mstrDefaultPassword := "Test123"
GLOBAL mstrPassword := mstrDefaultPassword
; #################################################################################################
 
;* Autohotkey Settings *
;--------------------------------------------

CapsLock & s:: ;Set Password
{
	KeyWait "Capslock"
	Password := InputBox("Enter a Password","Debugging password","Password",mstrDefaultPassword)
	if Password.Result = "OK"
	{
		GLOBAL mstrPassword := Password.Value
	}

}


CapsLock & p:: ;Get Password
{
    KeyWait "Capslock"
	BaseFunctions.SimpleSend(mstrPassword)

 }
 
CapsLock & U:: ;Send username
{
	strL_UserName := Globals.GetGeneralConfigValue("User","UserName")		
	KeyWait "Capslock"
	SendInput strL_UserName
	SendInput "{Tab}"
}

CapsLock & E:: ;Send Email	
{
	strL_Email := Globals.GetGeneralConfigValue("User","Email")		
	KeyWait "Capslock"
	SendInput strL_Email
	SendInput "{Tab}"
}