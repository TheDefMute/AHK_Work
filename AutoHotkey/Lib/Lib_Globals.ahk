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
		; IF NOT FileExist("GentaxEnvironments.ini")	
		; {
			; Create_EnvironmentIniFile()
		; }
		
		strSet_Value := " "
		strSet_Value := IniRead("GentaxEnvironments.ini", pstrEnvironment, pstrKey)
		Return strSet_Value
	}
	Static GetEnvironmentDecodeList(pstrEnvironment)
	{
		strSet_Value := IniRead("GentaxEnvironments.ini", pstrEnvironment)
		Return strSet_Value
	}

	Static WriteEnvironmentDecodes(pstrEnvironment, pstrLogical, pstrValue)
	{
		IniWrite pstrValue, "GentaxEnvironments.ini", pstrEnvironment, pstrLogical
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
	; ;-------------------------------
	; ;DEVSQL03: 10.64.216.72
	; ;STGSQL01: 10.64.216.68
	; ;PRDSQL13: 10.64.216.113
	; ;PRDSQL10: 10.64.216.117
	 ; Create_EnvironmentIniFile()
	 ; {
		; ConnectString := "Provider=SQLOLEDB.1;Password=" . A_UserName . ";Persist Security Info=True;User ID=" . A_UserName . ";Initial Catalog=MND_GTSYS;Data Source=10.64.216.72;Use Procedure for Prepare=1;Auto Translate=True;Packet Size=4096;Use Encryption for Data=False;Tag with column collation when possible=False"
		
		; Query := "SELECT	* FROM	tblDatabase WHERE fstrEnvironment like 'M%'"
		
		; ;Retrieves the list of all logical data base names in an object
		; ObjectReturn := ADOSQL(ConnectString, Query)

		; ;Loop through each row and add to an ini file.
		; Loop % ObjectReturn.MaxIndex()
		 ; {
			; strLogical :=  ObjectReturn[A_Index,2]
			; strEnviron := ObjectReturn[A_Index,1]
			; strKey := ObjectReturn[A_Index,3]
			
			; WriteEnvironmentDecodes(strLogical, strEnviron, strKey)
		 ; }
		
		; strLogical:=
		; strEnviron:=
		; strKey:=
	; }	
}