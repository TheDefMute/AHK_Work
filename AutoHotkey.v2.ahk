; IMPORTANT INFO ABOUT GETTING STARTED: Lines that start with a
; semicolon, such as this one, are comments.  They are not executed.

; This script has a special filename and path because it is automatically
; launched when you run the program directly.  Also, any text file whose
; name ends in .ahk is associated with the program, which means that it
; can be launched simply by double-clicking it.  You can have as many .ahk
; files as you want, located in any folder.  You can also run more than
; one .ahk file simultaneously and each will get its own tray icon.

SetWorkingDir A_ScriptDir "\AutoHotkey"  ; Ensures a consistent starting directory.
;SetWorkingDir "C:\Users\DefMute\Documents\AHK_Scripts"
;A_WorkingDir := A_ScriptDir "\AHK_Scripts"
 ;*********************************************
;************ USER SPECIFIC CONFIG ***********
;*********************************************

;msgbox A_WorkingDir
;*********************************************
;*********** GENERIC SCRIPTS *****************
;*** This will load all scripts from the *****
;*** AHK_Folder, but not sub folders *********
;*********************************************
	;Determine version path
	strPathDefault := A_AhkPath
	strPathV1:= "" ; A_ProgramFiles "\AutoHotkey\v1.1.36.02\AutoHotkeyU64.exe"
	strPathV2:= "" ; A_ProgramFiles "\AutoHotkey\" A_LoopFileName "\AutoHotkey64.exe"
	
	;Find all versions of 64bit AHK that we can run and determine which version
	LOOP Files A_ProgramFiles "\AutoHotKey\*Autohotkey*64*.exe", "R"
	{
		;Lets ignore anything that looks like UIA
		if instr(A_LoopFileFullPath,"UIA")=0
		{
			;A little hacky to just look at the first number
			Switch Substr(FileGetVersion(A_LoopFileFullPath),1,1)
			{
				CASE 1:
					strPathV1 := A_LoopFileFullPath
				CASE 2:
					strPathV2 := A_LoopFileFullPath
				Default:
					msgbox "Unknown version found; " FileGetVersion(A_LoopFileFullPath)
			}
		}
	}
	
	
	;Not that we would wait this long, but we could switch to to a switch statement if we get more than 2
	Loop Files A_WorkingDir "\*.ahk"
	{
		if InStr(A_LoopFileFullPath,".v1.",0)>0
		{
			if strPathV1 != ""
			{
				;msgbox "Run V1 " A_LoopFileFullPath
				run strPathV1 " `"" A_LoopFileFullPath "`""
			}
			Else
			{
				msgbox "AHK v 1.* not found. Cannot run " A_LoopFileFullPath
			}
			
		}
		else If InStr(A_LoopFileFullPath,".v2.",0)>0
		{
			;msgbox "Run V2 " A_LoopFileFullPath
			run strPathV2 " `"" A_LoopFileFullPath "`""
		}
		else
		{
			;msgbox "Run default " strPathDefault "`n" A_LoopFileFullPath
			run strPathDefault " `"" A_LoopFileFullPath "`""
		}
	}

	Return


;*********************
;*********************

;*********************************************
;*********** Include SCRIPTS *****************
;*** Currently Include files cannot be *******
;*** dynamically included. *******************
;*********************************************
;This gives us access to the shortcuts in there, but doesn't start their own instance.
;I can't remember why we are doing it this way. But I know we need it.
#Include AutoHotkey\Includes\ShortCuts.ahk

