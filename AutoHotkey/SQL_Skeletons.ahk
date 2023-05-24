#SingleInstance force  ; Ensures that only the last executed instance of script is running
#NoTrayIcon
SendMode "Input" ; Recommended for new scripts due to its superior speed and reliability.
SetTitleMatchMode "REGEX"

#Include Lib\Lib_Sql.AHK

global mblnServerCreated := False


BuildServerGui()
{
	global
	if !(mblnServerCreated)
	{
		global mguiServer := Gui()

		mguiServer.AddDropDownList("vstrDDL_Environment Choose1",["D","T","S","P","FCR"])
		mguiServer.AddDropDownList("vstrDDL_Set Choose1",["App","TAP"])
		
		btnServerOk := mguiServer.AddBUtton("Default", "OK")
		
		btnServerOk.OnEvent("Click", btnServerOk_Click)
		mguiServer.onevent("Escape",Gui_Escape)
		
		mblnServerCreated := True
	}
		mguiServer.Show
}


Gui_Escape(mguiServer)
{
	mguiServer.Hide()
}

btnServerOk_Click(*)
{
	SubmitInfo := mguiServer.Submit(True)
	SQL.GetServer(SubmitInfo.strDDL_Environment,SubmitInfo.strDDL_Set)
}


!+a:: ;Skeleton - Server address
{
	BuildServerGui()
}

;**********************
;***** SQL Query ******
;**********************
;SQL Query
!+h:: ;Skeleton - Date: highdate
{
	SQL.Date_HighDate()
}

!+y:: ;Skeleton - Date: first day of the current year
{
	SQL.Date_FirstDayOfYear()
}

!+d:: 	;Skeleton - Date: today
{
	SQL.Date_Today()
}

!+c:: ;Skeleton - Count
{
	SQL.Count()
}

!+z:: ;Skeleton - Zaudit layout
{
	SQL.Zaudit()
}

;**********************
;***** SQL Nolock ******
;**********************
;SQL Query
!+n:: ;Skeleton - NoLock (individual table)
{
	SQL.NoLock()
}

;********************************************
;***** SQL Isolation Level Uncommitted ******
;********************************************
;SQL Query
!+u:: ;Skeleton - NoLock (all tables)
{
	SQL.NoLock_All_Tables()

} 

;****************************
;** SQL Information Schema **
;****************************
!+i:: ;Skeleton - Information_schema base
{
	SQL.Information_Schema_Base()
}

;**********************
;** SQL transaction ***
;**********************
!+t:: ;Skeleton - Begin tran block
{
	SQL.Trans_Block()
}

;**********************
;** SQL select ********
;**********************
!+Q:: ;Skeleton - Select statement
{
	SQL.Select_Statement()
}

!+1:: ;Skeleton - Select top statement
{
	SQL.Select_Top_Statement(10)
}

;**********************
;** SQL like **********
;**********************
!+L:: ;Skeleton - Like block
{
	SQL.Like()
}

;***********************
;** SQL group **********
;***********************
!+G:: ;Skeleton - Group By block
{
	SQL.GroupBy()
}

;***********************
;** SQL ver** **********
;***********************
!+V:: ;Skeleton - VER = 0
{
	SQL.Ver()
}

;***********************
;** CTE User************
;***********************
!+S:: ;Skeleton - create CTE_User
{
	SQL.CTE_User()
}
	
;***********************
;** SP_who *************
;***********************
!+W:: ;Skeleton - sp_Who
{
	SQL.spWho()
}