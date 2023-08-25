#Include Lib_Globals.ahk
Class FCore
{
	static GetUrlFromEnvAndSet(pstrEnvSet,pstrEnvironment,pstrKeyPrefix)
	{
		SWITCH pstrEnvSet
		{
			CASE "Prod Support":
				SWITCH pstrEnvironment
				{
					CASE "D":
						strURL := Globals.GetGeneralConfigValue("Core-ProdSupport",pstrKeyPrefix "_D")
					CASE "T":
						strURL := Globals.GetGeneralConfigValue("Core-ProdSupport",pstrKeyPrefix "_T")
					CASE "S":
						strURL := Globals.GetGeneralConfigValue("Core-ProdSupport",pstrKeyPrefix "_S")
					CASE "P":
						strURL := Globals.GetGeneralConfigValue("Core-ProdSupport",pstrKeyPrefix "_P")
					Default:
						Msgbox "Environment not configured: " pstrEnvironment
						Return
				}
			CASE "Upgrade":
				SWITCH pstrEnvironment
				{
					CASE "D":
						strURL := Globals.GetGeneralConfigValue("Core-Upgrade",pstrKeyPrefix "_D")
					CASE "T":
						strURL := Globals.GetGeneralConfigValue("Core-Upgrade",pstrKeyPrefix "_T")
					CASE "S":
						strURL := Globals.GetGeneralConfigValue("Core-Upgrade",pstrKeyPrefix "_S")
					CASE "P":
						strURL := Globals.GetGeneralConfigValue("Core-Upgrade",pstrKeyPrefix "_P")
					Default:
						Msgbox "Environment not configured: " pstrEnvironment
						Return
				}
			Default:
				msgbox "Env Set not configured: " pstrEnvSet
				Return
		}
		Return strURL
	}
}