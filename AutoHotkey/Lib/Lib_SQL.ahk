SendMode "Input"
#Include Lib_SQL_Helpers.ahk
#Include Lib_BaseFunctions.ahk
#Include Lib_Globals.ahk

Class SQL
{
	static ListToCommaDelimited(pstrDelimiter:=",",pstrPre:="",pstrPost:="")
	{
		strColumns := A_Clipboard

		;Remove all new lines and put onto a single line
		;Split by the normal carriage return & line feed, then by each individually.
		astrColumns:= strSplit(strColumns, [chr(13) chr(10), chr(10), chr(13)])
		
		;reset string back to blank
		strDelimitedString := ""
		blnIsString := False
		
		;Loop through and build final string
		for index, element in astrColumns ; Enumeration is the recommended approach in most cases.
		{
			;Skip empty elements
			element := RegExReplace(element, "^\s+")
			element := RegExReplace(element, "\s+$")
			IF (element != "")
			{
				;MsgBox % "Element number " . index . " is " . element
				strDelimitedString .= pstrPre
				strDelimitedString .= element
				strDelimitedString .= pstrPost
				strDelimitedString .= pstrDelimiter
				
				if !isNUmber(element)
				{
					blnIsString := True
				}
			}
			
		}
		
		strDelimitedString := RegExReplace(strDelimitedString,",$")
		
		if blnIsString
		{
			if (pstrPre != "" AND pstrPost != "")
			{
			strDelimitedString := strReplace(strDelimitedString,pstrPre,pstrPre "'")
			strDelimitedString := strReplace(strDelimitedString,pstrPost,"'" pstrPost)
			;strDelimitedString := "'" strDelimitedString "'"
			}
			else
			{
				strDelimitedString := "'" strReplace(strDelimitedString,",","','") "'"
			}
		}
		
		BaseFunctions.SimpleSend(strDelimitedString)
	}


	;**********************
	;***** SQL Query ******
	;**********************
	;SQL Query
	static Date_HighDate()
	{
		BaseFunctions.SimpleSend("'9999-12-31'")
	}

	static Date_FirstDayOfYear()
	{
		strOutputVar := FormatTime(A_Now, "yyyy-01-01")
		
		BaseFunctions.SimpleSend("'" strOutputVar "'")
	}
	static Date_Today()	
	{
		strOutputVar := FormatTime(A_Now, "yyyy-MM-dd")
		BaseFunctions.SimpleSend("'" strOutputVar "'")
	}

	;**********************
	;***** SQL Nolock ******
	;**********************
	;SQL count
	static Count()
	{
		;SendInput, COUNT(1)
		BaseFunctions.SimpleSend("COUNT(1)")
	}

	;**********************
	;***** SQL Nolock ******
	;**********************
	;SQL Query
	static NoLock()
	{
		;SendInput, (NOLOCK)
		BaseFunctions.SimpleSend("(NOLOCK)")
	}

	;********************************************
	;***** SQL Isolation Level Uncommitted ******
	;********************************************
	;SQL Query
	static NoLock_All_Tables()
	{
		;SendInput, SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BaseFunctions.SimpleSend("SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED")
	}
	  
	;****************************
	;** SQL Information Schema **
	;****************************
	static Information_Schema_Base()
	{
		
		BaseFunctions.SimpleSend("SELECT	*`rFROM	INFORMATION_SCHEMA.COLUMNS `rWHERE	TABLE_NAME LIKE `'`%`%`' `rAND 	COLUMN_NAME LIKE `'`%`%`'")
	}

	;****************************
	;** SQL ZAudit data        **
	;****************************
	static ZAudit()
	{

		BaseFunctions.SimpleSend("SELECT	*`rFROM	ZAUDIT_LOG zl INNER JOIN`r		ZAUDIT_DATA zd`r	ON zl.fstrId = zd.fstrId `rWHERE	zl.fstrTable LIKE `'`%`%`'`rAND		zd.fstrLogData LIKE `'`%`%`'`rAND		zl.fdtmWhen>='12/31/9999'`rAND		zl.fstrLogin  LIKE `'`%`%`'`rORDER BY fdtmWhen")
	}
	;**********************
	;** SQL transaction ***
	;**********************
	static Trans_Block()
	{
		BaseFunctions.SimpleSend("BEGIN TRAN`r--ROLLBACK`r--COMMIT")
		SendInput "{up}{up}{end}`r`t"
		;SendInput, BEGIN TRAN`r--ROLLBACK`r--COMMIT{up}{up}{end}{enter}{tab}
	}

	;**********************
	;** SQL select ********
	;**********************
	static Select_Statement()
	{
		;SendInput, SELECT 	*`rFROM{Tab} ;(NOLOCK){LEFT}{LEFT}{LEFT}{LEFT}{LEFT}{LEFT}{LEFT}{LEFT}{LEFT}
		BaseFunctions.SimpleSend("SELECT 	*`rFROM`t")
	}

	static Select_Top_Statement(intAmt)
	{
		;SendInput, SELECT 	TOP %intAmt% *`rFROM{Tab} ;(NOLOCK){LEFT}{LEFT}{LEFT}{LEFT}{LEFT}{LEFT}{LEFT}{LEFT}{LEFT}
		BaseFunctions.SimpleSend("SELECT 	TOP " intAmt " *`rFROM`t")
	}

	;**********************
	;** SQL like **********
	;**********************
	static Like()
	{
		; strLike:= "like "Chr(39)chr(37)chr(37)chr(39)
		; SendInput  %strLike%{left}{left}
		BaseFunctions.SimpleSend("like " Chr(39) chr(37) chr(37) chr(39))
		SendInput "{left}{left}"
	}

	static CTE_User()
	{
		strUser := "WITH CTE_User AS ("
		strUser .= "`n`tSELECT	fstrUser,"
		strUser .= "`n`t`t`tfstrFirstName,"
		strUser .= "`n`t`t`tfstrFamilyName,"
		strUser .= "`n`t`t`tfstrFirstName + ' ' + fstrFamilyName + ' (' + fstrUser +')' as fstrDecode"
		;strUser .= "`n`tFROM	[SYSTEM].tblUser "
		strUser .= "`n`tFROM	"

		;At this point we could attempt to add the lookup, but it is still really hacky
		strUser .="[System]"
		strUser .= ".tblUser "
		strUser .= "`n`tWHERE	flngVer = 0)"

		BaseFunctions.SimpleSend(strUser)
	}

	;**********************
	;** SQL like **********
	;**********************
	static spWho()
	{
		
		strSpWho := "CREATE TABLE #sp_who2 ("
		strSpWho .= "`n`t`tSPID INT,Status VARCHAR(255),"
		strSpWho .= "`n`t`tLogin  VARCHAR(255),HostName  VARCHAR(255),"
		strSpWho .= "`n`t`tBlkBy  VARCHAR(255),DBName  VARCHAR(255),"
		strSpWho .= "`n`t`tCommand VARCHAR(255),CPUTime INT,"
		strSpWho .= "`n`t`tDiskIO INT,LastBatch VARCHAR(255),"
		strSpWho .= "`n`t`tProgramName VARCHAR(255),SPID2 INT,"
		strSpWho .= "`n`t`tREQUESTID INT)"
		strSpWho .= "`n`t`tINSERT INTO #sp_who2 EXEC sp_who2"

		strSpWho .= "`nSELECT"     
		strSpWho .= "`n			ISNULL(U.fstrUser,'') AS fstrUser,"
		strSpWho .= "`n			ISNULL(U.fstrFamilyName,'') AS fstrFamilyName,"
		strSpWho .= "`n			ISNULL(U.fstrFirstName,'') AS fstrFirstName,"
		strSpWho .= "`n			#sp_who2.*"
		strSpWho .= "`nFROM        #sp_who2"
		strSpWho .= "`n			LEFT OUTER JOIN RDD_GTSYS..tblUser U"
		strSpWho .= "`n				ON #sp_who2.[Login] = 'NET\' + U.fstrUser"
		strSpWho .= "`n				AND	U.flngVer = 0"
		strSpWho .= "`n-- Add any filtering of the results here :"
		strSpWho .= "`nWHERE       DBName = 'RDD_GTAPP'"
		strSpWho .= "`n-- Add any sorting of the results here :"
		strSpWho .= "`nORDER BY    BlkBy desc, SPID ASC"

		strSpWho .= "`nDROP TABLE #sp_who2"
		
		BaseFunctions.SimpleSend(strSpWho)
		
	}

	;***********************
	;** SQL group **********
	;***********************
	static GroupBy()
	{		
		BaseFunctions.SimpleSend("GROUP BY ")
	}

	;***********************
	;** SQL ver** **********
	;***********************
	static Ver()
	{		
		BaseFunctions.SimpleSend("flngVer = 0")
	}

	;**********************
	;** SQL parameters ****
	;**********************
	static Parameters_GetList()
	{
		BaseFunctions.Clipboard_Save()	
		A_Clipboard := ""
		
		SENDInput "^c"
		Clipwait
		
		strQuery := A_Clipboard
		
		arrParameter := []

		lngParameterPosition := InStr(strQuery,"@")
		
		strParameterRegEx := "(@[A-Za-z0-9_]+)"
		
		while lngParameterPosition > 0
		{

			SkipParameter := 0
			;Find all parameters
			strParameter := SubStr(strQuery, lngParameterPosition)
		

			lngFoundPos := RegExMatch(strParameter, strParameterRegEx, &strMatch)
			strParameter := strMatch[0]
			;Check if parameter already exists, then add it
			if strParameter != ""
			{
				IF (NOT (SQL.ValExists(arrParameter,strParameter)))
				{
					arrParameter.Push(strParameter)
				}
			}

			
			lngParameterPosition := InStr(strQuery,"@", false, lngParameterPosition + 1)
		}
		

		sqlVariablesDeclare := ""
		For index, element in arrParameter
		{
			Switch format("{:L}",substr(element,2,4))
			{
				Case "pstr" : sqlVariablesDeclare .= "DECLARE " element " AS VARCHAR(MAX) = ''`n"
				case "pi64": sqlVariablesDeclare .= "DECLARE " element " AS BIGINT = 0`n"
				Case "pint": sqlVariablesDeclare .= "DECLARE " element " AS INTEGER = 0`n"
				Case "plng": sqlVariablesDeclare .= "DECLARE " element " AS INTEGER = 0`n"
				Case "pcur": sqlVariablesDeclare .= "DECLARE " element " AS MONEY = 0`n"
				case "pbln": sqlVariablesDeclare .= "DECLARE " element " AS TINYINT = 1`n"
				case "pdtm": 
					IF(inStr(Element,"RunDate")>1)
					{
						sqlVariablesDeclare .= "DECLARE " element " AS DATETIME = GetDate()`n"
					}
					Else
					{
						sqlVariablesDeclare .= "DECLARE " element " AS DATETIME = '9999-12-31'`n"
					}
				
			}
		}
		
		;Add additional newlines
		sqlVariablesDeclare .= "`n"

		;Append strQuery to the declaration items
		sqlVariablesDeclare .= strQuery
		
		;Assign everything back to strQuery
		A_Clipboard := ""
		A_Clipboard := sqlVariablesDeclare
		Clipwait

		SENDInput "^v"
			
		BaseFunctions.Clipboard_Restore()

	}

	;****************************************
	;** SQL parameters as called by code ****
	;****************************************
	static Parameterization()
	{
		BaseFunctions.Clipboard_Save()

		A_Clipboard := ""
		SENDInput "^c"
		Clipwait
		
		strQuery := A_Clipboard
		
		
		arrParameter:= [] ;Holds the parameters as we parse through
		ReplacementParameter := 0
		
		;Find first position of variable
		lngParameterPosition := InStr(strQuery,"@")
		strParameterRegEx := "(@[A-Za-z0-9_]+)"
		
		While lngParameterPosition > 0
		{
			strParameter := SubStr(strQuery, lngParameterPosition)
			
			;Get ending position of variable
			strParameter := SubStr(strQuery, lngParameterPosition)
		
			lngFoundPos := RegExMatch(strParameter, strParameterRegEx, &strMatch)
			strParameter := strMatch[0]
			
			arrParameter.Push(strParameter)
			
			ReplacementParameter := arrParameter.Length
			strQuery := SQL.ReplaceAtPos(strQuery, lngParameterPosition+1,SQL.ConvertReplacementParameter(&ReplacementParameter),Strlen(strParameter)-1)
				
			;Loop, set next position
			lngParameterPosition := InStr(strQuery,"@", false, lngParameterPosition + 1)
		}
		
		strQuery := strReplace(strQuery, chr(39), chr(39) chr(39),0)

		;Build initial exection
		strFinalOutPut := "sp_executeSQL N'`n"
		
		;Assign query in strQuery to output
		strFinalOutPut .= strQuery
		
		;Build Variable list and list of values
		sqlVariables := ""
		sqlValues := ""
		For index, element in arrParameter
		{
			Switch format("{:L}",substr(element,2,4))
			{
				Case "pstr" : 
					sqlVariables .= "@" SQL.ConvertReplacementParameter(&index) " nvarchar(max),`n"
					sqlValues .= "N'',`n"
				case "pi64": 
					sqlVariables .= "@" SQL.ConvertReplacementParameter(&index) " bigint,`n"
					sqlValues .= "0,`n"
				case "pint": 
					sqlVariables .= "@" SQL.ConvertReplacementParameter(&index) " integer,`n"
					sqlValues .= "0,`n"
				case "plng": 
					sqlVariables .= "@" SQL.ConvertReplacementParameter(&index) " integer,`n"
					sqlValues .= "0,`n"
				case "pbln": 
					sqlVariables .= "@" SQL.ConvertReplacementParameter(&index) " tinyint,`n"
					sqlValues .= "0,`n"
				case "pdtm": 
					sqlVariables .= "@" SQL.ConvertReplacementParameter(&index) " datetime,`n"
					sqlValues .= "'9999-12-31 00:00:00.000',`n"
				case "pcur": 
					sqlVariables .= "@" SQL.ConvertReplacementParameter(&index) " money,`n"
					sqlValues .= "0.0,`n"
				
			}
		}
		
		;Build closing quote, comma and new line and opening quote
		strFinalOutPut .= chr(39) ;single quote
		
		IF(arrParameter.Length<=0)
		{
			sqlVariables := ""
			sqlValues := ""
			
		}
		ELSE {
			;Remove trailing comma and newline
			sqlVariables := substr(sqlVariables,1,StrLen(sqlVariables)-2)
			sqlValues := substr(sqlValues,1,Strlen(sqlValues)-2)
			
			;Add comma and opening section for variables list
			strFinalOutPut .= ",`nN'"
			
			;Add variables list
			strFinalOutPut .= sqlVariables
			
			;Close quote 
			strFinalOutPut .="',`n"
			
			;Build Value list
			strFinalOutPut .=sqlValues
		}
		
		A_Clipboard := ""
		A_Clipboard := strFinalOutPut
		Clipwait
		
		SENDInput "^v"
		
		BaseFunctions.Clipboard_Restore()
	}	

	;******************************
	;** Human readable columns ****
	;******************************
	static RenameColumns_HumanFriendly()
	{
		BaseFunctions.Clipboard_Save()
		A_Clipboard := ""
		SENDInput "^c"
		ClipWait
		
		
		strColumns := A_Clipboard
		;stringCaseSense, off
		
		;strRegexNeedle := "iO)((fstr|flng|fi64|fint|fcur|fbln|fdtm)\w+)(?!\s+AS\s+)"
		strRegexNeedle := "i)((\w+\.)?(fstr|flng|fi64|fint|fcur|fbln|fdtm)\w+)"
		
		
		lngFoundPos := RegExMatch(strColumns, strRegexNeedle, &strMatched,1)
				
		;strDebug := ""
		
		;seems to fail when it loops through 12 times
		While lngFoundPos > 0
		{
			;Here is where we should check if we have a prefix for the table first		
			strBaseName := ""
			arrName := strSplit(strMatched[0],".")
			if arrName.length = 1
				strBaseName := arrName[1]
			ELSE
				strBaseName := arrName[2]
				
			
			;strDebug .= "Pos:" lngFoundPos "`nClip:`n" strColumns
			switch strBaseName
			{
				Case "flngCustomerKey":
					lngFoundPos := lngFoundPos + 32
					lngFoundPos := lngFoundPos + strMatched.Len(1)
					strColumns:= RegExReplace(strColumns,strRegexNeedle, "'\C' + CAST($1 AS VARCHAR(MAX)) AS " SQL.FormatColumnName(strMatched[1],&lngFoundPos),,1,strMatched.Pos(0))
								
				Case "flngAccountKey":
					lngFoundPos := lngFoundPos + 32
					lngFoundPos := lngFoundPos + strMatched.Len(1)
					strColumns:= RegExReplace(strColumns,strRegexNeedle, "'\A' + CAST($1 AS VARCHAR(MAX)) AS " SQL.FormatColumnName(strMatched[1],&lngFoundPos),,1,strMatched.Pos(0))
				
				Default:
					lngFoundPos := lngFoundPos + strMatched.Len(1)
					strColumns:= RegExReplace(strColumns,strRegexNeedle, "$1 AS " SQL.FormatColumnName(strMatched[1],&lngFoundPos),,1,strMatched.Pos(0))
					
					
			}
			;msgbox % strColumns
			lngFoundPos := RegExMatch(strColumns, strRegexNeedle, &strMatched,lngFoundPos-1)
				
		}
		
		;msgbox % strDebug
			
		A_Clipboard := ""
		A_Clipboard := strColumns
		Clipwait
			
		SENDInput "^v"
		
		BaseFunctions.Clipboard_Restore()
		
	}
	
	static AddDefaultsToSelect()
	{
		BaseFunctions.Clipboard_Save()
		A_Clipboard := ""
		SENDInput "^c"
		ClipWait
		;---------------------------------
		
		
		strColumns := A_Clipboard
		;stringCaseSense, off
		
		;strRegexNeedle := "iO)((fstr|flng|fi64|fint|fcur|fbln|fdtm)\w+)(?!\s+AS\s+)"
		strRegexNeedle := "i)((\w+\.)?(fstr|flng|fi64|fint|fcur|fbln|fdtm)\w+)"
		
		
		lngFoundPos := RegExMatch(strColumns, strRegexNeedle, &strMatched,1)

		strDebug := ""
		
		;seems to fail when it loops through 12 times
		While lngFoundPos > 0
		{
			;Here is where we should check if we have a prefix for the table first		
			strBaseName := 
			arrName := strSplit(strMatched[0],".")

			if arrName.Length = 1
				strBaseName := arrName[1]
			ELSE
				strBaseName := arrName[2]
							
			switch subStr(strBaseName,2,3)
			{
				CASE "lng","int","i64","cur":
					lngFoundPos += 5 + strMatched.Len(0)
					strColumns := RegExReplace(strColumns,strRegexNeedle, "0 AS " strMatched[0],,1,strMatched.Pos(0))
					
				CASE "bln":
					lngFoundPos += 5 + strMatched.Len(0)
					strColumns := RegExReplace(strColumns,strRegexNeedle, "0 AS " strMatched[0],,1,strMatched.Pos(0))
					
				CASE "dtm":
					lngFoundPos += 16 + strMatched.Len(0)
					strColumns := RegExReplace(strColumns,strRegexNeedle, "'9999-12-31' AS " strMatched[0],,1,strMatched.Pos(0))
					
				DEFAULT:
					lngFoundPos += 5 + strMatched.Len(0)
					strColumns := RegExReplace(strColumns,strRegexNeedle, "'' AS " strMatched[0],,1,strMatched.Pos(0))
					
			}
		
			lngFoundPos := RegExMatch(strColumns, strRegexNeedle, &strMatched,lngFoundPos-1)
				
		}
		
		;---------------------------------
		A_Clipboard := ""
		A_Clipboard := strColumns
		Clipwait
			
		SENDInput "^v"
		
		BaseFunctions.Clipboard_Restore()	
	}
	;--------------------------------
		
	static ReplaceAtPos(pstrLine, pos, pstrReplacement, plngLength:=1)
	{
	
		;new below
		if Pos > strLen(pstrLine) +1 -plngLength
		{
			return pstrLine
		}
		Else
		{
			return substr(pstrLine,1,pos-1) pstrReplacement Substr(pstrLine, pos + plngLength)
		}
	}
	static ConvertReplacementParameter(&plngNumber)
	{
		plngNumber := plngNumber+64
		If plngNumber<65
		{
			Return "A"
		}
		ELSE IF plngNumber > 90
		{
			;Needs work. Should probably do something like if past Z, the create AA and build. So this would work well using modulus calculation. Too lazy now.
			
		}
		Else
		{
			return CHR(plngNumber)
		}
	}

	static ValExists(parrArray, pstrParameter)
	{
		for Index, element in parrArray
		{
			element := strUpper(element)
			pstrParameter := strUpper(pstrParameter)
			
			if(element == pstrParameter)
			{
				Return True
			}
		}
		Return False
	}

	static FormatColumnName(pstrColumnName,&plngLength:=0)
	{
		pstrColumnName := "[" SQL_Helper.HumanReadable(pstrColumnName) "]"
		
		plngLength := plngLength + strLen(pstrColumnName)
		
		Return pstrColumnName
	}

	static LogicalTable_To_Decode(pstrEnv,pblnGentaxFormat)
	{	
		BaseFunctions.Clipboard_Save()
		A_Clipboard :=""
		;Send ^a
		SENDInput "^c"
		Clipwait
		
		;Check the size of the clipboard, exit
		lngClipSize:= strLen(A_Clipboard)
		IF(lngClipSize=0)
		{
			BaseFunctions.Clipboard_Restore()
			Exit
		}
		List_Of_Environments := Globals.GetEnvironmentDecodeList(pstrEnv)

		Loop parse List_Of_Environments, "`n", "`r"
		{
			;New Method
			astrReplace_Fields := StrSplit(A_LoopField,"=")
			strReplace_Description := astrReplace_Fields[1]
			strReplace_Value := astrReplace_Fields[2]
			
			
			if(pblnGentaxFormat)
			{
				A_Clipboard := Strreplace(A_Clipboard, strReplace_Value, "[" strReplace_Description "]")
			}
			else
			{
				A_Clipboard := StrReplace(A_Clipboard, "[" strReplace_Description "]", strReplace_Value)
			}
		}

		SENDInput "^v"
		BaseFunctions.Clipboard_Restore()
	}

	; ;This should be setup to only work in SQL Server 2012 because of the limitation of getting the DB name
	; ChangeDatabase(pstrEnv, pstrDB)
	; {
		; GetKeyState, KeyState, Alt	
		; if KeyState = D 
		; {
			; WinGetActiveTitle, Title
			; IF InStr(Title,"Microsoft SQL Server Management Studio") > 0
			; {
				; strEnv_DB:= GetEnvironmentDecode(pstrEnv,pstrDB)
				; SendInput  {Alt down}{Ctrl down}j{Ctrl up}{Alt up}
				; SendInput %strEnv_DB%{Enter}
			; }
		; }	
	; }

	; ;This should be setup to only work in SQL Server 2012
	static GetCurrentEnvironment(&pstrEnv)
	{
		;Hacky way of doing this, but simpliest way I found
		; WinGetActiveTitle, Title
		; IF InStr(Title,"Microsoft SQL Server Management Studio") > 0
		; {
				BaseFunctions.Clipboard_Save()
				; ;SQL 2012
				SendInput  "{Alt down}{Ctrl down}j{Ctrl up}{Alt up}"
				
				; ;SQL prior 2012, but there isn't really a way to copy the current text, so this is partially pointless
				; ;SendInput  {Ctrl down}U{Ctrl up}MN{Down}
				
				A_Clipboard :=""
				SendInput "^c"
				;SendInput  {Ctrl down}c{Ctrl up}
				ClipWait 1000
							
				SendInput "{Shift down}{Esc}{Shift Up}"
				pstrEnv := A_Clipboard
							
				; ; ; New method
				strEnv_Fields := StrSplit(pstrEnv,"_")
				pstrEnv := strEnv_Fields[1]
				
				; ; Old Method
				; StringSplit, strEnv_Fields, pstrEnv,"_"
				; pstrEnv := strEnv_Fields1
				
				BaseFunctions.Clipboard_Restore()
		;}
	}

	static GetServer(pstrEnvironment, pstrDB)
	{
		
		BaseFunctions.SimpleSend("[" Globals.GetGeneralConfigValue("SQL",pstrEnvironment "_Server_" pstrDB) "]")
	}
}