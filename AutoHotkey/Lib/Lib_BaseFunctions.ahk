;SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

ClipboardSaved := ""
Global lngDefault_SleepTime := 50

Class BaseFunctions
{
	
	static SimpleSend(pstrString)
	{
		BaseFunctions.Clipboard_Save(pstrString)
		SendInput "^v"
		BaseFunctions.ClipBoard_Restore()
	}

	Static Clipboard_Save(var:="") ;Save clipboard information for later use.
	{
		IF(ClipboardAll().Size != 0)
		{
			;This has an issue if the clipboard is ever starting from blank.
			Global ClipboardSaved := ClipboardAll()
			A_Clipboard := ""
		}
		Else
		{
			;hacky way to get clipboard init
			Send "^c"
			Clipwait
		}
		if (var != "" )
		{
			A_Clipboard := var

			ClipWait
		}
	}

	Static ClipBoard_Restore() ;restores clipboard information because it is now later.
	{
		BaseFunctions.PasteWait()
		A_Clipboard := ""
		IF (ClipboardSaved != "")
		{
			A_Clipboard := ClipboardSaved
			Clipwait
		}
	}

	static PasteWait(lngTimeOut:=200)
	{
		;msgbox % "Checking"
		lngStartTick := A_TickCount
		while !dllCall("user32\GetOpenClipboardWindow","Ptr")
		{
			IF(A_TickCount - lngStartTick) >lngTimeOut
			{
				;msgbox % "Breaking"
				Break
			}
			;msgbox % "Sleeping"
			Sleep lngDefault_SleepTime
		}
	}

	; Static WinWait_Base(pstrTitle,pintDesktop:=0)
	; {
		; WinWait pstrTitle, , 60
		; if ErrorLevel
		; {
			; MsgBox "WinWait timed out."
			; return
		; }
		; else
			; IF (pintDesktop=10)
			; {
				; WinActivate
				; Send "{Enter}"
			; }
			; else if (pintDesktop>0)
			; {
				; WinActivate
				; Globals.SwitchDesktop(pintDesktop)
			; }
			; Else
				; WinMinimize 
		
		; RETURN
	; }	

	; ; Can only be used if VirtuaWin is installed.
	; Static SwitchDesktop(pintDesktop)
	; {
		; ;PostMessage, 0x0400 + 10, pintDesktop,,, ahk_class VirtuaWinMainClass
		; PostMessage 1049, 0, pintDesktop,, VirtuaWinMainClass ;send, make negative to follow
		; ;PostMessage, 1034, 4, 0,, VirtuaWinMainClass ;switch
		; RETURN
	; }

}
