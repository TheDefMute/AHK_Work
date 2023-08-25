
#SingleInstance force  ; Ensures that only the last executed instance of script is running

;**********************
;** Keyboard shortcuts ***
;**********************
~^s:: ;Save/reload ahk script
{
	SetTitleMatchMode 2
	;HotIf WinActive(".ahk")
	;HotIfWinActive "ahk_class Notepad"
	If WinActive(".ahk")>0
	{
		Sleep 300
		ToolTip "Reloading..."
		Sleep 300
		Reload
	}
	else
	{	 

		SendInput "^s"
	}
}
^!+R::      ;Reload scripts
{
      Sleep 300
      ToolTip "Reloading..."
      Sleep 300
      Reload

}
^!+#K:: ;Kill Autohotkey scripts
{
	
	global guiKillAhk := Gui()
	;guiKillAhk := Gui()
	
	guiKillAhk.Title := "Close AHK"
	guiKillAhk.AddText("","Close which AHK scripts")
	guiKillAhk.AddDropDownList("vCloseChoice Choose2",["All","Some"])
	btnSubmit := guiKillAhk.AddButton("Default","OK")
	btnSubmit.onEvent("Click", guiKillAhk_Kill)
	guiKillAhk.OnEvent("Escape",guiKillAhk_Escape)
	
	guiKillAhk.Show("AutoSize")
}

guiKillAhk_Kill(*)
{
		Info:=guiKillAhk.Submit(True)
		Switch Info.CloseChoice
		{
			Case "All":
				AHKPanic(1,0,0,1)
			Case "Some":
				AHKPanic(1,0,0,0)
			Default:
				msgbox "Things went south"
		}	
		guiKillAhk.destroy
}
guiKillAhk_Escape(guiKillAhk)
{
	guiKillAhk.Destroy
}

AHKPanic(Kill:=0, Pause:=0, Suspend:=0, SelfToo:=0)
{
      DetectHiddenWindows True
      IDList := WinGetList("ahk_class AutoHotkey")
      Loop IDList.length
      {
            ID:=IDList[A_Index]
            ATitle:=WinGetTitle(ID)
                        
            ;Checks to make sure that what we are killing exists in the AHK script path of files
            If NOT INstr(ATitle, A_ScriptFullPath)
            {
                  If Suspend
                  {
                        PostMessage 0x111, 65305,,, ID  ; Suspend.
                  }
                  If Pause
                  {
                        PostMessage 0x111, 65306,,, ID  ; Pause.
                  }
                  If Kill
                  {
                        WinClose ID ;kill
                  }
            }
      }
      If SelfToo
      {
      If Suspend
            Suspend NOT(Suspend)  ; Suspend.
      If Pause
            Pause NOT(Pause)  ; Pause.
      If Kill
            ExitApp
      }
}   
