#singleinstance force
#NoTrayIcon

#Include Lib\Lib_Windows.AHK
CapsLock & 1::  	;Center window Screen 1, 90% screen
{
	;This will center on my primary screen.
	Windows.CenterResize(1,90)
	Return
}

CapsLock & 2::  	;Center window Screen 2, 90% screen
{
	;This will center on my secondary screen.
	Windows.CenterResize(2,90)
	Return
}
	
CapsLock & 3::  	;Center window Screen 2, 90% screen
{
	;This will center on my secondary screen.
	Windows.CenterResize(3,90)
	Return
}
	
; #+Right:: ;Move active window to screen on right
	; Move("Right")
	; Return

; #+Left:: ;Move active window to screen on left
	; Move("Left")
	; Return

; #+Up:: ;Move active window to screen on top
	; Move("Up")
	; Return

; #+Down:: ;Move active window to screen on bottom
	; Move("Down")
	; Return

#+c:: ;Center screen, no resize
{
	Windows.Center()
	Return
}
