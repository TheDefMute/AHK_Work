SetWorkingDir A_ScriptDir ; Ensures a consistent starting directory.
#SingleInstance force  ; Ensures that only the last executed instance of script is running
#NoTrayIcon

#Include Lib\Lib_BaseFunctions.ahk
#Include Lib\Lib_Globals.ahk
#Include Lib\Lib_FCore.ahk


	global mblnGuiCreated_Core := False
	global mblnGuiCreated_Harness := False
	global mblnGuiCreated_FCR := False



/*
*****************
**** Core - open new instance
*****************
*/
^!G::	;Environment - Core
{
	BuildGui("Core")
}	
/*
*****************
**** TAP - open new instance
*****************
*/
^!T::	;Environment - TAP
{
	BuildGui("TAP")

}		

/*
*****************
**** Cache  - Open cache folder
*****************
*/
^!C::	;Folder - Cache Location
{
	BuildGui("Cache")
	
}

BuildGui(pstrTitle)
{
	global
	If !(mblnGuiCreated_Core)
	{
		guiCore := Gui()
		
		global mobjTitle := guiCore.AddText("vstrTitle","Temporary Placeholder")
		
		guiCore.AddDropDownList("vDDL_Environment Choose1",["D","T","S","P"])
		guiCore.AddDropDownList("vDDL_Set Choose1",["Prod Support","Upgrade"])
		
		btnSubmit := guiCore.Addbutton("Default","OK")
		
		btnSubmit.OnEvent("Click", (*) => CoreSubmit_Click(guiCore))
		guiCore.OnEvent("Escape", (*) => Core_Escape(guiCore))
		
		mblnGuiCreated_Core:=True
	}
	mobjTitle.Value := pstrTitle
	guiCore.show
	
}
BuildHarnessGui()
{
	global
	If !(mblnGuiCreated_Harness)
	{
		global mguiD_Harness := Gui()
		
		
		mGuiD_Harness.AddText("","Development harness")
		mguiD_Harness.AddDropDownList("vDDL_Set Choose1", ["Prod Support","Upgrade"])
		
		btnServerOK := mguiD_Harness.AddButton("Default", "Input")
		
		btnServerOK.OnEvent("Click", D_HarnessButton_Click)
		mguiD_Harness.OnEvent("Escape",D_HarnessGui_Escape)
		mblnGuiCreated_Harness:=True
	}
	mguiD_Harness.show
	
}

CoreSubmit_Click(pguiCore)
{
	SubmitInfo := pguiCore.Submit(True)
	SWITCH mobjTitle.Value, False
	{
		CASE "Core":
			strURL := FCore.GetUrlFromEnvAndSet(SubmitInfo.DDL_Set,SubmitInfo.DDL_Environment,"Core")
			run "chrome.exe --new-window " strURL
			
		CASE "TAP":
			strURL := FCore.GetUrlFromEnvAndSet(SubmitInfo.DDL_Set,SubmitInfo.DDL_Environment,"Tap")
			run "chrome.exe --new-window " strURL
			
		CASE "Cache":
			strURL := FCore.GetUrlFromEnvAndSet(SubmitInfo.DDL_Set,SubmitInfo.DDL_Environment,"CacheLoc")
			RUN strURL
		Default:
			msgbox "Invalid Option"
	}
		
}

/*
**************
**** GUI Cancel
**************
*/
Core_Escape(pguiCore)
{
	pguiCore.hide
	
}

D_HarnessGui_Escape(*)	
{
	mGuiD_Harness.Hide
		
}
	

^!D::		;Harness - Core Development
{
	BuildHarnessGui()
}

D_HarnessButton_Click(*)
{
	SubmitInfo := mGuiD_Harness.Submit(True)
	IF (SubmitInfo.DDL_Set="Prod Support")
	{
		strURL := Globals.GetGeneralConfigValue("Core-ProdSupport","Harness-Core-D")
		run strURL
	}
	ELSE IF(SubmitInfo.DDL_Set="Upgrade")
	{
		strURL := Globals.GetGeneralConfigValue("Core-Upgrade","Harness-Core-D")
		run strURL
	}
	
}

	
^!A::		;Harness - TAP Development
{

	strURL := Globals.GetGeneralConfigValue("Core-ProdSupport","Harness-Tap-D")
	run strURL
	
}
	
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
		if FileExist(iniRead("GeneralConfig.ini","FCR","FCR-Core"))
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

; ^!L::		;FCR - Site
; {
	; strURL := Globals.GetGeneralConfigValue("FCR","FCR-Site")
	; RUN strURL
	
; }

FCR_Submit(pguiFCR)
{
	SubmitInfo := pguiFCR.Submit(True)
	strURL := ""
	SWITCH SubmitInfo.Choice
	{
		CASE "Core":
			strURL := Globals.GetGeneralConfigValue("FCR","FCR-Core")
		CASE "Site":
			strURL := Globals.GetGeneralConfigValue("FCR","FCR-Site")
		Default:
			msgbox "Invalid option: " SubmitInfo.Choice
	}
	RUN strURL
	
	
}
;------------------------

^!W::	;Window - Organize layout (Experimental)
{
	DetectHiddenWindows False
	;set a default to get started
	intHarnessWidth := 500 
	
	strWindowName:=Globals.GetGeneralConfigValue("Core-ProdSupport-Decodes","Decode_FCR-Core")
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

	strWindowName:=Globals.GetGeneralConfigValue("Core-ProdSupport-Decodes","Decode_FCR-Site")
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
	strWindowName:=Globals.GetGeneralConfigValue("Core-ProdSupport-Decodes","Decode_FCR-Core")
	WinMove WindowPostitionWidth,WindowPositionHeigth,,,strWindowName

	;--------------------------------------------------	
	; Site FCR
	strWindowName:=Globals.GetGeneralConfigValue("Core-ProdSupport-Decodes","Decode_FCR-Site")
	WindowPositionHeigth:=WindowPositionHeigth+intWindowHeight_Core+WindowSpaceBetween
	WinMove WindowPostitionWidth,WindowPositionHeigth,,,strWindowName

	;--------------------------------------------------
	; D environment
	WindowPositionHeigth:=WindowPositionHeigth+WindowHeight_Site+WindowSpaceBetween
	
	strWindowName:=Globals.GetGeneralConfigValue("Core-ProdSupport-Decodes","Decode_Harness-Core-D")
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
	
	strWindowName:=Globals.GetGeneralConfigValue("Core-ProdSupport-Decodes","Decode_Harness-TAP-D")
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
		FCoreKill(Globals.GetGeneralConfigValue("Core-ProdSupport-Decodes","Decode_Harness-Core-D"),1,0,0,1)
		FCoreKill(Globals.GetGeneralConfigValue("Core-ProdSupport-Decodes","Decode_Harness-Tap-D"),1,0,0,1)
		FCoreKill(Globals.GetGeneralConfigValue("Core-ProdSupport-Decodes","Decode_FCR-Site"),1,0,0,1)
		FCoreKill(Globals.GetGeneralConfigValue("Core-ProdSupport-Decodes","Decode_FCR-Core"),1,0,0,1)
		
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
