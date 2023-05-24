#SingleInstance force  ; Ensures that only the last executed instance of script is running
;#NoTrayIcon
SetTitleMatchMode(2)
SetWorkingDir A_ScriptDir

;Todo:
;;Add ability to find "HotKey" dynamically configured
;;Check running programs (because missing Shortcuts which is included in base file
;;Issue with screen percent still going outside main screen.

;These can be changed in settings, otherwise these are just defaults
Global mlngFontSize := 10
global mlngVScreenPercent := 90

;These cannot be changed in settings
Global mstrBackColor := "FFFFFF"
Global mstrFont := "Courier New"

;global Variables for tracking only
	global mMapFileList := Map() ;keeps track of all files processed.
	global maMapAllKeys := Map() ;Keep track of all hotkeys to check for dups later on


#F1:: ; Display Help for all AHK files in current folder
{

	;Load global values
	global mlngFontSize := IniRead("Help.ini", "Font", "Size" , mlngFontSize)
	global mlngVScreenPercent := IniRead("Help.ini", "Display", "ScreenPercent" , mlngVScreenPercent)
		
	mMapFileList.Clear() ;Clear these on each load, otherwise help is blank after first run
	maMapAllKeys.Clear() ;Clear these on each load, otherwise help is blank after first run
	
	
	mapHelp := map() ;declare main array to hold all help information
	mapScripts := map()
	
	GetActiveScripts_Location(&mapScripts)    ; Get Path of all AHK Scripts
	for intIndex, mapScript in mapScripts     ; Loop Through AHK Script Files
	{
		ParseFile(A_WorkingDir, mapScript, &mapHelp)
		
	}
	;GetActiveScripts(&nothing) ;used to get running scripts
	
	BuildGUI_Text(mapHelp)
	;We can either have a different screen pop up and/or show "(DUP)" at the start of each entry
	BuildGuiDuplicates(maMapAllKeys)
	
	;Quick debug to see counts of each time a file was attempted to be processed
	; strAllFiles := ""
	; for strFile in mMapFileList
	; {
		; strAllFiles .= strFile " : " mMapFileList[strFile]["Count"] "`n"
	; }
	
	; msgbox strAllFiles
}

;*************
;** METHODS **
;*************
ParseFile(pstrParentDir, pmapFileInfo, &pmapHelp)
{
	if (Trim(pmapFileInfo["Path"])!="") ;No need to look at file if it is just blank
	{
		
		IF !AHKFileExists(pmapFileInfo["Title"])
		{
			;Initialize count of new entries to 0
			pmapHelp[pmapFileInfo["Title"]] := Map("Count", 0)

			;Loop through the file line by line
			astrKeys := map()
			; AttributeString := FileExist(pmapFileInfo["Path"])
			; msgbox "Type: " Type(pmapFileInfo["Path"]) "`nPath: " pmapFileInfo["Path"] "`nWorking Dir: " A_WorkingDir "`nAttribute: " AttributeString
			Loop Read pmapFileInfo["Path"]
			{
				strhotkey := ""
				strcomment := ""
				if (A_LoopReadLine="")
				{
					;blank line, just skip
					continue
				}
				Else
				{
					;msgbox "Path: " pmapFileInfo["Path"] "`nName: " pmapFileInfo["Name"] "`nDir: " pmapFileInfo["Dir"] "`nExt: " pmapFileInfo["Ext"] "`nTitle: " pmapFileInfo["Title"]
					;Evaluate line to see if it contains a hotkey command and a comment
					EvaluateLine(pstrParentDir, A_LoopReadLine, &strhotkey, &strcomment, &pmapHelp)
					if (strhotkey!= "")
					{
					pmapHelp[pmapFileInfo["Title"]]["Count"] += 1
					astrKeys.set(strHotKey,strComment)
					
					TrackAllkeys(pmapFileInfo["Title"],strHotKey)
					}
				}
			}
			;This is where we should set the list of keys to pmapHelp
			pmapHelp[pmapFileInfo["Title"]].set("Keys", astrKeys)
		}
	}
}

EvaluateLine(pstrParentDir, pstrLine, &pstrHotKey, &pstrComment, &pmapHelp)
{
	; Extract the hotkeys and comments
	strHotKey_Matches := ""
	;Simple first check to see if the line even contains the trigger for a hotkey
	if RegExMatch(pstrLine, "::")
	{
		;More complex regex to determine hotkey
		IF Regexmatch(pstrLine, "Umi)^\s*[\Q#!^+<>*~$\E]*((LButton|RButton|MButton|XButton1|XButton2|WheelDown|WheelUp|WheelLeft|WheelRight|CapsLock|Space|Tab|Enter|Return|Escape|Esc|Backspace|BS|ScrollLock|Delete|Del|Insert|Ins|Home|End|PgUp|PgDn|Up|Down|Left|Right|NumLock|Numpad0|Numpad1|Numpad2|Numpad3|Numpad4|Numpad5|Numpad6|Numpad7|Numpad8|Numpad9|NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub|NumpadEnter|NumpadIns|NumpadEnd|NumpadDown|NumpadPgDn|NumpadLeft|NumpadClear|NumpadRight|NumpadHome|NumpadUp|NumpadPgUp|NumpadDel|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|F13|F14|F15|F16|F17|F18|F19|F20|F21|F22|F23|F24|LWin|RWin|Control|Ctrl|Alt|Shift|LControl|LCtrl|RControl|RCtrl|LShift|RShift|LAlt|RAlt|Browser_Back|Browser_Forward|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|AppsKey|PrintScreen|CtrlBreak|Pause|Break|Help|Sleep|sc\d{1,3}|vk\d{1,2}|\S)(?<!;)|```;)(\s+&\s+((LButton|RButton|MButton|XButton1|XButton2|WheelDown|WheelUp|WheelLeft|WheelRight|CapsLock|Space|Tab|Enter|Return|Escape|Esc|Backspace|BS|ScrollLock|Delete|Del|Insert|Ins|Home|End|PgUp|PgDn|Up|Down|Left|Right|NumLock|Numpad0|Numpad1|Numpad2|Numpad3|Numpad4|Numpad5|Numpad6|Numpad7|Numpad8|Numpad9|NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub|NumpadEnter|NumpadIns|NumpadEnd|NumpadDown|NumpadPgDn|NumpadLeft|NumpadClear|NumpadRight|NumpadHome|NumpadUp|NumpadPgUp|NumpadDel|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|F13|F14|F15|F16|F17|F18|F19|F20|F21|F22|F23|F24|LWin|RWin|Control|Ctrl|Alt|Shift|LControl|LCtrl|RControl|RCtrl|LShift|RShift|LAlt|RAlt|Browser_Back|Browser_Forward|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|AppsKey|PrintScreen|CtrlBreak|Pause|Break|Help|Sleep|sc\d{1,3}|vk\d{1,2}|\S)(?<!;)|```;))?(\s+Up)?::",&strHotKey_Matches)
		{
			;We found a match for the hotkey
			pstrHotKey := trim(trim(strHotKey_Matches[0],"::"))

			;Decode hotkey from ^+! to normal people speak
			DecodeHotKey(&pstrHotKey)

			;Look for the comment on the same like
			if RegExMatch(pstrLine, "i);(.+)", &strComment_Match)
			{
				pstrComment := strComment_Match[1]
			}
		}
	}
	else IF RegExMatch(pstrLine, "i)^\s*#Include")
	{
		;this is the check to look at include files to see if there are hotkeys in there

		;We could probably check if the include file we are looking at already has a count, meaning we checked it already
		;msgbox "Parent Dir: " pstrParentDir "`n Path: " pstrParentPath "`nLine: " pstrLine

		;This resets the pstrParentDir to the current file using ParseFilePathName          
		ParseFile(pstrParentDir, ParseFilePathName(&pstrParentDir, pstrLine), &pmapHelp)
		;msgbox pstrLine
	}
	; else if RegExmatch(pstrLine, "i)^\s*hotkey\s+(.*?),(.*?)", &strHotKey_Matches)
	; {
		; ;match dynamically created hotkeys
		; msgbox "0: " strHotKey_Matches[0] "`n1: " strHotKey_Matches[1] "`n2: " strHotKey_Matches[2]
	; }
}
DecodeHotKey(&pstrHotKey)
{
	Set_Hotkey_Mod_Delimiter := "+"     ; Delimiter Character to Display Between Hotkey Modifiers
	
	pstrHotKey := strUpper(pstrHotKey) ;Set keys to upper case for consistency
	
	pstrHotKey := StrReplace(pstrHotKey, "+", "Shift" Set_Hotkey_Mod_Delimiter)
	pstrHotKey := StrReplace(pstrHotKey, "<^>", "AltGr" Set_Hotkey_Mod_Delimiter)
	pstrHotKey := StrReplace(pstrHotKey, "<", "Left", , &All)
	pstrHotKey := StrReplace(pstrHotKey, ">", "Right", , &All)
	pstrHotKey := StrReplace(pstrHotKey, "!", "Alt" Set_Hotkey_Mod_Delimiter)
	pstrHotKey := StrReplace(pstrHotKey, "^", "Ctrl" Set_Hotkey_Mod_Delimiter)
	pstrHotKey := StrReplace(pstrHotKey, "#", "Win" Set_Hotkey_Mod_Delimiter)
}
ParseFilePathName(&pstrParentDir,pstrFilePath)
{
	if RegExMatch(pstrFilePath, "mi`a)^\s*#include(?:again)?(?:\s+|\s*,\s*)(?:\*i[ `t]?)?([^;\v]+[^\s;\v])", &strMatch)     ; Check for #Include
	{

		pstrFilePath := StrReplace(strMatch[1], "A_ScriptDir", A_ScriptDir)
		pstrFilePath := StrReplace(pstrFilePath, "A_AppData", A_AppData)
		pstrFilePath := StrReplace(pstrFilePath, "A_AppDataCommon", A_AppDataCommon)
		
		;Hacky way to remove this from the primary script path
		pstrFilePath := StrReplace(pstrFilePath, "\AHK_Scripts\")
		;pstrFilePath := strReplace(pstrFilePath,"`"") ;remove quotes from path
		pstrFilePath := strReplace(pstrFilePath,chr(34)) ;remove quotes from path
				
	}
	strFile_Path := RegExReplace(pstrFilePath, "^(.ahk).+$", "$1")


	;SplitPath(File_Path, &File_Name, &File_Dir, &File_Ext, &File_Title)

	IF substr(strFile_Path,0,strLen(pstrParentDir))!= pstrParentDir
	{
		;msgbox "does not match`n" "File: " File_Path "`nDir: " pstrParentDir
		if substr(strFile_path,0,1) = "\"
		{
			strFile_Path := pstrParentDir strFile_Path
		}
		Else
		{
			strFile_Path := pstrParentDir "\"  strFile_Path
		}
	}

	SplitPath(strFile_Path, &strFile_Name, &strFile_Dir, &strFile_Ext, &strFile_Title)

	pstrParentDir := strFile_Dir

	arrFileInfo := Map()
	arrFileInfo.set("Path", strFile_Path)
	arrFileInfo.set("Name", strFile_Name)
	arrFileInfo.set("Dir", strFile_Dir)
	arrFileInfo.set("Ext", strFile_Ext)
	arrFileInfo.set("Title", strFile_Title)


	return arrFileInfo
}

;***************************
;** METHODS - Get scripts **
;***************************
;This is if we want to grab only the active programs running
GetActiveScripts(&pmapScripts)
{
	Setting_A_DetectHiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows True
	;DetectHiddenWindows((Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? true : "")
	AHK_Windows := WinGetList(".ahk")
	; msgbox AHK_Windows.Length

	loop ahk_windows.length
	{
		splitPath(wingettitle(ahk_windows[a_index]), &strFile_Name, &strFile_Dir, &strFile_Ext, &strFile_Title)

		IF !AHKFileExists(strFile_Title)
		{
			strtest := "visiting all windows "
			strtest .= a_index
			strtest .= " of "
			strtest .= ahk_windows.length
			strtest .= "`nahk id "
			strtest .= ahk_windows[a_index]
			strtest .= "`nahk_class " wingetclass(ahk_windows[a_index])
			strtest .= "`nthis title " strFile_Title
			msgbox strtest
		}
	}
	; ; AHK_Windows := Array()
	; ; AHK_Windows := AHK_Windows.Length
	; ; For v in oAHK_Windows
	; ; {  
		; ; aAHK_Windows.Push(v)
	; ; }
	; ; pmapScripts := map()
	; Loop AHK_Windows.Length
	; {
		; hWnd := AHK_Windows[A_Index]
		; Win_Name := WinGetTitle("ahk_id " hWnd)


		; strFile_Path := RegExReplace(Win_Name, "^(.*) - AutoHotkey v[0-9\.]+$", "$1")
		; msgbox "Here: " Win_Name "`n" strFile_Path
		; SplitPath(strFile_Path, &strFile_Name, &strFile_Dir, &strFile_Ext, &strFile_Title)

		; pmapScripts[A_Index] := Map()
		; pmapScripts[A_Index].set("Path",strFile_Path)
		; pmapScripts[A_Index].set("Name", strFile_Name)
		; pmapScripts[A_Index].set("Dir", strFile_Dir)
		; pmapScripts[A_Index].set("Ext", strFile_Ext)
		; pmapScripts[A_Index].set("Title", strFile_Title)
		; ;pmapScripts[A_Index,"hWnd"] := hWnd
		; ;list .= strFile_Path "`n"
		; ;msgbox pmapScripts[A_Index]["Path"]
	; }
	DetectHiddenWindows Setting_A_DetectHiddenWindows
}
;This is if we want to grab only the active programs running
GetActiveScripts_Location(&pmapScripts)
{
      
	Loop Files "*.ahk"
	{


		SplitPath(A_LoopFileFullPath, &strFile_Name, &strFile_Dir, &strFile_Ext, &strFile_Title)

		pmapScripts[A_Index] := Map()
		pmapScripts[A_Index].set("Path",A_LoopFileFullPath)
		pmapScripts[A_Index].set("Name", strFile_Name)
		pmapScripts[A_Index].set("Dir", strFile_Dir)
		pmapScripts[A_Index].set("Ext", strFile_Ext)
		pmapScripts[A_Index].set("Title", strFile_Title)

		;msgbox "Path: " pmapScripts[A_Index]["Path"] "`nName: " pmapScripts[A_Index]["Name"] "`nDir: " pmapScripts[A_Index]["Dir"] "`nExt: " pmapScripts[A_Index]["Ext"] "`nTitle: " pmapScripts[A_Index]["Title"] "`n"

	}

}

;**********************************
;** METHODS - Formatting Options **
;**********************************
String_Wings(pstrLine,plngLength:=76,pstrTitleCharacter:="=",pstrCase:="U")
{
	Switch pstrCase
	{
		CASE "U":
			pstrLine := StrUpper(pstrLine)
		CASE "T":
			pstrLine := StrTitle(pstrLine)
		CASE "L":
			pstrLine := StrLower(pstrLine)
		Default:
			msgbox "Undefined case: " pstrCase
	}
	
	lngWingX1 := Round(((plngLength-StrLen(pstrLine))/2)/StrLen(pstrTitleCharacter)-.5)
	lngWingX2 := Round((plngLength-StrLen(pstrLine)-(lngWingX1*StrLen(pstrTitleCharacter)))/StrLen(pstrTitleCharacter)+.5)
	
	Loop lngWingX1
	{
		strWing_1 .= pstrTitleCharacter
	}
	
	Loop lngWingX2
	{
		strWing_2 .= pstrTitleCharacter
	}

	return SubStr(strWing_1 pstrLine strWing_2, 1, plngLength)
}

; Format Spaces Between Hot Keys and Help Info to Create Columns
Format_Line(pstrHot,pstrInfo,plngPos_Info)
{
	pstrSpaces := ""
	lngLength := plngPos_Info - StrLen(pstrHot) - 1
	Loop lngLength
	{
		pstrSpaces .= " "
	}
	return pstrHot pstrSpaces pstrInfo
}

;**************************
;** Methods - Tracking ****
;**************************
AHKFileExists(pstrTitle)
{
	if mMapFileList.has(pstrTitle)
	{
		mMapFileList[pstrTitle]["Count"] += 1
		Return true
	}
	Else
	{
		mMapFileList.set(pstrTitle,Map("Count",1))
		return False
	}
}

TrackAllkeys(pstrTitle,pstrHotKey)
{
	; maMapAllKeys.Set(pstrHotKey,pstrHotKey)
	; maMapAllKeys[pstrHotKey]:= Map("Count",1)
	astrKeys := []
	IF !(maMapAllKeys.has(pstrHotKey))
	{
		maMapAllKeys[pstrHotKey]:= Map("Count",1)
		astrKeys.push(pstrTitle)
		maMapAllKeys[pstrHotKey].set("Files",astrKeys)
	}
	Else
	{
		maMapAllKeys[pstrHotKey]["Count"] +=1
		maMapAllKeys[pstrHotKey]["Files"].push(pstrTitle)
	}
}

;**************************
;** Methods - Gui Things **
;**************************
BuildGUI_Text(pmapHelp)
{

	lngPos_Info := 25 ; spacing from the right to the start of the comment
	strDisplay := "" ;This is the main text that will display on the main screen
	lngRowCount := 0 ;Keep track of how many rows of text.

	;Loop through each "file"
	for strFileTitle, element in pmapHelp
	{
		
		;Skip items with nothing
		if pmapHelp[strFileTitle]["Count"]=0
		{
			  Continue
		}
		
		;Build Header for each section
		if lngRowCount>1
		{
			;this is to avoid the first line being blank
			strDisplay .= "`r`n" 
		}
		strDisplay .= String_Wings(" " strFileTitle " ") "`r`n"
		lngRowCount += 2
		
		;Reset the file section text
		strDisplay_Section := ""
		
		;Loop through each "Key" in the file
		for Hot, Info in pmapHelp[strFileTitle]["Keys"]
		{
			if maMapAllKeys[Hot]["Count"]>1
			{
				strDisplay_Section .= "(DUP) "
			}

			strDisplay_Section .= Format_Line(Hot,Info,lngPos_Info) "`r`n"
			lngRowCount += 1
		}
		
		;Just sort alphabetically by comment
		strDisplay_Section := Sort(strDisplay_Section, "P" lngPos_Info)
		
		;Append section data to main display
		strDisplay .= strDisplay_Section
		;lngRowCount += 1
			  
	}
	  
	if strLen(strDisplay)>0
	{
		;lets just remove the last \r\n
		strDisplay := substr(strDisplay,1,strLen(strDisplay)-2)
	}

	lngMaxRows := CalcRows(mlngFontSize) ;pass in font size
	;Determine height of edit box
	;msgbox "Row Count: " lngRowCount "`nMax Rows: " lngMaxRows
	if lngRowCount > lngMaxRows 
	{
		lngRowCount := lngMaxRows
	}

	myGui := Gui()
	
	
		FileMenu := Menu()
		FileMenu.Add "Se&ttings`tCtrl+T", (*) => OpenSettings() 
		FileMenu.Add "E&xit", (*) => GuiEscape(mygui)
		HelpMenu := Menu()
		HelpMenu.Add "&About", (*) => MsgBox("Contact: defmute+AHK@gmail.com")
		Menus := MenuBar()
		Menus.Add "&File", FileMenu  ; Attach the two submenus that were created above.
		Menus.Add "&Help", HelpMenu
		

		MyGui.MenuBar := Menus
	
	
	myGui.BackColor := mstrBackColor
	myGui.SetFont("s" mlngFontSize, mstrFont)
	myGui.Opt("+MinSize660x100")
	;we want the entire thing to resize
	myGui.AddEdit("ReadOnly +Vscroll r" lngRowCount, strDisplay)
	myGui.onEvent("Escape",GuiEscape)

	myGui.Show("AutoSize")
	Send("^{Home}")
}

GuiEscape(myGui)
{
	myGui.Show("Hide")
}

GetMonitorHeight(&plngDisplaySize)
{
	;Font size specifications may come in points or pixels where:
	;1 pixel (px) is usually assumed to be 1/96th of an inch.
	;1 point (pt) is assumed to be 1/72nd of an inch.
	;Therefore 16px = 12pt
	MonitorGetWorkArea(MonitorGetPrimary(), &lngLeft, &lngTop, &lngRight, &lngBottom)
	plngDisplaySize := (lngBottom - lngTop)
	plngDisplaySize *= (mlngVScreenPercent/100) ;If we want to only use X percent of the screen
}
CalcRows(pintPoint)
{     
	lngPixelPerInch := A_ScreenDPI
	clngPointsPerInch := 72 ;This shouldn't really ever change

	lngRows := (lngPixelPerInch / clngPointsPerInch) * pintPoint

	;Hacky method
	;Need to take into consideration distance between rows, so like 0.5
	lngRows += 0.5 ;spacing between rows
	;end hacky method, plus last line

	GetMonitorHeight(&lngWorkingArea)
	lngRows := FLOOR(lngWorkingArea/lngRows)

	;Additional hacky method pieces
	lngRows -= pintPoint ;final piece of hacky attempt
	lngRows -= 1 ;one more line
	;End of hacky method

	;This should span the full length of the screen
	return lngRows
}

BuildGuiDuplicates(pMapAllKeys)
{
	;Builds a seperate view to display duplicate keys and their files
	lngPos_Info := 25 ; spacing from the right to the start of the comment
	strDisplay := ""
	lngRowCount := 0 ;Keep track of how many rows of text.
	
	;Look through all keys
	for element in pMapAllKeys
    {
		;We only care about the ones where the count >1 obviously
		if pMapAllKeys[element]["Count"]>1
        {
			;Build Header for each section
			if lngRowCount > 1
			{
				;this is to avoid the first line being blank
				strDisplay .= "`r`n" 
			}
			strDisplay .= String_Wings(" " element " ") "`r`n"
			lngRowCount += 2
			
			;Reset the file section text
			strDisplay_Section := ""

			;Loop through each file tied to the key
			for strFile in pMapAllKeys[element]["Files"]
			{
				  strDisplay_Section .= Format_Line(strFile,"",lngPos_Info) "`r`n"
				  lngRowCount += 1
			}
			
			;Just sort alphabetically by comment
			strDisplay_Section := Sort(strDisplay_Section, "P" lngPos_Info)
			
			;Append section data to main display
			strDisplay .= strDisplay_Section
			;lngRowCount += 1
		
            ;msgbox "Shortcut: " element "`nCount: " pMapAllKeys[element]["Count"]
		}
    }
	if strDisplay != "" 
	{
		myGuiDuplicate := Gui()
		myGuiDuplicate.Title := "Duplicate(s)"
		myGuiDuplicate.BackColor := mstrBackColor
		myGuiDuplicate.SetFont("s" mlngFontSize, mstrFont)
		myGuiDuplicate.Opt("+MinSize660x100")
		;we want the entire thing to resize
		myGuiDuplicate.AddEdit("ReadOnly +Vscroll r" lngRowCount, strDisplay)
		;myGui.AddText("ReadOnly +Vscroll r" lngRowCount, strDisplay)
		myGuiDuplicate.onEvent("Escape",GuiEscape)

		myGuiDuplicate.Show("AutoSize")
		Send("^{Home}")
	}
}

;********************************************
;** Methods - Gui Settings specific Things **
;********************************************
OpenSettings()
{

	guiSettings := Gui()
	guiSettings.Title := "Settings"
	
	txtFont := guiSettings.AddText("w85 xm","Font Size")

	intFontSize := IniRead("Help.ini", "Font", "Size" , mlngFontSize)
	txtFont.SetFont("w700")
		
	;seriously, if you can't choose a font size from these...what is wrong with you
	ddlFontSize := guiSettings.AddDropDownList("Choose" intFontSize-4 " xp+85", [5,6,7,8,9,10,11,12,13,14,15,16,17])
	ddlFontSize.OnEvent("Change",guiSettingsChgFont)
	
	
	
	
	
	global mlngVScreenPercent := IniRead("Help.ini", "Display", "ScreenPercent" , mlngVScreenPercent)
	global txtVPercent := guiSettings.AddText("w85 xm","Vertical " mlngVScreenPercent "%")
	txtVPercent.SetFont("w700")
	
	sldVPercent := guiSettings.AddSlider("xp+85", mlngVScreenPercent)
	sldVPercent.Onevent("Change",guiSettingsMySlider)
	
	guiSettings.onEvent("Close",guiSaveSettings)
	guiSettings.OnEvent("Escape", guiSaveSettings)
	
	;Todo:
	;Could probably make this better vs just hard coding this size
	guiSettings.Show("w250 h75")
	
}

guiSettingsChgFont(ddlFontSize,Info)
{
	global mlngFontSize := ddlFontSize.text
}

guiSettingsMySlider(sldVPercent,Info)
{
	Global mlngVScreenPercent := sldVPercent.Value
	txtVPercent.value := "Vertical " mlngVScreenPercent "%"
	
}

guiSaveSettings(guiSettings)
{
	;On exit of settings screen, save settings. lazy way vs just checking if they actually changed.
	;Alternatively if we changed on each update, it would update on button clicks for the slider, so 90-100 would write 10 times
	IniWrite mlngFontSize,"Help.ini", "Font", "Size"
	IniWrite mlngVScreenPercent,"Help.ini", "Display", "ScreenPercent"
	guiSettings.Hide

}