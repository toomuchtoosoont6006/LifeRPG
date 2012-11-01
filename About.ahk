About:
; Cursor change for about box links:
; Load the cursor and start the hook:
hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
OnMessage(0x200,"WM_MOUSEMOVE")

GuiChildInit("AboutBox")
ABw = 250
ABh = 150
ABx := CenterX(ABw)
ABy := CenterY(ABh)

DevEmail := "JJPujara@gmail.com"
SiteUrl := "http://www.reddit.com/r/LifeRPG/"

Gui, AboutBox:Add, Picture, w32 h-1, res/WP_RPG_VG.ico

Gui, AboutBox:Font, bold
Gui, AboutBox:Add, Text, x+10, LifeRPG r2
Gui, AboutBox:Font

Gui, AboutBox:Add, Text, y+1, by Jayvant Javier Pujara
Gui, AboutBox:Font, cBlue
Gui, AboutBox:Add, Text, y+1 gAboutLinkEmail vAboutLinkEmail, %DevEmail%
Gui, AboutBox:Font

Gui, AboutBox:Add, Text, xm y+10, For help and discussion,`nvisit the LifeRPG community on reddit:
Gui, AboutBox:Font, cBlue
Gui, AboutBox:Add, Text, y+1 gAboutLinkSite, %SiteUrl%
Gui, AboutBox:Font,

Gui, AboutBox:Add, Button, y+15 w80 Default gAboutBoxGuiClose, OK
Gui, AboutBox:Show, w%ABw% h%ABh% x%ABx% y%ABy%, About
return

AboutLinkEmail:
Run, mailto:%DevEmail%
return

AboutLinkSite:
Run, %SiteUrl%
return

AboutBoxGuiClose:
AboutBoxGuiEscape:
; Disable the hook and destroy the cursor:
OnMessage(0x200,"")
DllCall("DestroyCursor","Uint",hCurs) 
GuiChildClose("AboutBox")
return

; Cursor hook:
WM_MOUSEMOVE(wParam,lParam)
{
	Global hCurs, AboutLinkEmail
	MouseGetPos,,,,ctrl
	; Only change over certain controls, use Windows Spy to find them.
	If ctrl in Static4,Static6
		DllCall("SetCursor","UInt",hCurs)
	Return
}