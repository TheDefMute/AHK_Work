#Requires AutoHotkey v2.0
#SingleInstance force  ; Ensures that only the last executed instance of script is running
#NoTrayIcon
	
#Include Lib\Lib_Setup.ahk

#+F1:: ;View/Change General Config ini file
{
	Setup.CreateGui("Setup_General Config.ini","GeneralConfig.ini","General Config")
}