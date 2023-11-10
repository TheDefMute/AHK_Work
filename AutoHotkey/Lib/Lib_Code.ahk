#Include Lib_BaseFunctions.ahk
#Include Lib_String.ahk

mchrDoubleQuote := chr(34)

Class Code
{
	;*************************************
	;** str parse comma  in column form **
	;*************************************
	CommaList_To_MultiRows()
	{	
		; WinGetActiveTitle, Title
		; IF InStr(Title,"Microsoft SQL Server Management Studio") > 0
		; {
		; }
		BaseFunctions.Clipboard_Save(RegExReplace(A_Clipboard, ",", ",`r"))
		SendInput "^c"
		A_Clipboard := RegExReplace(A_Clipboard, ",", ",`r") 
		SendInput "^v"
		BaseFunctions.Pastewait()
		BaseFunctions.Clipboard_Restore()
		RETURN
	}

	;************************************
	;** format to multiline from comma **
	;************************************
	CommaList_To_MultiLine()
	{
		BaseFunctions.Clipboard_Save()
		A_Clipboard := ""
		SendInput "^c"
		Clipwait
		
		strValues := A_Clipboard
		
		;WinGetActiveTitle Title
		msgbox "This needs to be looked at"
		strTitle := WinExist("A")
		If InStr(strTitle,"Microsoft Visual Studio") > 0
		{	
			strValues:=RegExReplace(strValues, ",", ", _`r") 
		}
		else
		{		
			strValues:=RegExReplace(strValues, ",", ",`r") 
		}
		
		A_Clipboard := ""
		A_Clipboard := strValues
		Clipwait
		
		SendInput "^v"
		BaseFunctions.Clipboard_Restore()
	}

	;******************************
	;** str parse comma -Remove ***
	;******************************
	RemoveComma()
	{
		;removes comma's from highlighted text. useful for numbers
		BaseFunctions.Clipboard_Save()
		A_Clipboard :=""
		SendInput "^c"
		Clipwait
		
		A_Clipboard := RegExReplace(A_Clipboard, ",", "") 

		SendInput "^v"

		BaseFunctions.Clipboard_Restore()
	}

	;**********************
	;** str fda prefix ****
	;**********************
	fdaFormat()
	{
	; Add fdaStuff around highlighted field using clipboard.
	;could convert this to use regex and make it cleaner
		If (InStr(A_Clipboard,"fda") > 0)
		{
			ClipboardOld := A_Clipboard
			SendInput "^c"
			If (InStr(A_Clipboard,"flng") > 0)
			{
				SendInput ClipboardOld ".lng(" mchrDoubleQuote A_Clipboard mchrDoubleQuote ")"
			}
			If (InStr(A_Clipboard,"fint") > 0)
			{
				SendInput ClipboardOld ".int(" mchrDoubleQuote A_Clipboard mchrDoubleQuote ")"
			}
			If (InStr(A_Clipboard,"fstr") > 0)
			{
				SendInput ClipboardOld ".str(" mchrDoubleQuote A_Clipboard mchrDoubleQuote ")"
			}
			If (InStr(A_Clipboard,"fdtm") > 0)
			{
				SendInput ClipboardOld ".dtm(" mchrDoubleQuote A_Clipboard mchrDoubleQuote ")"
			}
			If (InStr(A_Clipboard,"fbln") > 0)
			{
				SendInput ClipboardOld ".bln(" mchrDoubleQuote A_Clipboard mchrDoubleQuote ")"
			}
			If (InStr(A_Clipboard,"fvnt") > 0)
			{
				SendInput ClipboardOld ".obj(" mchrDoubleQuote A_Clipboard mchrDoubleQuote ")"
			}
			If (InStr(A_Clipboard,"fi64") > 0)
			{
				SendInput ClipboardOld ".i64(" mchrDoubleQuote A_Clipboard mchrDoubleQuote ")"
			}
		
			A_Clipboard := Clipboardold
		}
		RETURN
	}

	;------------------------------------------

	static DefaultXMLParameter()
	{
		BaseFunctions.Clipboard_Save()
		A_Clipboard := ""
		SendInput "^c"
		ClipWait

		strParameters := A_Clipboard
		;msgbox "Check this out"
		strRegexNeedle := "i)(name=" mchrDoubleQuote ")(p...)(\w+)(" mchrDoubleQuote ">)"
	
		strMatched := ""
		lngFoundPos := RegExMatch(strParameters, strRegexNeedle, &strMatched,1)

		; ;seems to fail when it loops through 12 times
		While lngFoundPos > 0
		{
		
			lngFoundPos := lngFoundPos + strMatched.Len(0) + strlen(StringHelper.CamelCaseToSpace(strMatched[3]))
			strParameters:= RegExReplace(strParameters,strRegexNeedle, "$0" StringHelper.CamelCaseToSpace(strMatched[3]),,1,strMatched.Pos(0))				
		
			lngFoundPos := RegExMatch(strParameters, strRegexNeedle, &strMatched,lngFoundPos-1)
		}


		A_Clipboard := ""
		A_Clipboard := strParameters
		Clipwait
			
		SendInput "^v"
		
		BaseFunctions.Clipboard_Restore()
	}
	
	Static DefaultBOParameter()
	{
		;Use paste buffer
		strInput := A_Clipboard
		;Remove anything before parameters
		strInput := RegExReplace(strInput,")^.+\(","")
		;Remove last paran if it exists
		strInput := RegExReplace(strInput,")(.+)\)","$1")
		
		strParameters := ""
		Loop parse, strInput, "`n", "`r"
		{
			if(Trim(A_LoopField)="")
			{
				Continue
			}
			astrValues := []
			astrValues := strsplit(trim(A_LoopField)," ")
			Switch astrValues.Length
			{
				case 3:
					;Assumption is that it is not using the byref/byval
					strParameters .= astrValues[1] ":=" this.GetDefaultFromType(Trim(astrValues[3],",")) ',`r'
					
				case 4:
					;Assumption is that it IS using byref/byval
					strParameters .= astrValues[2] ":=" this.GetDefaultFromType(Trim(astrValues[4],",")) ',`r'
					
				Case 6:
					;assumption is that this is an optional parameter
					strParameters .= astrValues[2] ":=" Trim(astrValues[6],",") ',`r'
					
				Case 7:
					;assumption is that this is an optional parameter
					strParameters .= astrValues[3] ":=" Trim(astrValues[7],",") ',`r'
					
				Default:
					msgbox "Line: " A_Index " has value " A_LoopField " which does not conform to the format we are expecting."
					Exit
			}
		}
		;Need to remove newline and last comma
		strParameters := substr(strParameters,1,StrLen(strParameters)-2)
		BaseFunctions.SimpleSend(strParameters)
	}
	
	static GetDefaultFromType(pstrType)
	{
		Switch pstrType,0
		{
			case "boolean":
				return "True"
			case "date","datetime":
				return "HighDate"
			Case "int","int16","int32","int64":
				Return "0"
			case "string":
				Return "String.Empty"
			default:
				Return "Nothing"
		}
	}
}
