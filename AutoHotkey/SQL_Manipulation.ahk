#SingleInstance force  ; Ensures that only the last executed instance of script is running
#NoTrayIcon
SendMode "Input" ; Recommended for new scripts due to its superior speed and reliability.
SetTitleMatchMode "REGEX"

#Include Lib\Lib_SQL.AHK


;***********************************
;** str parse comma SQL compliant***
;***********************************
!+,::  ;Convert - Columular Data to SQL-Compatible List (Paste buffer)
{
	SQL.ListToCommaDelimited()
}

;***********************************
;** str parse comma SQL compliant***
;***********************************
!+(::  ;Convert - Columular Data to SQL-Compatible List for use in value (Paste buffer)
{
	SQL.ListToCommaDelimited(",","(",")")
}

;**********************
;** SQL parameters ****
;**********************
!+R:: ;Convert - column names to human friendly (Highlighted)
{
	SQL.RenameColumns_HumanFriendly()
}

!+B:: ;Default - Next to the select statement, fields based on prefix type (Highlighted)
{
	SQL.AddDefaultsToSelect()
}
	
!+p:: ;Default - Get sql variables and declare at top of statement (Highlighted)
{
	SQL.Parameters_GetList()
}
	
!^+P:: ;Convert - Create SQL parameterization structure how it gets executed from code (Highlighted)
{
	SQL.Parameterization()
}
; Anything below this check will only work if SQL studio is active.	

; #HotIf WinActive("ahk_exe Ssms.exe")>0
; {
	; !+E::	;Convert - Parse out Logical table values for actual  (Highlighted)
	; {
		; ;To use this you will need to make sure two things are set
		; ; 1 - GeneralConfig.ini:Misc Section has an entry for BasEnv set to the first two letters of the environments
		; ; 2 - SQLEnvironments.ini exists and is populated with values for each envi in tblDataBase
		; strEnv :=""
		; ;SQL.GetCurrentEnvironment(&strEnv)
		; mguiConvertServer.Show
		; ;LogicalTable_To_Decode(strEnv,CBFormat)
	; }
	
; ConvertServerButtonInput(*)
; {
	; submitInfo := mguiConvertServer.Submit(true)
	; msgbox submitInfo.mbtnInput.value
	; ;SQL.LogicalTable_To_Decode(submitInfo.strEnv,submitInfo.CBFormat)
	
; }
	
; ConvertServerGuiEscape:
; {
	; Gui ConvertServer:Cancel
	
; }
	; !E::	;Parse out Logical table values for actual use current env
		; strEnv :=""
		; GetCurrentEnvironment(strEnv)
		; LogicalTable_To_Decode(strEnv,False)
		; return		
	
; CAPSLock & A:: ;This also uses ALT. This will change the server when SQL server is active to Application
	; strEnv :=""
	; GetCurrentEnvironment(strEnv)
	; ChangeDatabase(strEnv, "Application")
	; RETURN

; CAPSLock & R:: ;This also uses ALT. This will change the server when SQL server is active to reference
	; strEnv :=""
	; GetCurrentEnvironment(strEnv)
	; ChangeDatabase(strEnv, "CodeTable")
	; RETURN	
; 
;} ;end of winactive