#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force  ; Ensures that only the last executed instance of script is running
#NoTrayIcon
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetTitleMatchMode, REGEX


global gblnActiveCircle := False

^F10:: ;Create large circle around mouse
{
	setWindelay,-1
	coordmode, mouse, screen
	radius := 100
	gui MouseCircle: +AlwaysOnTop -caption
	Gui MouseCircle: color, yellow
	Gui MouseCircle: show, % "x0 y0 w" A_ScreenWidth " h" A_ScreenHeight, backdrop1 
	WinSet, ExStyle, +0x20, backdrop1 ; make the gui clickthrough
	WinSet, trans, 50, backdrop1 ; transparency
	gblnActiveCircle := true
	while(gblnActiveCircle) {
		mousegetpos, mx,my
		newregion := midpointAlgo(mx,my,radius) ;generate the "x-y" points of the circle
		winSet, region, % newRegion,backdrop1 ; setting the shape of the gui to the points
	}
	 return
}

^+F10:: ;Remove large circle around mouse
{
	gui, MouseCircle:destroy
	gblnActiveCircle := False
	return
}
	
MouseCircleGuiEscape:
{
	Gui,MouseCircle:Cancel
	Return
}

MidPointAlgo(x0,y0, radius)
{
	x := radius
	y := 0
	err := 0
	oct := array()
	While( x>= y) 
	{
		oct[1] .= x0 + x "-" y0 + y " "
		oct[2] .= x0 + y "-" y0 + x " "
		oct[3] .= x0 - y "-" y0 + x " "
		oct[4] .= x0 - x "-" y0 + y " "
		oct[5] .= x0 - x "-" y0 - y " "
		oct[6] .= x0 - y "-" y0 - x " "
		oct[7] .= x0 + y "-" y0 - x " "
		oct[8] .= x0 + x "-" y0 - y " "
		IF(err <= 0) 
		{
			y += 1
			err += 2*y +1
		}
		IF(err > 0)
		{
			x -=1
			err -= 2*x +1
		}
	}
	RETURN % oct[1] oct[2] oct[3] oct[4] oct[5] oct[6] oct[7] oct[8]
}