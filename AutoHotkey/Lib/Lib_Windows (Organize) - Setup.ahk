Class Windows_Organize_Setup
{

	static SetupWindowOrganize()
	{
		guiWindow := Gui("+AlwaysOnTop","Win-Organize")
		
		;Titles
		lblMonitor := guiWindow.AddText("Section w50 ","Monitor")
		lblMonitor := guiWindow.AddText("x+10 w250 ","Programs")
		
		
		;Combo boxes to select monitor
		ddlWindows := guiWindow.AddComboBox("xs w50")
		ddlWindows.Add(Windows_Organize_Setup.BuildWindowCount())
		ddlWindows.Choose(Windows_Organize_Setup.GetMonitorCount())

		;Combo boxes to select apps
		ddlApps := guiWindow.AddComboBox("x+10 w250 Choose1", Windows_Organize_Setup.BuildProgramList(ddlWindows.text))
		
		;Event when drop down list is changed to repopulate app list
		ddlWindows.OnEvent("Change", (*)=> Windows_Organize_Setup.RetrieveProgramList(ddlApps,ddlWindows.Text))
			
		;Section - Titles
		lblTitle := guiWindow.AddText("xs w50","Title")
		txtTitle := guiWindow.AddEdit("x+10 w250", "")
		
		;Section - Positions: X
		lblXPos := guiWindow.AddText("xs w50","X Pos")
		txtXPos := guiWindow.AddEdit("x+10 number","")
		
		;Section - Position: Y
		lblYPos := guiWindow.AddText("xs w50","Y Pos")
		txtYPos := guiWindow.AddEdit("x+10 number","")
		
		;Section - Checkbox
		lblCBFullScreen := guiWindow.AddText("xs w50","Full Scr")
		cbFullScreen := guiWindow.AddCheckBox("x+10 ","")
		
		;Section - Width
		lblWidth := guiWindow.AddText("xs w50","Width")
		txtWidth := guiWindow.AddEdit("x+10 number","")
		
		;Section - Height
		lblHeight := guiWindow.AddText("xs w50","Height")
		txtHeight := guiWindow.AddEdit("x+10 number","")
		
		;Event when full screen checkbox is checked to disable/enable H/W
		cbFullScreen.OnEvent("Click",(*)=> Windows_Organize_Setup.CheckBoxFullScreen(cbFullScreen.Value,txtWidth,txtHeight))
		
		;Section - Button to get window details
		btnGetWindow := guiWindow.AddButton("Default w80","Capture")
		
		;Section - Button to update
		btnUpdate := guiWindow.AddButton("w80","Update")
		btnUpdate.OnEvent("Click", (*)=> Windows_Organize_Setup.UpdateProgramDetails(ddlApps.Text,txtTitle.value,txtXPos.value,txtYPos.value,cbFullScreen.value,txtWidth.value,txtHeight.value))
		
		btnAdd := guiWindow.AddButton("x+10 w80","Add")
		btnAdd.OnEvent("Click", (*)=> Windows_Organize_Setup.AddNewProgram(guiWindow, ddlApps, ddlWindows.Value, &txtTitle,&txtXPos,&txtYPos,&cbFullScreen,&txtWidth,&txtHeight))
		
		;Section - Status at Bottom
		lblStatus := guiWindow.AddText("xs w300","Manual entry")
		
		
		;Events
		ddlApps.OnEvent("Change", (*)=> Windows_Organize_Setup.LoadWindowDetail(ddlWindows.Text,ddlApps.Text,&txtTitle,&txtXPos,&txtYPos,&cbFullScreen,&txtWidth,&txtHeight))
		
		;Event - To capture window details
		btnGetWindow.OnEvent("Click", (*) => Windows_Organize_Setup.CaptureWindowDetail(lblStatus,&txtTitle,&txtXPos,&txtYPos,&cbFullScreen,&txtWidth,&txtHeight))
		
		
		;Load window details
		Windows_Organize_Setup.LoadWindowDetail(ddlWindows.Text,ddlApps.Text,&txtTitle,&txtXPos,&txtYPos,&cbFullScreen,&txtWidth,&txtHeight)
		
		
		guiWindow.OnEvent("Escape", (*) => Windows_Organize_Setup.gui_Escape(guiWindow))
		;Display options for window position
		guiWindow.show()
	}

	static AddNewProgram(pguiWindow, pddlApps, plngCurrentMonitor, &ptxtTitle,&ptxtXPos,&ptxtYPos,&pcbFullScreen,&ptxtWidth,&ptxtHeight)
	{
		pguiWindow.Opt("+Disabled -AlwaysOnTop")
		
		astrApplicationList := Windows_Organize_Setup.BuildProgramList(plngCurrentMonitor)
		lngNewApplicationNumber := 0
		
		;Lets just do simple for now. count+1
		lngNewApplicationNumber := astrApplicationList.Length+1

		;Find the next item in the list or an open number not used
		; loop astrApplicationList.length
		; {
			; astrItems := strsplit(astrApplicationList[A_Index],"=")
		; }
		
		;Loop until the value they give is NOT found
		loop
		{
			;Set this to true and only set to false if we need to loop again
			blnValid := true
			ibNewProgram := InputBox("Name","New Program Title")
			ibNewProgram.value := strReplace(ibNewProgram.value," ","")

			if ibNewProgram.Result = "OK"
			{
				loop_ProgramList:
				Loop astrApplicationList.length
				{
					IF(Instr(astrApplicationList[A_Index],ibNewProgram.Value,0)>0)
					{
						;Try again
						msgbox "The value: '" ibNewProgram.Value "' is already used for " astrApplicationList[A_Index]
						blnValid := false
						break
					}				
				}
			}
		} Until blnValid
		
		If ibNewProgram.Result = "OK"
		{
			;Add entries to ini FileAppend
			IniWrite(ibNewProgram.Value "_MonitorCount_" plngCurrentMonitor,"Windows (Organize).ini","Monitors_" plngCurrentMonitor,"Application" lngNewApplicationNumber)
			
			Windows_Organize_Setup.UpdateProgramDetails("Application" ibNewProgram.Value "=" ibNewProgram.Value "_MonitorCount_" plngCurrentMonitor,"",0,0,False,0,0)
			
			;Refresh ddl box and select
			Windows_Organize_Setup.RetrieveProgramList(pddlApps,plngCurrentMonitor,lngNewApplicationNumber)
			ptxtTitle.value := ""
			ptxtXPos.value := 0
			ptxtYPos.value := 0
			pcbFullScreen.value := False
			ptxtWidth.value := 0
			ptxtHeight.value := 0
		}

		
		pguiWindow.opt("-Disabled +AlwaysOnTop")
		
	}


	static gui_Escape(pguiWindow)
	{
		;Need to abort the loop in CaptureWindowDetail otherwise it will create an error later
		pguiWindow.destroy
		
		;This is a hack workaround, just reload the script to abort the loop
		Reload 
	}


	static CaptureWindowDetail(plblStatus,&ptxtTitle,&ptxtxPos,&ptxtyPos,&pcbFullScreen,&ptxtWidth,&ptxtHeight)
	{
		plblStatus.Value := "Helper: Click window to capture details"
		
		;this will be used to get the mouse position when we want to position the window
		loop {
			if getkeystate("lbutton"){
				mousegetpos &xpos, &ypos, &id, &control
				;msgbox "ahk_id " id "`nahk_class " WinGetClass(id) "`n" WinGetTitle(id) "`nControl: " control
				
				WinGetPos &xPos, &yPos, &Width, &Height, WinGetTitle(id)
				blnMinMax := WinGetMinMax(WinGetTitle(id))
				
				ptxtTitle.value := "ahk_exe " WinGetProcessName(WinGetTitle(id))
				ptxtxPos.Value := xPos
				ptxtyPos.Value := yPos
				pcbFullScreen.Value := blnMinMax
				ptxtWidth.Value := Width
				ptxtHeight.Value := Height
				
				Windows_Organize_Setup.CheckBoxFullScreen(pcbFullScreen.value,ptxtWidth,ptxtHeight)
				
				break
			}
			; if GetKeyState("Escape")
			; {
				; break
			; }
		}
		plblStatus.Value := "Manual entry"
	}

	static GetMonitorCount()
	{
		lngCount_Monitors:=0
		lngCount_Monitors := sysGet(80) ;80 is the monitor count
		
		return lngCount_Monitors
	}

	static BuildWindowCount()
	{
		alngMonitorCount := []
		loop Windows_Organize_Setup.GetMonitorCount()
		{
			;msgbox A_Index
			alngMonitorCount.Push(A_Index)
		}
		return alngMonitorCount
	}


	static RetrieveProgramList(pddlPrograms,plngMonitorCount, plngChoice := 1)
	{
		;this should be changed to update the program list
		pddlPrograms.Delete
		
		
		pddlPrograms.Add(Windows_Organize_Setup.BuildProgramList(plngMonitorCount))
		pddlPrograms.Choose(plngChoice)
	}



	static CheckBoxFullScreen(pcbValue, ptxtWidth,ptxtHeight)
	{
		if(pcbValue)
		{
			ptxtWidth.Opt("+ReadOnly")
			ptxtHeight.Opt("+ReadOnly")
		}
		Else
		{
			ptxtWidth.Opt("-ReadOnly")
			ptxtHeight.Opt("-ReadOnly")
		}

	}

	;Section - INI File stuff
		static BuildProgramList(plngMonitorCount)
		{
			strProgramlist := INiRead("Windows (Organize).ini","Monitors_" plngMonitorCount)
			astrProgramList := []
			
			loop Parse strProgramlist, "`n", "`r"
			{
				;msgbox A_LoopField
				astrProgramList.Push(A_LoopField)
			}
			return astrProgramList
		}

		static LoadWindowDetail(pstrMonitor,pstrApplication,&ptxtTitle,&ptxtxPos,&ptxtyPos,&pcbFullScreen,&ptxtWidth,&ptxtHeight)
		{
			strCurrentMonitor := "Monitors_" pstrMonitor
			strCurrentApplication := strSplit(pstrApplication,"=")[1]
			
			
			ptxtTitle.Value := Windows_Organize_Setup.GetTitle(iniRead("Windows (Organize).ini",strCurrentMonitor,strCurrentApplication))
			ptxtxPos.Value := Windows_Organize_Setup.GetPosX(iniRead("Windows (Organize).ini",strCurrentMonitor,strCurrentApplication))
			ptxtyPos.value := Windows_Organize_Setup.GetPosY(iniRead("Windows (Organize).ini",strCurrentMonitor,strCurrentApplication))
			
			pcbFullScreen.value := Windows_Organize_Setup.GetWindowMax(iniRead("Windows (Organize).ini",strCurrentMonitor,strCurrentApplication))
			
			ptxtWidth.value := Windows_Organize_Setup.GetWidth(iniRead("Windows (Organize).ini",strCurrentMonitor,strCurrentApplication))
			ptxtHeight.value := Windows_Organize_Setup.GetHeight(iniRead("Windows (Organize).ini",strCurrentMonitor,strCurrentApplication))
			
			Windows_Organize_Setup.CheckBoxFullScreen(pcbFullScreen.value,ptxtWidth,ptxtHeight)

		}

		static UpdateProgramDetails(pstrApplication,pstrTitle,plngXPos,plngYPos,pblnFullScreen,plngWidth,plngHeight)
		{
			astrApplication := strsplit(pstrApplication,"=")
			
			Windows_Organize_Setup.SetTitle(astrApplication[2],pstrTitle)
			
			Windows_Organize_Setup.SetPosX(astrApplication[2],plngXPos)
			Windows_Organize_Setup.SetPosY(astrApplication[2],plngYPos)
			
			Windows_Organize_Setup.SetWindowMax(astrApplication[2], pblnFullScreen)
			if(pblnFullScreen)
			{
				Windows_Organize_Setup.SetWidth(astrApplication[2],0)
				Windows_Organize_Setup.SetHeight(astrApplication[2],0)
			}
			Else
			{
				Windows_Organize_Setup.SetWidth(astrApplication[2],plngWidth)
				Windows_Organize_Setup.SetHeight(astrApplication[2],plngHeight)
			}
		}
		
	static GetTitle(pstrItem)
	{
		return IniRead("Windows (Organize).ini", pstrItem,"Title")
	}
	static GetPosX(pstrItem)
	{
		return IniRead("Windows (Organize).ini", pstrItem,"PosX")
	}
	static GetPosY(pstrItem)
	{
		return IniRead("Windows (Organize).ini", pstrItem,"PosY")
	}
	static GetHeight(pstrItem)
	{
		return IniRead("Windows (Organize).ini", pstrItem,"Height")
	}
	static GetWidth(pstrItem)
	{
		return IniRead("Windows (Organize).ini", pstrItem,"Width")
	}
	static GetWindowMax(pstrItem)
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

	static SetTitle(pstrItem,pstrValue)
	{
		INIWrite(pstrValue,"Windows (Organize).ini",pstrItem,"Title")
	}
	static SetPosX(pstrItem,plngValue)
	{
		INIWrite(plngValue,"Windows (Organize).ini",pstrItem,"PosX")
	}
	static SetPosY(pstrItem,plngValue)
	{
		INIWrite(plngValue,"Windows (Organize).ini",pstrItem,"PosY")
	}
	static SetHeight(pstrItem,plngValue)
	{
		INIWrite(plngValue,"Windows (Organize).ini",pstrItem,"Height")
	}
	static SetWidth(pstrItem,plngValue)
	{
		INIWrite(plngValue,"Windows (Organize).ini",pstrItem,"Width")
	}
	static SetWindowMax(pstrItem,pblnValue)
	{
		INIWrite(pblnValue,"Windows (Organize).ini",pstrItem,"WinMax")
	}
}