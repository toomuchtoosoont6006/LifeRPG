;~ ===============================================================================
; HUD and functions:

HUD_Color = 15384E
HUD_Trans = 200
HUD_Color2 = 48B1DF

; Create a new independent Guis for the HUD

; Level Module:
LevelX = 80
LevelY = 45
LevelW = 450
LevelH = 80
Gui, HUD_Level:New
Gui, HUD_Level:+LastFound +AlwaysOnTop -Caption +ToolWindow 
Gui, HUD_Level:Color, %HUD_Color%
;Gui, HUD_Level:Add, Picture, x0 y0 w400 h70 , Res\BG.png
Gui, HUD_Level:Font, S14 Q5 Bold, Electrolize
Gui, HUD_Level:Add, Progress, vHUD_Progress x12 y12 w425 h18 cWhite Background48B1DF
NameSize = 260
Gui, HUD_Level:Add, Text, vHUD_Name x12 y+1 w%NameSize% r1 c%HUD_Color2% BackgroundTrans, % ProfileGet("name")
Gui, HUD_Level:Font, s10
PointsSize := 424 - NameSize
Gui, HUD_Level:Add, Text, vHUD_Points x+1 w%PointsSize% Right cWhite BackgroundTrans,
Gui, HUD_Level:Font, s14
Gui, HUD_Level:Add, Text, vHUD_Text x12 y+7 w425 cWhite BackgroundTrans		; Shows current level and temporarily shows new XP awards.
HUD_LevelText := "LEVEL "
HUD_LevelTitle :=
;Gui, HUD_Level:Color, 15384E
WinSet, Transparent, %HUD_Trans%
Winset, ExStyle, +0x20
Gui, HUD_Level:Show, x%LevelX% y%LevelY% w%LevelW% h%LevelH% NoActivate
Gui, HUD_Level:Hide

; Momentum Module:
Gui, HUD_Momentum:New
Gui, HUD_Momentum:+LastFound +AlwaysOnTop -Caption +ToolWindow
Gui, HUD_Momentum:Color, %HUD_Color%
Gui, HUD_Momentum:Font, S14 Q5 bold, Electrolize
Gui, HUD_Momentum:Add, Text, x9 y4 cWhite BackgroundTrans, MMT
MMTStart := ProfileGet("momentum")
Gui, HUD_Momentum:Add, Progress, vHUD_MomentumBar x+5 y8 w325 h13 cRed Background48B1DF, % MMTStart
Gui, HUD_Momentum:Add, Text, vHUD_MomentumPerc x388 y4 w59 cWhite BackgroundTrans Center, % MMTStart . "%"
WinSet, Transparent, %HUD_Trans%
Winset, ExStyle, +0x20
Gui, HUD_Momentum:Show, x80 y135 w450 h30 NoActivate
Gui, HUD_Momentum:Hide

HUD_Refresh()
{
	global
	;	HUD Update: 
	;		name
	;		level + title
	;		points/threshold
	;		momentum bar
	;		progress bar!
	GuiControl, HUD_Level:, HUD_Progress, % ProgressGet()
	GuiControl, HUD_Level:, HUD_Name, % ProfileGet("name")
	GuiControl, HUD_Level:, HUD_Text, % HUD_LevelText . LevelCheck() . " " . ProfileGet("title")
	GuiControl, HUD_Level:, HUD_Points, % PointsCheck() . "/" . ThreshCheck()
	MMTNow := ProfileGet("momentum")
	GuiControl, HUD_Momentum:, HUD_MomentumBar, % MMTNow
	GuiControl, HUD_Momentum:, HUD_MomentumPerc, % MMTNow . "%"
}


HUD_MouseOverHide(ByRef hX, ByRef hY, ByRef hW, ByRef hH)
{
	global HUD_Trans
	SetTimer, Mouse, 100
	
	Mouse:
	CoordMode, Mouse, Screen
	MouseGetPos, x, y
	
	;ToolTip, %GuiX% (%GuiW% + %GuiX%) `n %x% %y%
	; if the mouse (x) is located horizontally in a greater position than the hud's X starting position
	; and less than that x position plus the HUD's width
	; and vertically (y) greater than the HUD's y position
	; and lower than that y pos plus the HUD's height
	; then hide the HUD.
	if (((x >= hX && x <= (hX+hW))) && ((y >= hY) && (y <= (165)))) ; 80-530; 45-125 ; hY+hH+
	{
		Gui, HUD_Level:+LastFound
		WinSet, Transparent, 0
		WinSet, ExStyle, +0x20
		
		Gui, HUD_Momentum:+LastFound
		WinSet, Transparent, 0
		WinSet, ExStyle, +0x20
	}
	else
	{
		Gui, HUD_Level:+LastFound
		WinSet, Transparent, %HUD_Trans%
		WinSet, AlwaysOnTop, On
		
		Gui, HUD_Momentum:+LastFound
		WinSet, Transparent, %HUD_Trans%
		WinSet, AlwaysOnTop, On
	}
	return
}


HUD_Progress(PreviousLevelPoints="toggle",PreviousLevel="") 
{	
	global
	split = 0
	;SetTimer, DestProg, Off
	SetTimer, ClearAwardText, off
	SetTimer, HideAgain, off
	static VisibState = 0
	Gui, HUD_Level:Default
	if (VisibState = 1) ; HUD is visible
	{
		if (PreviousLevelPoints = "toggle") ; toggle called, so hide HUD and return
		{
			Gui, HUD_Level:Hide
			Gui, HUD_Momentum:Hide
			VisibState = 0	; HUD now hidden
		}
		else	; update progress bar and then clear award text from control after a few seconds.
		{
			HUD_Update(PreviousLevelPoints, PreviousLevel)
			SetTimer, ClearAwardText, 2000
			return
			
			ClearAwardText:
			Critical
			Gui, HUD_Level:Default
			GuiControl, , HUD_Text, % HUD_LevelText . LevelCheck() . " " . ProfileGet("title")
			SetTimer, ClearAwardText, off
			return
		}
	}
	else if (VisibState = 0) ; HUD is not visible
	{
		if (PreviousLevelPoints = "toggle") ; toggle called, so show HUD
		{
			GuiControl,, HUD_Progress, % ProgressGet()	; Update progress bar
			GuiControl,, HUD_Text, % HUD_LevelText . LevelCheck() . " " . ProfileGet("title")
			GuiControl,, HUD_Points, % PointsCheck() . "/" . ThreshCheck()
			
			Gui, HUD_Level:Show, x80 y45 NoActivate
			WinSet, AlwaysOnTop, On
			Gui, HUD_Momentum:Show, NoActivate
			WinSet, AlwaysOnTop, On
			HUD_MouseOverHide(LevelX, LevelY, LevelW, LevelH)
			
			VisibState = 1	; HUD now showing
		}
		else	; show HUD temporarily when points are awarded, update progress bar and text, and then hide again.
		{
			
			Gui, HUD_Level:Show, x80 y45 NoActivate
			WinSet, AlwaysOnTop, On
			Gui, HUD_Momentum:Show, NoActivate
			WinSet, AlwaysOnTop, On
			
			HUD_Update(PreviousLevelPoints, PreviousLevel)
			SetTimer, HideAgain, 2500
			return
			
			HideAgain:
			Critical
			Gui, HUD_Level:Hide
			Gui, HUD_Momentum:Hide
			SetTimer, HideAgain, off
			return
		}
	}
	return
}

; Animate the progress bars and numbers and check for leveling up event:
HUD_Update(PreviousLevelPoints, PreviousLevel)
{
	global 
	Gui, HUD_Level:Default	; Operate on the Level module
	CurrentLevelPoints := ProgressGet()
	if (PreviousLevelPoints < CurrentLevelPoints)	
	{
		; slide up to sub100 value CurrentLevelPoints
		GuiControl,, HUD_Progress, % PreviousLevelPoints
		if (CurrentLevelPoints >= 100)
		{
			split = 1
			CurrentLevelPoints = 100
		}
		else
			split = 0
		AnimationCount := CurrentLevelPoints - PreviousLevelPoints
		AnimPoints := PointsCheck() - AnimationCount
		Loop % AnimationCount
		{
			GuiControl,, HUD_Progress, % PreviousLevelPoints + A_Index
			;GuiControl,, HUD_Text, % HUD_LevelText . PreviousLevel . " +" . A_Index . " XP"
			GuiControl,, HUD_Text, % HUD_LevelText . PreviousLevel . " +" . A_Index . " XP " . ProfileGet("title")
			GuiControl,, HUD_Points, % AnimPoints + A_Index . "/" . ThreshCheck()
			Sleep 50
		}
		if (split = 1)
		{
			GuiControl,, HUD_Progress, 0
			NewLevelPoints := ProgressGet() - 100
			Loop % NewLevelPoints 
			{
				GuiControl,, HUD_Progress, % A_Index
				;GuiControl,, HUD_Text, % HUD_LevelText . LevelCheck() . " +" . A_Index
				GuiControl,, HUD_Text, % HUD_LevelText . LevelCheck() . " +" . A_Index . " XP " . ProfileGet("title")
				GuiControl,, HUD_Points, % (PointsCheck()-NewLevelPoints) + A_Index . "/" . ThreshCheck()
				Sleep 50
			}
		}
	}
	LevelCheck()
}


HUD_Message(message, duration="2500")
{
	;Gui, 2:Destroy
	Gui, Message:New
   ; Example: On-screen display (OSD) via transparent window:
	CustomColor = 9AFF9A  ; Can be any RGB color (it will be made transparent below).
	Gui Message:+LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
	Gui, Message:Color, %CustomColor%
	Gui, Message:Font, s25 Q5, Electrolize 	; Set a large font size (32-point).
	Gui, Message:Add, Text, Center cLime, %message%  ; XX & YY serve to auto-size the window.
	; Make all pixels of this color transparent and make the text itself translucent (150):
	WinSet, TransColor, %CustomColor% 255

	;VertPos := A_ScreenHeight - offset
	Gui, Message:Show, x60 y99 NoActivate  ; NoActivate avoids deactivating the currently active window.
	;Sleep 2000
	SetTimer, DestroyMsg, %duration%
	return

	DestroyMsg:
	Gui, Message:Destroy
	SetTimer, DestroyMsg, Off
	return
}


PointsCheck()
{
	; The current number of points I have
	global db
	PointsSet := db.OpenRecordSet("SELECT value FROM profile WHERE setting = 'points'")
	while (!PointsSet.EOF)
	{
		Points := PointsSet["value"]
		PointsSet.MoveNext()
	}
	PointsSet.Close()
	return Points
}

; Could combine these two functions into one ^ \/, plus the writing ones:

ThreshCheck()
{
	; The next upcoming point threshold to level up again
	global db
	ThresholdSet := db.OpenRecordSet("SELECT value FROM profile WHERE setting = 'threshold'")
	while (!ThresholdSet.EOF)
	{
		Threshold := ThresholdSet["value"]
		ThresholdSet.MoveNext()
	}
	ThresholdSet.Close()
	return Threshold
}


PointsWrite(Points)
{
	;global PointsFile
	;IniWrite, %Points%, %PointsFile%, Data, Points		; Store certain number of awarded points in file
	global db
	bool := db.Query("UPDATE profile SET value = " . Points . " WHERE setting = 'points'")
	return
}

ThreshWrite(Threshold)
{
	;global PointsFile
	;IniWrite, %Threshold%, %PointsFile%, Data, Threshold
	global db
	bool := db.Query("UPDATE profile SET value = " . Threshold . " WHERE setting = 'threshold'")
	return
}

ProgressGet() {
	CurrentProgress := 100 - (ThreshCheck() - PointsCheck()) 		; How many points until next level up event
	return CurrentProgress	; What shows up on progress bar
}


LevelCheck() {
	global LevelUpSound
	; Threshold starts at 100, i.e. you start at level 1
	If (PointsCheck() >= ThreshCheck())
	{
		;Set next threshold
		;Threshold should go up.
		if (FileExist(LevelUpSound))
			SoundPlay, %LevelUpSound%
		ThreshWrite(ThreshCheck() + 100)	; Write new threshold
		LevelNow := Floor(ThreshCheck()/100)
		;HUD_Message("Level Up! Level " LevelNow, 5000)	; This *could* be a fancier notification than just a tray notification
		Notification("LEVEL UP!", "You have reached Level " . LevelNow)
	}
	Return Floor(ThreshCheck()/100)
}

LevelGet() 
{
	return Floor(ThreshCheck()/100)
}

; Main function to call to award points:
UpdateProgress(Message, Award, Sound="")	; Call to give user some points and show a notification
{
	PreviousLevelPoints := ProgressGet()
	PreviousLevel := LevelCheck()
	;SoundPlay, %Sound%
	;HUD_Message(Message) HUD_message should be altered to be a fancy HUD message
	Notification(Message, "+" . Award . " XP Awarded")
	PointsWrite(PointsCheck() + Award)
	HUD_Progress(PreviousLevelPoints, PreviousLevel)
	return
}

Notification(Title, Message="", Duration=9)
{
	Notify(Title, Message, Duration, "GC=15384E GR=0 GT=200 TS=14 TC=ffffff TF=Electrolize MS=14 MC=48B1DF MF=Electrolize BW=0 BR=0")
	return
}