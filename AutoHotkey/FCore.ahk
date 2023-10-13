SetWorkingDir A_ScriptDir ; Ensures a consistent starting directory.
#SingleInstance force  ; Ensures that only the last executed instance of script is running
#NoTrayIcon

#Include Lib\Lib_BaseFunctions.ahk
#Include Lib\Lib_Globals.ahk


	global mblnGuiCreated_Cache := False
	global mblnGuiCreated_Link := False
	global mblnGuiCreated_Harness := False
	global mblnGuiCreated_FCR := False



/*
**********************************
**** Core - open new instance
**********************************
*/
^!G::	;Environment - Core
{
	BuildGuiLink("Core")
}	

/*
**********************************
**** Cache  - Open cache folder
**********************************
*/
^!C::	;Folder - Cache Location
{
	BuildGui_Cache("Cache")
	
}
/*
**********************************
**** Harness  - Open new d harness
**********************************
*/
^!D::		;Harness - Core Development
{
	BuildHarnessGui()
}
;##########################################################################
	BuildGui_Cache(pstrTitle)
	{
		global
		If !(mblnGuiCreated_Cache)
		{
			guiCore := Gui()
			
			objTitle_Cache := guiCore.AddText("vstrTitle","Temporary Placeholder")
			
			;After selecting one, load other options
			guiCore.AddDropDownList("vDDL_Environment Choose1",["D","T","S","P"])
			guiCore.AddDropDownList("vDDL_Set Choose1",["Prod Support","Upgrade"])

			
			;#####################################################
			;TODO: Need to rebuild settings list if path changes
			;#####################################################
			
			btnSubmit := guiCore.Addbutton("Default","OK")
			
			btnSubmit.OnEvent("Click", (*) => CacheSubmit_Click(guiCore))
			guiCore.OnEvent("Escape", (*) => Cache_Escape(guiCore))
			
			
			objTitle_Cache.Value := pstrTitle
			mblnGuiCreated_Cache:=true
		}
		guiCore.show
	
	}
	CacheSubmit_Click(pguiCore)
	{
		SubmitInfo := pguiCore.Submit(True)

		strSection := NormalizeSetTitle(SubmitInfo.DDL_Set) "-Cache"
		strKey := "CacheLoc_" SubmitInfo.DDL_Environment
		
		strURL := IniRead("GeneralConfig.ini",strSection,strKey)
		RUN strURL
			
	}
	Cache_Escape(pguiCore)
	{
		pguiCore.hide
		
	}
;##########################################################################

	BuildGuiLink(pstrTitle)
	{
		global
		If !(mblnGuiCreated_Link)
		{
			guiCore := Gui()
			
			objTitle := guiCore.AddText("vstrTitle","Temporary Placeholder")
			
			;After selecting one, load other options
			guiCore.AddDropDownList("vDDL_Environment Choose1",["D","T","S","P"])
			guiCore.AddDropDownList("vDDL_Set Choose1",["Prod Support","Upgrade"])
			guiCore.AddDropDownList("vDDL_Setting Choose1",BuildSetting("Prod Support"))

			
			;#####################################################
			;TODO: Need to rebuild settings list if path changes
			;#####################################################
			
			btnSubmit := guiCore.Addbutton("Default","OK")
			
			btnSubmit.OnEvent("Click", (*) => CoreSubmit_Click(guiCore))
			guiCore.OnEvent("Escape", (*) => Core_Escape(guiCore))
			
			
			objTitle.Value := pstrTitle
			mblnGuiCreated_Link:=True
		}
		guiCore.show
		
	}
	CoreSubmit_Click(pguiCore)
	{
		SubmitInfo := pguiCore.Submit(True)


		strSection := NormalizeSetTitle(SubmitInfo.DDL_Set) "-Links_" SubmitInfo.DDL_Environment
		strKey := GetSettingFromValue(SubmitInfo.DDL_Environment,SubmitInfo.DDL_Setting)
		
		strURL := IniRead("GeneralConfig.ini",strSection,strKey)
		run "chrome.exe --new-window " strURL

			
	}
	Core_Escape(pguiCore)
	{
		pguiCore.hide
		
	}

;##########################################################################
	BuildHarnessGui()
	{
		global
		If !(mblnGuiCreated_Cache)
		{
			guiD_Harness := Gui()
			
			;after selecting path, load settings
			GuiD_Harness.AddText("","Development harness")
			guiD_Harness.AddDropDownList("vDDL_Set Choose1", ["Prod Support","Upgrade"])
			guiD_Harness.AddDropDownList("vDDL_Setting Choose1",BuildSetting("Prod Support"))
			
			;#####################################################
			;TODO: Need to rebuild settings list if path changes
			;#####################################################
			
			btnServerOK := guiD_Harness.AddButton("Default", "Input")
			
			btnServerOK.OnEvent("Click", (*) => D_HarnessButton_Click(guiD_Harness))
			guiD_Harness.OnEvent("Escape",(*) => D_HarnessGui_Escape(guiD_Harness))
			mblnGuiCreated_Harness:=True
		}
		guiD_Harness.show
		
	}
	D_HarnessButton_Click(pguiD_Harness)
	{
		SubmitInfo := pGuiD_Harness.Submit(True)
		IF (SubmitInfo.DDL_Set="Prod Support")
		{
			strURL := Globals.GetGeneralConfigValue("APP-Harness","ProdSupport")
		}
		ELSE IF(SubmitInfo.DDL_Set="Upgrade")
		{
			strURL := Globals.GetGeneralConfigValue("APP-Harness","Upgrade")
		}
		strURL .= " "
		strURL .= Globals.GetGeneralConfigValue("APP-Harness","AutoStart")
		strURL .= SubmitInfo.DDL_Setting
		run strURL
		
	}
	D_HarnessGui_Escape(pguiD_Harness)	
	{
		pguiD_Harness.Hide
			
	}
;##########################################################################

;##########################################################################
;Helpers
	BuildSetting(pstrPath)
	{
		switch pstrPath
		{
			case "Prod Support":
				SettingsList := IniRead("GeneralConfig.ini","ProdSupport-Settings")
			Default:
				SettingsList := IniRead("GeneralConfig.ini","Upgrade-Settings")
		}
		Settings := Array()
		Loop Parse SettingsList, "`n","`r"
		{
			Settings.Push strSplit(A_LoopField,"=")[2]
		}
		return Settings
	}
	GetSettingFromValue(pstrPath,pstrValue)
	{
		switch pstrPath
		{
			case "Prod Support":
				SettingsList := IniRead("GeneralConfig.ini","ProdSupport-Settings")
			Default:
				SettingsList := IniRead("GeneralConfig.ini","Upgrade-Settings")
		}
		Loop Parse SettingsList, "`n","`r"
		{
			if(pstrValue = strSplit(A_LoopField,"=")[2])
			{
				return strSplit(A_LoopField,"=")[1]
			}
		}
	}
	NormalizeSetTitle(pstrSet)
	{
		Switch pstrSet
		{
			Case "Prod Support":
				return "ProdSupport"
			Default:
				return pstrSet
		}
	}
;##########################################################################
	^!F::		;FCR - Harness GUI for Core/Site
	{

		; strURL := Globals.GetGeneralConfigValue("FCR","FCR-Core")
		; RUN strURL
		global
		If !(mblnGuiCreated_FCR)
		{
			guiFCR := gui("","FCR")
			guiFCR.OnEvent("Escape", (*) => Core_Escape(guiFCR))
			
			guiFCR.AddText("","FCR - Selection")
			
			;We could do a lookup here on the ini file to see if core is configured
			ddlChoice := guiFCR.AddDropDownList("vChoice w100")
			if FileExist(iniRead("GeneralConfig.ini","FCR-Harness","Core"))
			{
				ddlChoice.Add(["Core"])
			}
			ddlChoice.Add(["Site"])
			ddlChoice.Choose(1)
			
			
			btnSubmit := GuiFCR.AddButton("Default","OK")
			btnSubmit.OnEvent("Click", (*) => FCR_Submit(guiFCR))
			
			mblnGuiCreated_FCR:=True
		}
		
		guiFCR.Show()

	}



	FCR_Submit(pguiFCR)
	{
		SubmitInfo := pguiFCR.Submit(True)
		strURL := ""
		SWITCH SubmitInfo.Choice
		{
			CASE "Core":
				strURL := Globals.GetGeneralConfigValue("FCR-Harness","Core")
			CASE "Site":
				strURL := Globals.GetGeneralConfigValue("FCR-Harness","Site")
			Default:
				msgbox "Invalid option: " SubmitInfo.Choice
		}
		RUN strURL
		
		
	}
;##########################################################################

^!W::	;Window - Organize layout (Experimental)
{
	DetectHiddenWindows False
	;set a default to get started
	intHarnessWidth := 500 
	
	strWindowName:=Globals.GetGeneralConfigValue("FCR-Decode","Decode_Core")
	WinGetPos &x,&y,&intWidth,&intWindowHeight_Core,strWindowName
	
	if(intWindowHeight_Core=0 OR intWindowHeight_Core = "")
	{
		intWindowHeight_Core := 250
	}

	;Get harness width and set it, otherwise use a default
	IF(intWidth = "")
	{
		intHarnessWidth := 500 
	}
	else 
	{
		intHarnessWidth := intwidth
	}

	strWindowName:=Globals.GetGeneralConfigValue("FCR-Decode","Decode_Site")
	WinGetPos &x,&y,&intWidth,&WindowHeight_Site, strWindowName

	;Attempt to get harness width again, otherwise use default...which should have already been set
	IF(intHarnessWidth=500 AND intWidth != "")
	{
		;Should probably check if harness width is set at all ALSO
		intHarnessWidth := intWidth
	}
	
	if(WindowHeight_Site=0)
	{
		WindowHeight_Site:=250
	}
	
	WindowPostitionWidth := (A_ScreenWidth-intHarnessWidth)-50
	WindowPositionHeigth := 10
	WindowSpaceBetween := 10
	
	;--------------------------------------------------
	; Core FCR
	;msgbox, % A_ScreenWidth " - " intHarnessWidth " - " WindowPostitionWidth " - " WindowPositionHeigth
	strWindowName:=Globals.GetGeneralConfigValue("FCR-Decode","Decode_Core")
	WinMove WindowPostitionWidth,WindowPositionHeigth,,,strWindowName

	;--------------------------------------------------	
	; Site FCR
	strWindowName:=Globals.GetGeneralConfigValue("FCR-Decode","Decode_Site")
	WindowPositionHeigth:=WindowPositionHeigth+intWindowHeight_Core+WindowSpaceBetween
	WinMove WindowPostitionWidth,WindowPositionHeigth,,,strWindowName

	;--------------------------------------------------
	; D environment
	WindowPositionHeigth:=WindowPositionHeigth+WindowHeight_Site+WindowSpaceBetween
	
	strWindowName:=Globals.GetGeneralConfigValue("ProdSupport-Settings","Setting1")
	WinList := WinGetList(strWindowName)

	WindowPostitionWidth_tmp:= WindowPostitionWidth
	Loop WinList.length
	{
		;msgbox WinGetClass(WinList[A_Index])
		;Loop through each window of this name and make them next to each other
		this_id := "ahk_id " . WinList[A_Index]
		WinMove WindowPostitionWidth_tmp,WindowPositionHeigth,,,this_id
		;Update position in case of multiple windows
		WindowPostitionWidth_tmp := WindowPostitionWidth_tmp-(intHarnessWidth+WindowSpaceBetween)
	}
	
	;--------------------------------------------------
	; D Tap
	
	strWindowName:=Globals.GetGeneralConfigValue("ProdSupport-Settings","Setting1")
	WindowPostitionWidth:=WindowPostitionWidth-800
	;msgbox strWindowName " : " WinGetClass(this_id)

	;WinMove WindowPostitionWidth,WindowPositionHeigth,,,strWindowName
	
	; WinGet, WinList, list, TAP
	; WindowPostitionWidth_tmp:= WindowPostitionWidth
	; Loop, %WinList%
	; {
		; ;Loop through each window of this name and make them next to each other
		; this_id := "ahk_id " . WinList%A_Index%
		; WinMove, %this_id%,,WindowPostitionWidth_tmp,WindowPositionHeigth
		; ;Update position in case of multiple windows
		; WindowPostitionWidth_tmp := WindowPostitionWidth_tmp-(HarnessWidth+WindowSpaceBetween)
	; }
	
	
	
}

^!+K:: ;Kill all instances of Core
{
	;257 means two buttons with second being the focus
	strResults := MsgBox("Close Core", "Close all Core instances?", 257)
	If strResults = "OK"
	{
		;If this isn't closing a window, the case on the decode might be off
		FCoreKill(Globals.GetGeneralConfigValue("FCR-Decode","Decode_Site"),1,0,0,1)
		FCoreKill(Globals.GetGeneralConfigValue("FCR-Decode","Decode_Core"),1,0,0,1)
		
		;Loop through settings
		Settings := IniRead("GeneralConfig.ini", "ProdSupport-Settings")
		Loop Parse Settings, "`n", "`r"
		{
			;msgbox strSplit(A_LoopField,"=")[2]
			FCoreKill(strSplit(A_LoopField,"=")[2],1,0,0,1)
		}
	
		;FCoreKill(Globals.GetGeneralConfigValue("Core-ProdSupport-Decodes","Decode_Harness-Core-D"),1,0,0,1)
		;FCoreKill(Globals.GetGeneralConfigValue("Core-ProdSupport-Decodes","Decode_Harness-Tap-D"),1,0,0,1)
		
		
		;Temp for TN, because I ALWAYS need to open this to close my VPN after closing all harnesses
		Run "c:\program files (x86)\cisco\cisco anyconnect secure mobility client\vpnui.exe"
	}	
}

FCoreKill(pstrCore,Kill:=0, Pause:=0, Suspend:=0, SelfToo:=0) 
{
	DetectHiddenWindows true
	; WinGet, IDList ,List, %pstrCore%
	IDList := WinGetList(pstrCore)

	;msgbox "Found: " IDList.Length

	Loop IDList.Length
	{
	
		this_ID := IDList[A_Index]
		this_class := WinGetClass(IDList[A_Index])
		;ATitle := WinGetTitle(this_ID)
		; msgbox ATitle
		; msgbox "Title: " ATitle "`nClass: " this_class
		if instr(this_class,"gtGen")>0
		{
			If Suspend
			{
				PostMessage 0x111, 65305,,, this_ID  ; Suspend. 
			}
			If Pause
			{
				PostMessage 0x111, 65306,,, this_ID  ; Pause.
			}
			If Kill
			{
				;msgbox "Killed: " this_class 
				WinClose this_ID ;kill
			}
		}
	}
; ; If SelfToo
  ; ; {
  ; ; If Suspend
    ; ; Suspend, Toggle  ; Suspend. 
  ; ; If Pause
    ; ; Pause, Toggle, 1  ; Pause.
  ; ; If Kill
    ; ; ExitApp
  ; ; }
}
