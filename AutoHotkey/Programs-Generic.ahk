#SingleInstance force  ; Ensures that only the last executed instance of script is running
#NoTrayIcon

#Include Lib\Lib_Globals.ahk
;*********************
;*********************

;----------------------------------------------------------------------------------------------------------------------------	
^!I::		;Program - Browser
{
	;Run %A_ProgramFiles%\Internet Explorer\iexplore.exe
	
	;DB:=AssociatedProgram("htm")
	;IF (INSTR(DB,"Chrome")){
		run "chrome.exe --new-window "
	;}
	;else if (INSTR(DB,"iexplore")){
	;	Run %A_ProgramFiles%\Internet Explorer\iexplore.exe
	;}
	;Else{
	;	msgbox, Unknown default browser configured.
	;}
	
}
	
^!N::		;Program - Notepad++
{
	Run Globals.GetIniValue("Windows (Organize).ini","ProgramRun","NotepadPP")
}
	
^!S::		;Program - Sticky Notes
{
	Run Globals.GetIniValue("Windows (Organize).ini","ProgramRun","StickyNotes")
}

^+!S::		;Program - Snipping Tool
{
	Run A_WinDir "\System32\SnippingTool.exe"
}
	
^!O::	;Program - One Note
{
	Run  Globals.GetIniValue("Windows (Organize).ini","ProgramRun","OneNote")
}
;------------------------------------------

; !+C::		;Calculator
	; Run calc.exe 
	; Return
	
;------------------------------------------
	