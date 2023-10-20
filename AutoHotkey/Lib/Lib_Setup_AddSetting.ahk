#SingleInstance force  ; Ensures that only the last executed instance of script is running
#NoTrayIcon


Setup_AddSetting()
{
	guiAddSetting := gui()
	guiAddSetting.OnEvent("escape", (*) => Escape_AddSetting(guiAddSetting))

	guiAddSetting.AddText("w70" ,"Set")
	ddlSet := guiAddSetting.AddDropDownlist("x+10 vSetPath Choose1", ["Prod Support","Upgrade"])
	
	guiAddSetting.AddText("xs w70","Type")
	ddlType := guiAddSetting.AddDropDownlist("x+10 vType Choose1",["Settings","Links"])
	
	guiAddSetting.AddText("xs w70","Setting")
	ddlSettingsExisting := guiAddSetting.AddDropDownlist("x+10 vSettingsExisting Choose1",[])
	ddlSettingsExisting.Opt("+Disabled")
	
	guiAddSetting.AddText("xs w70","Env")
	ddlEnv := guiAddSetting.AddDropDownlist("x+10 vEnvironment",["D","T","S","P"])
	ddlEnv.Opt("+Disabled")
	
	ddlType.OnEvent("Change", (*)=> TypeChanged(ddlSet.Text,ddlType.Text, ddlEnv, ddlSettingsExisting))
	
	guiAddSetting.AddText("xs w70" ,"Display length")
	txtDisplayLength := guiAddSetting.AddEdit("x+10 w200 vDisplayLength","350")
	
	guiAddSetting.AddText("xs w70" ,"Edit length") ;Build from dropdown
	txtEditLength := guiAddSetting.AddEdit("x+10 w200 vEditLength","200")
	
	guiAddSetting.AddText("xs w70" ,"Decode") 
	txtDecode := guiAddSetting.AddEdit("x+10 w200 vDecode","")

	btnOK := guiAddSetting.AddButton("Default w80","OK")
	btnOK.OnEvent("Click", (*) => BuildSetupGeneralConfigFile(guiAddSetting))
	
	guiAddSetting.show
}

;Trigger building of links ddl or disabling depending on type choosen
TypeChanged(pstrSet, pstrType, pddlEnv, pddlSettingsExisting)
{
	SWITCH pstrType
	{
		CASE "Settings":
			pddlEnv.Opt("+Disabled")
			pddlEnv.Choose(0)
			
			pddlSettingsExisting.Opt("+Disabled")
			pddlSettingsExisting.Choose(0)
		CASE "Links":
			pddlEnv.Opt("-Disabled")
			pddlEnv.Choose(1)
			
			pddlSettingsExisting.Opt("-Disabled")
			SWITCH pstrSet
			{
				CASE "Prod Support":
					strSettings := iniRead("GeneralConfig.ini","ProdSupport-Settings")
				CASE "Upgrade":
					strSettings := iniRead("GeneralConfig.ini","Upgrade-Settings")
				Default:
					Msgbox "Something went wrong"
			}
			
			astrSettings := []
			loop parse strSettings,"`n","r"
			{
				astrSettings.push(strSplit(A_LoopField,"=")[2])
			}
			pddlSettingsExisting.Add(astrSettings)
			pddlSettingsExisting.Choose(1)
		Default:
			msgbox "Something went wrong"
	}
}

BuildSetupGeneralConfigFile(pguiAddSetting)
{
	SubmitInfo := pguiAddSetting.Submit(true)
	strIniSectionSetup := ""
	
	Switch SubmitInfo.SetPath
	{
		CASE "Prod Support":
			strIniSectionSetup := "Prod"
			
		CASE "Upgrade":
			strIniSectionSetup := "Upgrade"
			
		Default:
			msgbox "Things went wrong"
		
	}
	
	Switch SubmitInfo.Type
	{
		CASE "Settings":
			strIniSectionSetup .= " Settings"
		CASE "Links":
			strIniSectionSetup .= " Links_"
			;Will need to add to all envs
		Default:
			msgbox "Things went wrong"
	}
	strSetupIniSection := strIniSectionSetup SubmitInfo.Environment BuildSetupIniTitle(SubmitInfo.SetPath,SubmitInfo.Type,SubmitInfo.Environment)
	
	strWriteFile := "Setup_General Config.ini"
	;strWriteFile := "zTest.ini"
	IniWrite(BuildSetupIniTab(SubmitInfo.SetPath,SubmitInfo.Type, SubmitInfo.Environment),strWriteFile,strSetupIniSection,"Tab")
	IniWrite(BuildSetupIniOrder(strSetupIniSection,SubmitInfo.Environment),strWriteFile,strSetupIniSection,"Order")
	IniWrite("TextEdit",strWriteFile,strSetupIniSection,"Type")
	IniWrite(SubmitInfo.DisplayLength,strWriteFile,strSetupIniSection,"DisplayLength")
	IniWrite(SubmitInfo.EditLength,strWriteFile,strSetupIniSection,"EditLength")
	IniWrite(SubmitInfo.Decode,strWriteFile,strSetupIniSection,"Decode")
	IniWrite(BuildSetupIniSection(SubmitInfo.SetPath,SubmitInfo.Type,SubmitInfo.Environment),strWriteFile,strSetupIniSection,"Section")
	IniWrite(BuildSetupIniKey(SubmitInfo.SetPath, SubmitInfo.SettingsExisting),strWriteFile,strSetupIniSection,"Key")
	
	
}

;-------------------------------------------------------
	BuildSetupIniTitle(pstrSetPath, pstrType, pstrEnv)
	{
		strSection := ""
		SWITCH pstrSetPath
		{
			CASE "Prod Support":
				strSection := "Prod"
				
			CASE "Upgrade":
				strSection := "Upgrade"
				
			Default:
				msgbox "Things went wrong"
		}
		Switch pstrType
		{
			CASE "Settings":
				strSection .= " Settings"
			CASE "Links":
				strSection .= " Links_" pstrEnv
				;Will need to add to all envs
			Default:
				msgbox "Things went wrong"
		}
		astrSections := []
		
		loop parse,iniRead("Setup_General Config.ini"),"`n","`r"
		{
			if(inStr(A_LoopField,strSection)>0)
			{
				astrSections.push(A_LoopField)
			}
		}
		return astrSections.Length
	}
	BuildSetupIniTab(pstrSetPath, pstrType, pstrEnv)
	{
		if(pstrEnv="")
		{
			pstrEnv := "D"
		}
		SWITCH pstrSetPath
		{
			CASE "Prod Support":
				return "Prod " pstrType " (" pstrEnv ")"
				
			CASE "Upgrade":
				Return "Upgrade " pstrType " (" pstrEnv ")"
				
			Default:
				msgbox "Things went wrong"
		}
	}
	BuildSetupIniOrder(pstrSetupIniSection,pstrEnv)
	{
		strSearchString := substr(pstrSetupIniSection,1,instr(pstrSetupIniSection,"_")+1)

		lngMaxOrder := 0
		loop parse iniRead("Setup_General Config.ini"), "`n","`r"
		{
			IF(A_LoopField != strSearchString "0" AND A_LoopField != pstrSetupIniSection)
			{
				if(inStr(A_LoopField,strSearchString)>0)
				{
					lngOrder := IniRead("Setup_General Config.ini",A_LoopField,"Order")
					if(lngOrder > lngMaxOrder)
					{
						lngMaxOrder := lngOrder
					}
				}
			}
		}
		return lngMaxOrder+10
	}
	BuildSetupIniSection(pstrSetPath, pstrType, pstrEnv:="D")
	{
		strSection := ""
		SWITCH pstrSetPath
		{
			CASE "Prod Support":
				strSection := "ProdSupport"
				
			CASE "Upgrade":
				strSection := "Upgrade"
				
			Default:
				msgbox "Things went wrong"
		}
		Switch pstrType
		{
			CASE "Settings":
				strSection .= "-Settings"
			CASE "Links":
				strSection .= "-Links_" pstrEnv
				;Will need to add to all envs
			Default:
				msgbox "Things went wrong"
		}
		return strSection
	}
	BuildSetupIniKey(pstrSetPath, pstrSetting)
	{
		strSettings := ""
		strFoundSetting := ""
		SWITCH pstrSetPath
		{
			CASE "Prod Support":
				strSettings := iniRead("GeneralConfig.ini","ProdSupport-Settings")
			CASE "Upgrade":
				strSettings := iniRead("GeneralConfig.ini","Upgrade-Settings")
			Default:
				msgbox "Things went wrong"
		}
		
		loop parse strSettings,"`n","`r"
		{
			if(strSplit(A_LoopField,"=")[2]=pstrSetting)
			{
				strFoundSetting := strSplit(A_LoopField,"=")[1]
			}	
		}
		;if nothing is found, create new
		
		if strFoundSetting != ""
		{
			return strFoundSetting
		}
		Else
		{
			return "Setting" strsplit(strSettings,"`n","`r").length +1
		}
		
		
	
	}
;-------------------------------------------------------

Escape_AddSetting(pguiAddSetting)
{
	pguiAddSetting.Destroy
}
