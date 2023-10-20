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
			guiCache := Gui()
			
			objTitle_Cache := guiCache.AddText("vstrTitle","Temporary Placeholder")
			
			;After selecting one, load other options
			guiCache.AddDropDownList("vDDL_Environment Choose1",["D","T","S","P"])
			guiCache.AddDropDownList("vDDL_Set Choose1",["Prod Support","Upgrade"])

			
			;#####################################################
			;TODO: Need to rebuild settings list if path changes
			;#####################################################
			
			btnSubmit := guiCache.Addbutton("Default","OK")
			
			btnSubmit.OnEvent("Click", (*) => CacheSubmit_Click(guiCache))
			guiCache.OnEvent("Escape", (*) => Cache_Escape(guiCache))
			
			
			objTitle_Cache.Value := pstrTitle
			mblnGuiCreated_Cache:=true
		}
		guiCache.show
	
	}
	CacheSubmit_Click(pguiCache)
	{
		SubmitInfo := pguiCache.Submit(True)

		strSection := NormalizeSetTitle(SubmitInfo.DDL_Set) "-Cache"
		strKey := "CacheLoc_" SubmitInfo.DDL_Environment
		
		strURL := IniRead("GeneralConfig.ini",strSection,strKey)
		RUN strURL
			
	}
	Cache_Escape(pguiCache)
	{
		pguiCache.hide
		
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
			ddlCoreSet := guiCore.AddDropDownList("vDDL_Set Choose1",["Prod Support","Upgrade"])
			ddlCoreSetting := guiCore.AddDropDownList("vDDL_Setting Choose1",BuildSetting("Prod Support"))

			ddlCoreSet.OnEvent("Change", (*) => UpdateLinkSettings(ddlCoreSetting,ddlCoreSet.Text))
			
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
		strKey := GetSettingFromValue(SubmitInfo.DDL_Set,SubmitInfo.DDL_Setting)
		
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
		If !(mblnGuiCreated_Harness)
		{
			guiD_Harness := Gui()
			
			;after selecting path, load settings
			GuiD_Harness.AddText("","Development harness")
			ddlHarnessSet := guiD_Harness.AddDropDownList("vDDL_Set Choose1", ["Prod Support","Upgrade"])
			ddlHarnessSetting := guiD_Harness.AddDropDownList("vDDL_Setting Choose1",BuildSetting("Prod Support"))
			
			ddlHarnessSet.OnEvent("Change", (*)=> UpdateHarnessSettings(ddlHarnessSetting,ddlHarnessSet.Text))
			
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
	UpdateHarnessSettings(pddlHarnessSetting, pstrHarnessSetText)
	{
		pddlHarnessSetting.Delete
		Switch pstrHarnessSetText
		{
			Case "Prod Support":
				pddlHarnessSetting.Add(BuildSetting("Prod Support"))
			Default:
				pddlHarnessSetting.Add(BuildSetting("Upgrade"))
		}
		pddlHarnessSetting.Choose(1)
	}
	UpdateLinkSettings(pddlLinkSetting, pstrLinkSetText)
	{
		pddlLinkSetting.Delete
		Switch pstrLinkSetText
		{
			Case "Prod Support":
				pddlLinkSetting.Add(BuildSetting("Prod Support"))
			Default:
				pddlLinkSetting.Add(BuildSetting("Upgrade"))
		}
		pddlLinkSetting.Choose(1)
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
	
	WinList := WinGetList("ahk_exe gtgen.exe")
	mapWin := Map()
	mapWin.Capacity := WinList.length
	

	strCoreFCR := Globals.GetGeneralConfigValue("FCR-Decode","Decode_Core")
	strSiteFCR := Globals.GetGeneralConfigValue("FCR-Decode","Decode_Site")

	lngCounter:=mapWin.Capacity
	Loop WinList.length
	{
		SWITCH WinGetTitle("ahk_ID " WinList[A_Index])
		{
			CASE strCoreFCR:
				mapWin.Set(1,WinList[A_Index])
				
			CASE strSiteFCR:
				mapWin.Set(2,WinList[A_Index])
				
			Default:
				mapWin.Set(lngCounter,WinList[A_Index])
				lngCounter-=1
				
		}
	}
	
	lngHarnessWidth := 0
	lngHarnessHeight := 0
	
	lngStartPosWidth := A_ScreenWidth
	lngStartPosHeight := 0

	
	for Key, WinID in mapWin
	{
    	
		;Get window dimensions
		winGetpos ,,&lngHarnessWidth,&lngHarnessHeight,"ahk_id " WinId
		
		;Adjust width position for initial
		if(lngStartPosWidth = A_ScreenWidth)
		{
			lngStartPosWidth  -= (lngHarnessWidth+50 )
		}

		;Adjust height
		if(lngStartPosHeight=0)
		{
			lngStartPosHeight := 50
		}
		
		winMove lngStartPosWidth,lngStartPosHeight,,,"Ahk_ID " WinId
		
		;Adjust next window start position. Checking two times the current harness so that we can see if the next harness will go off screen
		if((lngStartPosHeight+(2*lngHarnessHeight)+10) >= A_ScreenHeight)
		{
			;move horizontal since we are now going beyond the screen height.
			;If it ever becomes a problem where we go OFF the screen horizontally as well, then I guess we could just reset the position and start overlaying
			lngStartPosWidth -= (lngHarnessWidth +10)
		}
		Else
		{
			;move new starting position down
			lngStartPosHeight += lngHarnessHeight+10
		}

	}

	
	
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
