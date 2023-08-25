#SingleInstance force  ; Ensures that only the last executed instance of script is running
#NoTrayIcon

Class Setup
{
	static mblnCreated := False
	static mstrINIDriverFile := ""
	static mstrINIConfigFile := ""
	
	static CreateGui(pstrDriverFile, pstrConfigFile, pstrDecode)
	{
		;global ;allows us to use the global variable
		if this.mblnCreated
		{
			;Destroy gui if it was already created
			guiGeneralConfig.destroy()
		}
		
		this.mstrINIDriverFile := pstrDriverFile
		this.mstrINIConfigFile := pstrConfigFile
		
		;keeps all information from the INI file in a format of [Section][Key][Value]
		mapAllItems := Map()
		
		strIniResults := IniRead(this.mstrINIDriverFile)
		loop parse strIniResults,"`n","`r"
		{
			;Build/Load each section
			;could PROBABLY be tweaked, to lazy right now
			;Can't build sections here because map automatically organizes it.
			mapAllItems[A_LoopField] := this.LoadSection(A_LoopField)
		}
		
		;Generic header settings..that probably COULD be moved to the INI file
		strHeaderOptions := "w700"
		strHeaderFontOptions := "cRed w700"
		
		;Create gui
		guiGeneralConfig := Gui("",pstrDecode)
		;guiGeneralConfig.OnEvent("Escape", (*)=> guiGeneralConfig.Destroy())
		guiGeneralConfig.OnEvent("Escape", (*)=> this.CloseGui(guiGeneralConfig))
		guiGeneralConfig.OnEvent("Close", (*)=> this.CloseGui(guiGeneralConfig))
		
		;Set global variable so that if we trigger the key multiple times, we can destroy the previously created version
		this.mblnCreated := True
		
		;Build array to create tabs for the gui
		astrSections := []
		for intOrder, strSection in mapAllItems["Tabs"]
		{
			astrSections.push(strSection)
		}
		
		;create tabs
		tabItems := guiGeneralConfig.addTab3("Buttons",astrSections)
		
		;will loop through each 'TAB' and grab the approprirate information to add items
		for intOrder, strSection in mapAllItems["Tabs"]
		{
			tabItems.UseTab(strSection)
		
			;Loop through map array of items that are sorted by each section and order to make it easier
			for intOrder, strItem in this.GetItemsByTab(mapAllItems, strSection)
			{
				if A_Index = 1
				{
					;The first row should have "Section" to create an anchor. Ideally the first section should always be the header.
					If mapAllItems[strItem]["Type"]="Header"
					{
						;Header
						lblTitle := guiGeneralConfig.AddText(strHeaderOptions " Section",mapAllItems[strItem]["Decode"])
						lblTitle.SetFont(strHeaderFontOptions)
					}
					Else
					{
						this.AddLineItem(guiGeneralConfig,mapAllItems[strItem]["Type"],mapAllItems[strItem]["Decode"],mapAllItems[strItem]["Section"],mapAllItems[strItem]["Key"],"Section",mapAllItems[strItem]["DisplayLength"],mapAllItems[strItem]["EditLength"])
					}
				}
				Else
				{
					this.AddLineItem(guiGeneralConfig,mapAllItems[strItem]["Type"],mapAllItems[strItem]["Decode"],mapAllItems[strItem]["Section"],mapAllItems[strItem]["Key"],"xs",mapAllItems[strItem]["DisplayLength"],mapAllItems[strItem]["EditLength"])
				}
			}
			
		}
		
		mapAllItems.Clear()
		guiGeneralConfig.show()
		
		
	}


	;Load all Key/values from a section
	static LoadSection(pstrSection)
	{
		mapSection := Map()
		strSection := iniRead(this.mstrINIDriverFile,pstrSection)

		loop parse strSection, "`n","`r"
		{
			astrKeyValue := strsplit(A_LOOPField,"=")
			if pstrSection="Tabs"
			{
				;Tabs is the only one section different. We are taking advantage of maps auto sorting by the first column.
				mapSection.set(Number(astrKeyValue[1]),astrKeyValue[2])
			}
			Else
			{
				mapSection.set(astrKeyValue[1],astrKeyValue[2])
			}
		}
		return mapSection
	}

	;Add each item for a specific section to a map to loop through. is takes advantage of maps auto sorting.
	static GetItemsByTab(pmapAllItems, pstrTab)
	{
		mapOrder := Map()
		
		for strSection in pmapAllItems
		{
			if pmapAllItems[strSection].has("Tab") AND pmapAllItems[strSection]["Tab"]=pstrTab
				mapOrder.set(Number(pmapAllItems[strSection]["Order"]),strSection)
		}
		
		return mapOrder
		
	}

	;******************************
	;****** Events when clicked ***
	;******************************
	;pstrgui : The gui we are going to add items ToCodePage
	;pstrType : The type used to determine which box to display for editting
	;pstrDecode : Value to show the user when changing 
	;pstrINISection : Section to read from the ini file
	;pstrINIKey : Key to read from the ini file
	;pstrOption : used to align Lines
	;plngEditLength : length to display when using InputBox
	 static AddLineItem(pgui,pstrType, pstrDecode,pstrIniSection, pstrIniKey,pstrOption,plngDisplayLength,plngEditLength:=300)
	{		

		;pstrOption Should either be 'Section' for the first entry, and 'xs' for each additional one
		lblItem := pgui.AddText(pstrOption " w70" ,pstrDecode)
		lnkItem := pgui.AddText("x+10","Change")
		lnkItem.SetFont("cBlue")
		txtItem := pgui.AddText("x+10 w" plngDisplayLength, this.iniGetValue(pstrIniSection,pstrIniKey))
		
		lnkItem.OnEvent("Click", (*) => this.ChangeValue(pstrType,txtItem,pstrDecode, pstrIniSection,pstrIniKey,plngEditLength))

	}

	static ChangeValue(pstrType,ptxtItem,pstrDecode, pstrIniSection,pstrIniKey, plngLength:=200)
	{

		
		SWITCH pstrType
		{
			CASE "TextEdit":
				strValue := InputBox("", pstrDecode, "w" plngLength " h75", ptxtItem.Value)
				if strValue.Result = "OK"
				{
					ptxtItem.value := strValue.Value
					iniWrite strValue.Value, this.mstrINIConfigFile,pstrIniSection,pstrIniKey
				}
			CASE "FileSelection":
				strSelectedFile := FileSelect("35",ptxtItem.value)
				if strSelectedFile != ""
				{
					ptxtItem.value := strSelectedFile
					iniWrite strSelectedFile, this.mstrINIConfigFile,pstrIniSection,pstrIniKey
				}
			CASE "DirSelection":
				SelectedFolder := DirSelect("*" ptxtItem.value,0,"Select folder for: " pstrDecode) ;[StartingFolder, Options, Prompt])
				if SelectedFolder != ""
					{
					ptxtItem.value := SelectedFolder
					iniWrite SelectedFolder, this.mstrINIConfigFile,pstrIniSection,pstrIniKey
				}
			Default:
				msgbox "Invalid Type passed in"
		}
	}


	;***********************
	;**** Methods **********
	;***********************
	static iniGetValue(pstrSection, pstrKey)
	{
		strValue := iniRead(this.mstrINIConfigFile,pstrSection,pstrKey,"{Click to set}")
		if trim(strValue) = ""
		{
			strValue := "{Click to set}"
		}
		return strValue
	}	
	
	;**************************
	;**** Gui things **********
	;**************************
	static CloseGui(pgui)
	{
		pgui.Destroy()
		this.mblnCreated := False
		
		
	}
}