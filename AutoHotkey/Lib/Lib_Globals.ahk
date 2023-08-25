SendMode "Input"  ; Recommended for new scripts due to its superior speed and reliability.
;SetWorkingDir "Lib" ; Ensures a consistent starting directory.

; Globals_GetUserFullName()
; {
	; IF FileExist("Global.ini")	
	; {
		; Set_UserFullName := " "
		; IniRead, Set_UserFullName, Global.ini, Globals, UserFullName, %Set_UserFullName%
		; Return %Set_UserFullName%
	; }
; }

; Globals_WriteUserFullName(UserFullName)
; {
	; IF Not FileExist("Global.ini")
	; {
		; IniWrite, %UserFullName%, Global.ini, Globals , UserFullName
	; }
	; else
	; {
		; Set_UserFullName:= Globals_GetUserFullName()
		; If Set_UserFullName <> %UserFullName%
		; {
			; IniWrite, %UserFullName%, Global.ini, Globals , UserFullName
		; }
	; }
	; RETURN
; }
;-----------------------------------------------------------------------------------------
Class Globals{

	static chrSingleQuote := chr(39)
	static chrPercent := chr(37)

	Static GetEnvironmentDecode(pstrEnvironment, pstrKey)
	{
		; ;Create the file if it doesn't exist.
		; IF NOT FileExist("SQLEnvironments.ini")	
		; {
			; Create_EnvironmentIniFile()
		; }
		
		strSet_Value := " "
		strSet_Value := IniRead("SQLEnvironments.ini", pstrEnvironment, pstrKey)
		Return strSet_Value
	}
	Static GetEnvironmentDecodeList(pstrEnvironment)
	{
		strSet_Value := IniRead("SQLEnvironments.ini", pstrEnvironment)
		Return strSet_Value
	}

	Static WriteEnvironmentDecodes(pstrEnvironment, pstrLogical, pstrValue)
	{
		IniWrite pstrValue, "SQLEnvironments.ini", pstrEnvironment, pstrLogical
	}

	Static GetGeneralConfigValue(pstrSection, pstrKey)
	{
		;IniRead, strGet_Value, GeneralConfig.ini, %pstrSection%, %pstrKey%, %strGet_Value%
		strGet_Value := IniRead("GeneralConfig.ini", pstrSection, pstrKey)
		strGet_Value := RegExReplace( RegExReplace( strGet_Value, "^.+\K.(?<=;).+" ), "\s+$" ) 
		Return strGet_Value
	}

	Static GetIniValue(pstrFile,pstrSection, pstrKey)
	{
		strGet_Value := IniRead(pstrFile, pstrSection, pstrKey)
		;strGet_Value := RegExReplace( RegExReplace( strGet_Value, "^.+\K.(?<=;).+" ), "\s+$" ) 
		Return strGet_Value
	}
}