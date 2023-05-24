#Include Lib_BaseFunctions.ahk

Class StringHelper
{
	;*************************************
	;** str parse comma  in column form **
	;*************************************
	static CommaList_To_MultiRows()
	{	
		; WinGetActiveTitle, Title
		; IF InStr(Title,"Microsoft SQL Server Management Studio") > 0
		; {
		; }
		BaseFunctions.Clipboard_Save(RegExReplace(A_Clipboard, ",", ",`r"))
		SENDInput "^c"
		A_Clipboard:=RegExReplace(A_Clipboard, ",", ",`r") 
		SENDInput "^v"
		BaseFunctions.Pastewait()
		BaseFunctions.Clipboard_Restore()
	}

	;************************************
	;** format to multiline from comma **
	;************************************
	static CommaList_To_MultiLine()
	{
		BaseFunctions.Clipboard_Save()
		A_Clipboard := ""
		SENDInput "^c"
		Clipwait
		
		strValues := A_Clipboard

		strTitle := WinActive("A")
		IF InStr(strTitle,"Microsoft Visual Studio") > 0
		{	
			;strValues:=RegExReplace(strValues, ",", ", _`r") 
			strValues:=RegExReplace(strValues, ",", ",`r") 
		}
		else
		{		
			strValues:=RegExReplace(strValues, ",", ",`r") 
		}
		
		A_Clipboard := ""
		A_Clipboard := strValues
		Clipwait
		
		SENDInput "^v"
		BaseFunctions.Clipboard_Restore()
	}

	;******************************
	;** str parse comma -Remove ***
	;******************************
	static RemoveComma()
	{
		;removes comma's from highlighted text. useful for numbers
		BaseFunctions.Clipboard_Save()
		A_Clipboard :=""
		SENDInput "^c"
		Clipwait
		
		A_Clipboard:=RegExReplace(A_Clipboard, ",", "") 

		SENDInput "^v"

		BaseFunctions.Clipboard_Restore()
	}

	static CamelCaseToSpace(pstrField)
	{
		strParameterRegEx := "([a-z])([A-Z])"
		
		pstrField := TRIM(RegExReplace(pstrField, strParameterRegEx, "$1 $2"))
		
		strParameterRegEx := "[_]"
		pstrField := TRIM(RegExReplace(pstrField, strParameterRegEx, " "))
		
		Return pstrField
	}

	;------------------------------------------
	;**********************************
	;** str second copy/paste        **
	;**********************************
	; Copy_SecondForm()
	; {
		; BaseFunctions.Clipboard_Save()
		; SENDInput "^c"
		; ClipWait
		; Clipboard2 := ClipboardAll
		; BaseFunctions.Clipboard_Restore()
	; }

	; Paste_SecondForm()
	; {
		; BaseFunctions.Clipboard_Save()
		; Clipboard := Clipboard2
		; SENDInput "^v"
		; ClipWait
		; BaseFunctions.Clipboard_Restore()
	; }
}