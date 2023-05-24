SendMode "Input" ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force  ; Ensures that only the last executed instance of script is running
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
#NoTrayIcon

#Include Lib_String.ahk

Class SQL_Helper
{
	;Not sure what I am doing with this array yet...I had a plan but have forgotten
	; global mastrPrefix := []
	; mastrPrefix.Push("bln")
	; mastrPrefix.Push("cur")
	; mastrPrefix.Push("dtm")
	; mastrPrefix.Push("i64")
	; mastrPrefix.Push("int")
	; mastrPrefix.Push("lng")
	; mastrPrefix.Push("str")
	; mastrPrefix.Push("vnt")

	TypeDefault(pstrField)
	{
		strType := ""
		SWITCH substr(pstrField,1,1)
		{
			CASE "f","p": strType := substr(pstrField,2,3)
			DEFAULT: strType := substr(pstrField,1,3)
		}
		
		SWITCH strType
		{
			CASE "bln": RETURN TRUE
			CASE "cur","i64","int","lng": RETURN 0
			CASE "dtm": RETURN "12/31/9999"
			CASE "str": RETURN ""
			CASE "vnt": RETURN ""
			DEFAULT: 
			;throw Exception ("Invalid type: " strType)
		}
	}

	static HumanReadable(pstrField)
	{
		RETURN StringHelper.CamelCaseToSpace(SQL_Helper.GetBaseFieldName(pstrField))
	}

	;Used only in this code
	static GetBaseFieldName(pstrField)
	{	

		;Check if it is aliased with a table prefix
		lngFoundPos := instr(pstrField,".")
		
		If (lngFoundPos > 0)
		{
			pstrField :=	subStr(pstrField,lngFoundPos+1)
		}

		;If nothing, then just return itself
		IF(SQL_Helper.GetFieldType(pstrField) ="")
		{
			return pstrField
		}
		
		SWITCH substr(pstrField,1,1)
		{
			CASE "f","p": pstrField := substr(pstrField,5)
			DEFAULT: pstrField := substr(pstrField,4)
		}
		
		RETURN pstrField
	}

	static GetFieldType(pstrField)
	{
		astrPrefix := []
		astrPrefix.Push("bln")
		astrPrefix.Push("cur")
		astrPrefix.Push("dtm")
		astrPrefix.Push("i64")
		astrPrefix.Push("int")
		astrPrefix.Push("lng")
		astrPrefix.Push("str")
		astrPrefix.Push("vnt")

		;Check if it is aliased with a table prefix
		lngFoundPos := instr(pstrField,".")
			
		If (lngFoundPos > 0)
		{
			pstrField := subStr(pstrField,lngFoundPos+1)
		}
		
		;Remove prefix of f or p if passed in
		SWITCH substr(pstrField,1,1)
		{
			CASE "f","p": pstrField := substr(pstrField,2)
			DEFAULT: ;do nothing
		}
		
		;Check if it is already the basename
		FOR KEY, ELEMENT in astrPrefix
		{	
			IF (ELEMENT = substr(pstrField,1,3) )
			{
				RETURN ELEMENT
			}
		}
		RETURN ""
		
	}
}