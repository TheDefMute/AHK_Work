#SingleInstance force  ; Ensures that only the last executed instance of script is running
#NoTrayIcon
SendMode "Input"  ; Recommended for new scripts due to its superior speed and reliability.

#Include Lib\Lib_BaseFunctions.ahk
#Include Lib\Lib_Code.ahk


^+I:: ;Skeleton - FCR - Add impact skeleton
{
	BaseFunctions.SimpleSend("[B][/B]`r[Indent][/Indent]")
}
^+C:: ;Skeleton - OneNote - Add skeleton config notes
{
	BaseFunctions.SimpleSend("^+{L}Config`rComponents`rPublishables")
}
;************************************
;** Default XML parameters **
;************************************
#HotIF WinActive( "ahk_exe devenv.exe")
{
	#+p:: ;.Net - Default XML parameters with human readable parameter (Only in .Net)
	{
		Code.DefaultXMLParameter()
	}	
	#+f:: ;Skeleton - Create default type for custom function array (only in .Net)
	{
		global guiCode := Gui()
		
		guiCode.OnEvent("Escape", guiCode_Escape)
		
		guiCode.AddDropdownList("vDDL_Type Choose1",["Boolean","String","Integer","Date"])
		btnInput := guiCode.AddButton("Default","Input")
		btnInput.Onevent("Click",CodeButtonInput)
		
		guiCode.Show
	}
}
;**********************
;** str fda prefix ****
;**********************
!+f:: ;Convert - fdaStuff around highlighted field using clipboard.
{
	Code.fdaFormat()
}

CodeButtonInput(*)
{
		
	Info := guiCode.Submit(true)
	BaseFunctions.SimpleSend("CType(DirectCast(pvntFunctionParameters, Object())(0), " Info.DDL_Type ")")
	guiCode.Destroy
	
}
guiCode_Escape(*)
{
	guiCode.Destroy
}
