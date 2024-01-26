SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
#SingleInstance force  ; Ensures that only the last executed instance of script is running
#NoTrayIcon

#Include Lib\Lib_Windows (Organize) - Setup.ahk

;Todo: Check if app is there before attempting to Move

!+F1::	;Open Base programs
{
	;get list of items
	strSections := IniRead("Windows (Organize).ini", "ProgramRun_Base")
	loop parse strSections, "`n", "`r"
	{
		astrItems := strsplit(A_LoopField,"=")
		CheckStartProgram(astrItems[2])
	}
	
}

!+F2:: ;Organize windows
{

	lngCount_Monitors:=0
	lngCount_Monitors := sysGet(80) ;80 is the monitor count


	;get list of items
	strSections := IniRead("Windows (Organize).ini", "Monitors_Any")
	if strSections != "" 
	{
		strSections .= "`n"
	}

	strSections .= IniRead("Windows (Organize).ini", "Monitors_" lngCount_Monitors)
	loop parse strSections, "`n", "`r"
	{
		astrItems := strsplit(A_LoopField,"=")
		;msgbox "Title: " GetTitle(astrItems[2]) "`nPos X: " GetPosX(astrItems[2]) "`nPos Y: " GetPosY(astrItems[2]) "`nHeight: " GetHeight(astrItems[2]) "`nWidth: " GetWidth(astrItems[2]) "`nWinMax: " GetWindowMax(astrItems[2])
		;msgbox GetTitle(astrItems[2]) "`n" GetWindowMax(astrItems[2])
		OrganizeWindow(GetTitle(astrItems[2]),GetPosX(astrItems[2]),GetPosY(astrItems[2]),GetWidth(astrItems[2]),GetHeight(astrItems[2]),GetWindowMax(astrItems[2]))
	}
	
	Reload
}

!+F3:: ;Get Count of monitors
{
	lngCount_Monitors:=0
	lngCount_Monitors := sysGet(80) ;80 is the monitor count
	msgbox lngCount_Monitors
	Reload
}

!+F5:: ;Move single window - Usually code
{
	lngCount_Monitors:=0
	lngCount_Monitors := sysGet(80) ;80 is the monitor count

	strTitle := WinGetTitle("A")
	strItem := "CurrentApplication_MonitorCount_" lngCount_Monitors
		
	OrganizeWindow(strTitle,GetPosX(strItem),GetPosY(strItem),GetWidth(strItem),GetHeight(strItem),GetWindowMax(strItem))

}
#+F6::	;Configure windows to be organized
{
	Windows_Organize_Setup.SetupWindowOrganize()
}

CheckStartProgram(pstrProgram,pblnCurrentWindow:=False)
{
	;Determine if we should check if the process exists on any window or just the current window
	IF(pblnCurrentWindow)
	{
		strCheck:= "ahk_exe " pstrProgram
		
		if not winexist(strCheck)
		{
			run pstrProgram
		}

	}
	ELSE
	{
		splitPath pstrProgram, &strFilename
		IF ProcessExist(strFilename)=0
		{
			run pstrProgram
		}


	}
}

	
OrganizeWindow(pstrWinTitle,plngStartX,plngStartY,plngSizeX:=0,plngSizeY:=0,pblnMaxSize:=False)
{
	;msgbox pstrWinTitle "`n" plngStartX "`n" plngStartY "`n" plngSizeX "`n" plngSizeY "`n" pblnMaxSize
	IF WinExist(pstrWinTitle)
	{
		; This is manipulate the window before move
		WinState := WinGetMinMax("A")
		;msgbox pstrWinTitle "`n" WinState
		SWITCH WinState
		{
			CASE -1:
				;Window is Minimized
				;msgbox, Window is Minimized
				WinRestore
			CASE 1:
				;Window is Maximized
				;msgbox, %pstrWinTitle% Window is Maximized
				WinRestore
			DEFAULT:
				;Window is something else
				;msgbox, Window is something else
				WinRestore
		}
		
		
		;msgbox pstrWinTitle "`n" pblnMaxSize
		If (pblnMaxSize)
		{
			WinMove plngStartX,plngStartY
			WinMaximize pstrWinTitle
			;msgbox "Maxxed"
		}
		Else
		{
			WinMove plngStartX,plngStartY,plngSizeX,plngSizeY
			;msgbox "Not Maxed"
		}
	}
	;For the google chrome move we used WinMove a,x,y
}

;**************************************
;*******   INI Functions **************
;**************************************
GetTitle(pstrItem)
{
	return IniRead("Windows (Organize).ini", pstrItem,"Title")
}
GetPosX(pstrItem)
{
	return IniRead("Windows (Organize).ini", pstrItem,"PosX")
}
GetPosY(pstrItem)
{
	return IniRead("Windows (Organize).ini", pstrItem,"PosY")
}
GetHeight(pstrItem)
{
	return IniRead("Windows (Organize).ini", pstrItem,"Height")
}
GetWidth(pstrItem)
{
	return IniRead("Windows (Organize).ini", pstrItem,"Width")
}
GetWindowMax(pstrItem)
{
	
	switch strUpper(Trim(IniRead("Windows (Organize).ini", pstrItem,"WinMax")))
	{
		case "TRUE","1":
			return true
		DEFAULT:
			return false
	}
	;return IniRead("Windows (Organize).ini", pstrItem,"WinMax")
}
