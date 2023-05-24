#Include Lib_Globals.ahk
Class Gentax
{
	static GetUrlFromEnvAndSet(pstrEnvSet,pstrEnvironment,pstrKeyPrefix)
	{
		SWITCH pstrEnvSet
		{
			CASE "Prod Support":
				SWITCH pstrEnvironment
				{
					CASE "D":
						strURL := Globals.GetGeneralConfigValue("Gentax-ProdSupport",pstrKeyPrefix "_D")
					CASE "T":
						strURL := Globals.GetGeneralConfigValue("Gentax-ProdSupport",pstrKeyPrefix "_T")
					CASE "S":
						strURL := Globals.GetGeneralConfigValue("Gentax-ProdSupport",pstrKeyPrefix "_S")
					CASE "P":
						strURL := Globals.GetGeneralConfigValue("Gentax-ProdSupport",pstrKeyPrefix "_P")
					Default:
						Msgbox "Environment not configured: " pstrEnvironment
						Return
				}
			CASE "Upgrade":
				SWITCH pstrEnvironment
				{
					CASE "D":
						strURL := Globals.GetGeneralConfigValue("Gentax-Upgrade",pstrKeyPrefix "_D")
					CASE "T":
						strURL := Globals.GetGeneralConfigValue("Gentax-Upgrade",pstrKeyPrefix "_T")
					CASE "S":
						strURL := Globals.GetGeneralConfigValue("Gentax-Upgrade",pstrKeyPrefix "_S")
					CASE "P":
						strURL := Globals.GetGeneralConfigValue("Gentax-Upgrade",pstrKeyPrefix "_P")
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