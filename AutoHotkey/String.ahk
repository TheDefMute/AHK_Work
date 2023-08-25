#SingleInstance force  ; Ensures that only the last executed instance of script is running
#NoTrayIcon
SendMode "Input"  ; Recommended for new scripts due to its superior speed and reliability.

#Include Lib\Lib_String.ahk
;************************************
;** format to multiline from comma **
;************************************
!+M:: ;Comma - Comma delimited to multiline (VB) highlighted
{
	StringHelper.CommaList_To_MultiLine()
	
}

;******************************
;** str parse comma -Remove ***
;******************************
^+,:: ;Comma - Remove comma from highlighted
{
	StringHelper.RemoveComma()
	
}

^+v:: ;Convert -  Convert word from Camel Case to spaces (Buffer)
{
	SendInput StringHelper.CamelCaseToSpace(A_Clipboard)
	
}	