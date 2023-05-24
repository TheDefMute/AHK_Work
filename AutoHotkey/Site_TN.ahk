SendMode "Input" ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
#SingleInstance force  ; Ensures that only the last executed instance of script is running
#NoTrayIcon

; ^+X::
; {
	; strChallengePhrase := "This is a test [A1] [B2] [C3] and some other stuff."
	; strChallengeResponse :=  GetChallengeResponse(strChallengePhrase)
	; msgbox strChallengeResponse
; }

;#IfWinActive,ahk_exe vpnui.exe
#HotIf WinActive("ahk_exe vpnui.exe")>0
{
; #C:: ;Prompt for TN Challenge
		; strChallengeResponse := GetChallengeResponse(Clipboard)
	
	; IF (strChallengeResponse = "")
	; {
		; MsgBox Code not found
	; }
	; ELSE
	; {
		; Clipboard = %strChallengeResponse%
	; }

	
	; Return


	^V:: ;VPN - Uses clipboard and pastes response for challenge
	{
		strChallengeResponse := GetChallengeResponse(A_Clipboard)
		
		IF (strChallengeResponse = "")
		{
			MsgBox "Code not found"
		}
		ELSE
		{
			SendInput strChallengeResponse
			;msgbox strChallengeResponse
		}
		
		
		Return
	}

} ; End of winactive
	
GetChallengeConfigValue(pstrSection, pstrKey)
{
	strGet_Value := IniRead("TN_Challenge.ini",pstrSection, pstrKey)
	strGet_Value := RegExReplace( RegExReplace( strGet_Value, "^.+\K.(?<=;).+" ), "\s+$" ) 
	Return strGet_Value
}

GetChallengeResponse(pstrHaystack)
{
	;pstrHayStack := "This is a test [A1] [B2] [C3] and some other stuff."
	strNeedleRegEx := "(\[[A-Z][0-9]\] ?){3}"
	lngFoundPos := RegExMatch(pstrHaystack, strNeedleRegEx, &strChallengePhrase)
	
	IF (lngFoundPos = 0)
	{
		Return ""
	}
	ELSE
	{
		strChallengePhrase := strReplace(strReplace(StrReplace(strChallengePhrase[0], "[" ),"]")," ")

		strChallengeResponse := ""
			
			lngLoop:= strlen(strChallengePhrase)/2
			Loop lngLoop
			 {
				lngFirstPos:= subStr(strChallengePhrase,((A_Index-1)*2)+1,1)
				lngSecPos:= substr(strChallengePhrase,((A_Index-1)*2)+2,1)
								
				strtmp := GetChallengeConfigValue(lngFirstPos,lngSecPos)
				
				strChallengeResponse := strChallengeResponse strTmp
			 }
			 ;MsgBox, ,Challenge Response,%strChallengeResponse%
			 ;SendInput %strChallengeResponse%
			 Return strChallengeResponse
	}
}