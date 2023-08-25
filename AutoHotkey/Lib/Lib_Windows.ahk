#singleinstance force
#NoTrayIcon

Class Windows
{
	; Move(direction)
	; {
		; SysGet, monCount, MonitorCount
		; WinGetPos, winX, winY, winW, winH, A
		; WinGet, mm, MinMax, A
		
		; ;Use center of window as base for comparison.
		; baseX := winx + winw / 2
		; baseY := winy + winh / 2
		
		; curMonNum := Windows.GetMonitorNumber(baseX, baseY, winX, winY, monCount)
		; curMonWidth := Windows.GetMonitorWorkArea("width", curMonNum)
		; curMonHeight := Windows.GetMonitorWorkArea("height", curMonNum)
		; SysGet, curMon, Monitor, %curMonNum%

		; ;Check for monitor in corresponding direction.
		; Windows.GetXYForExists()
		; monitorExists := Windows.DoesMonitorExist(tmpWinX, tmpWinY, monCount)
		
		; ;Move to new monitor.
		; If (monitorExists = "true")
		; {	
			; Windows.GetXYForMove()
			
			; If (mm = 1)
			; {
				; WinRestore, A
				; WinMove, A,, newWinX, newWinY
				; WinMaximize, A
			; }
			; Else
			; {
				; WinMove, A,, newWinX, newWinY
			; }
		; }
		; ;New monitor not found, let's re-align in current monitor.
		; Else If (monitorExists = "false")
		; {
			; monForReAlign := curMonNum
			
			; Windows.ReAlignX()
			; Windows.ReAlignY()
			
			; WinMove, A,, newWinX, newWinY
		; }
		
		; Return
	; }
	
	; GetXYForExists()
	; {
		; If (direction = "Right")
		; {
			; tmpWinX := baseX + curMonWidth
			; tmpWinY := baseY
		; }
		; Else If (direction = "Left")
		; {
			; tmpWinX := baseX - curMonWidth
			; tmpWinY := baseY
		; }
		; Else If (direction = "Up")
		; {
			; tmpWinX := baseX
			; tmpWinY := baseY - curMonHeight
		; }
		; Else If (direction = "Down")
		; {
			; tmpWinX := baseX
			; tmpWinY := baseY + curMonHeight
		; }
		; Return
	; }
	
	; GetXYForMove()
	; {
		; /*
		; Maximized winows are -4 x + -4 y of their current monitor.
		; Acount for this here.
		; */
		; If (mm = 1)
		; {
			; winX := winX + 4
			; winY := winY + 4
		; }
		; Windows.SetReAlignMon()
		; Windows.ReAlignX()
		; Windows.ReAlignY()
		
		; Return
	; }
	
	; SetReAlignMon()
	; {
		; If (direction = "Right")
		; {
			; newBaseX := baseX + curMonWidth
			; newBaseY := baseY
			; monForReAlign := Windows.GetMonitorNumber(newBaseX, newBaseY, null, null, monCount)
		; }
		; Else If (direction = "Left")
		; {
			; newBaseX := baseX - curMonWidth
			; newBaseY := baseY
			; monForReAlign := Windows.GetMonitorNumber(newBaseX, newBaseY, null, null, monCount)
		; }
		; Else If (direction = "Up")
		; {
			; newBaseX := baseX 
			; newBaseY := baseY - curMonHeight
			; monForReAlign := Windows.GetMonitorNumber(newBaseX, newBaseY, null, null, monCount)
		; }
		; Else If (direction = "Down")
		; {
			; newBaseX := baseX
			; newBaseY := baseY + curMonHeight
			; monForReAlign := Windows.GetMonitorNumber(newBaseX, newBaseY, null, null, monCount)
		; }
		; Return
	; }
	
	; ;ReAlignX and ReAlignY work to keep the window in a monitor.
	; ReAlignX()
	; {
		; If (direction = "Right")
		; {
			; SysGet, newMon, Monitor, %monForReAlign%
			; newMonWidth := Windows.GetMonitorWorkArea("width", monForReAlign)
			; ;adjust by setup, not fully tested.
			; padding := 0 ;curMonRight - curMonLeft - newMonWidth
			
			; If ((winX + winW + curMonWidth) > newMonRight)
			; {
				; newWinX := (newMonRight - winW) + padding 
			; }
			; Else If ((winX + curMonWidth) < newMonLeft)
			; {
				; newWinX := newMonLeft + padding 
			; }
			; Else
			; {
				; newWinX := (winX + newMonWidth) + padding 
			; }
		; }
		; Else If (direction = "Left")
		; {
			; SysGet, newMon, Monitor, %monForReAlign%
			; newMonWidth := Windows.GetMonitorWorkArea("width", monForReAlign)
			; ;adjust by setup, not fully tested.
			; padding := 0 ;curMonRight - curMonLeft - newMonWidth
			
			; If ((winX - curMonWidth) < newMonLeft)
			; {
				; newWinX := newMonLeft - padding
			; }
			; Else If ((winX + winW - curMonWidth) > newMonRight)
			; {
				; newWinX := (newMonRight - winW) - padding
			; }
			; Else
			; {
				; newWinX := (winX - newMonWidth) - padding
			; }
		; }
		; Else If (direction = "Up" or direction = "Down")
		; {
			; SysGet, newMon, Monitor, %monForReAlign%
			; newMonWidth := Windows.GetMonitorWorkArea("width", monForReAlign)
		
			; If (winX < newMonLeft)
			; {
				; newWinX := newMonLeft
			; }
			; Else If ((winX + winW) > (newMonWidth + newMonLeft))
			; {
				; newWinX := (newMonWidth + newMonLeft) - winW
			; }
			; Else
			; {
				; newWinX := winX
			; }
		; }
		; Return
	; }
		
	; ReAlignY()
	; {
		; If(direction = "Right" or direction = "Left")
		; {
			; SysGet, newMon, Monitor, %monForReAlign%
			; newMonHeight := Windows.GetMonitorWorkArea("height", monForReAlign)
			
			; If (winY < newMonTop)
			; {
				; newWinY := newMonTop
			; }
			; Else If ((winY + winH) > (newMonHeight + newMonTop))
			; {
				; newWinY := (newMonHeight + newMonTop) - winH
			; }
			; Else
			; {
				; newWinY := winY
			; }
		; }
		; Else If (Direction = "Up")
		; {
			; SysGet, newMon, Monitor, %monForReAlign%
			; newMonHeight := Windows.GetMonitorWorkArea("height", monForReAlign)
			; ;adjust by setup, not fully tested.
			; padding := 0 ;curMonBottom - curMonTop - newMonHeight

			; If ((winY - curMonHeight) < newMonTop)
			; {
				; newWinY := newMonTop + padding
			; }
			; Else If ((winY + winH - curMonHeight) > (newMonTop + newMonHeight))
			; {
				; newWinY := ((newMonTop + newMonHeight) - winH) - padding
			; }
			; Else
			; {
				; newWinY := (winY - newMonHeight) - padding
			; }
		; }
		; Else If (Direction = "Down")
		; {
			; SysGet, newMon, Monitor, %monForReAlign%
			; newMonHeight := Windows.GetMonitorWorkArea("height", monForReAlign)
			; padding := curMonBottom - curMonTop - newMonHeight

			; If ((winY + winH + curMonHeight) > newMonBottom)
			; {
				; newWinY := (newMonBottom - winH) - padding
			; }
			; Else If ((winY + curMonHeight) < newMonTop)
			; {
				; newWinY := newMonTop + padding
			; }
			; Else
			; {
				; newWinY := (winY + newMonHeight)  + padding
			; }
		; }
		; Return
	; }

	static Center()
	{
		mm := WinGetMinMax("A")
		If (mm != 1)
		{
			monCount := SysGet(80)
			WinGetPos &winX, &winY, &winW, &winH, "A"
						
			;Use center of window as base for comparison.
			baseX := winx + winw / 2
			baseY := winy + winh / 2
			
			curMonNum := Windows.GetMonitorNumber(baseX, baseY, winX, winY, monCount)
			curMonWidth := Windows.GetMonitorWorkArea("width", curMonNum)
			curMonHeight := Windows.GetMonitorWorkArea("height", curMonNum)
			
			;SysGet, curMon, Monitor, %curMonNum%
			MonitorGetWorkArea(curMonNum, &curMonLeft, &curMonTop, &curMonRight, &curMonBottom)
			
			newWinX := (curMonWidth - winW)/2 + curMonLeft
			newWinY := (curMonHeight - winH)/2 + curMonTop
			
			WinMove newWinX, newWinY,"A"
		}
	}

	static CenterResize(intScreen, intPercent)
	{
		baseWindow_Width:=intPercent/100 ;resizes to % of screen size.
		baseWindow_Height:=intPercent/100 ;resizes to % of screen size.
		
		;SysGet, Monitor, MonitorWorkArea, %intScreen%
		MonitorGetWorkArea(intScreen, &MonitorLeft, &MonitorTop, &MonitorRight, &MonitorBottom)
		Monitor_Width := MonitorRight-MonitorLeft
		Monitor_Height := MonitorBottom-MonitorTop

		WinMove (Monitor_Width/2)-((Monitor_Width*baseWindow_Width)/2)+(MonitorLeft),(Monitor_Height/2)-((Monitor_Height*baseWindow_Height)/2)+(MonitorTop), (Monitor_Width*baseWindow_Width),(Monitor_Height*baseWindow_Height), "A"
	}
		
	static GetMonitorNumber(baseX, baseY, winX, winY, monCount)
	{
		i := 0
		monFound := 0

		Loop %monCount%
		{   
			i := i+1
			;SysGet, tmpMon, Monitor, %i%
			MonitorGetWorkArea(i, &tmpMonLeft, &tmpMonTop, &tmpMonRight, &tmpMonBottom)
			if (baseX >= tmpMonLeft and baseX <= tmpMonRight and baseY >= tmpMonTop and baseY <= tmpMonBottom)
			{
				monFound := i
			}
		}
		;If we couldn't find a monitor through the assumed x/y, lets check by window x/y.
		If (monFound = 0)
		{
			{
				i := 0
				Loop %monCount%
				{   
					i := i+1
					;SysGet, tmpMon, Monitor, %i%
					MonitorGetWorkArea(i, &tmpMonLeft, &tmpMonTop, &tmpMonRight, &tmpMonBottom)
					if (winX >= tmpMonLeft and winX <= tmpMonRight and winY >= tmpMonTop and winY <= tmpMonBottom)
					{
						monFound := i
					}
				}
			}
		}
		Return monFound
	}

	static GetMonitorWorkArea(measurement, monToGet)
	{
		;SysGet, tmpMon, MonitorWorkArea, %monToGet%
		MonitorGetWorkArea(monToGet, &tmpMonLeft, &tmpMonTop, &tmpMonRight, &tmpMonBottom)
		If (measurement = "width")
		{
			tmpMonWidth  := tmpMonRight - tmpMonLeft
			Return tmpMonWidth
		}
		Else If (measurement = "height")
		{
			tmpMonHeight := tmpMonBottom - tmpMonTop
			Return tmpMonHeight
		}
	}

	; DoesMonitorExist(newWinX, newWinY, monCount)
	; {
		; i := 0
		; monitorFound = false

		; Loop %monCount%
		; {   
			; i := i+1
			; SysGet, tmpMon, Monitor, %i%
			; if (newWinX >= tmpMonLeft and newWinX <= tmpMonRight and newWinY >= tmpMonTop and newWinY <= tmpMonBottom)
			; {
				; monitorFound = true
				; break
			; }
		; }
		; Return monitorFound
	; }

	; GetMonitorInfo()
	; {
		; SysGet, MonitorCount, MonitorCount
		; SysGet, MonitorPrimary, MonitorPrimary
		; MsgBox, Monitor Count:`t%MonitorCount%`nPrimary Monitor:`t%MonitorPrimary%
		; Loop, %MonitorCount%
		; {
			; SysGet, MonitorName, MonitorName, %A_Index%
			; SysGet, Monitor, Monitor, %A_Index%
			; SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
			; MsgBox, Monitor:`t#%A_Index%`nName:`t%MonitorName%`nLeft:`t%MonitorLeft% (%MonitorWorkAreaLeft% work)`nTop:`t%MonitorTop% (%MonitorWorkAreaTop% work)`nRight:`t%MonitorRight% (%MonitorWorkAreaRight% work)`nBottom:`t%MonitorBottom% (%MonitorWorkAreaBottom% work)
		; }
		; RETURN
	; }

}