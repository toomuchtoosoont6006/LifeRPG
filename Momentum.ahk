; Momentum Bar: ==================================================
; Get date momentum bar last updated:
MomentumLastUpdate := ProfileGet("MMTLastUpdate")

MomentumTimer()

MomentumTimer(){
	global db, HUD_MomentumBar, HUD_MomentumPerc, MomentumLastUpdate	
	; Start timer to check current date:
	gosub MomentumUpdate
	SetTimer, MomentumUpdate, 1000
	return
	
	MomentumUpdate:
	CurrentDate := FormatTime(,"yyyyMMdd")
	; When current date does not match date momentum bar last updated,
	if (MomentumLastUpdate <> CurrentDate)	; Momentum bar needs to be lowered:
	{
		; Compare both dates to see how long ago in days last update was:
		DateDiff := CurrentDate
		DateDiff -= MomentumLastUpdate, Days
		; Multiply difference in days by percentage loss in MMT bar,
		MMTLoss := DateDiff * 15
		; and move MMT down:
		;    Check the database to see what the current momentum level is.
		MMTCurrent := ProfileGet("momentum")
		;    Calculate current level minus calculated loss.
		MMTNew := MMTCurrent - MMTLoss
		;    If result is 0 or less than 0, just make the MMT level 0:
		if (MMTNew <= 0)
			MMTNew = 0
		;    Update database and HUD momentum bar:
		db.Query("UPDATE profile SET value = " . MMTNew . " WHERE setting =  'momentum'") ; update momentum value in database
		db.Query("UPDATE profile SET value = " . CurrentDate . " WHERE setting =  'MMTLastUpdate'") ; update when MMT last updated
		MMTNow := ProfileGet("momentum")
		GuiControl, HUD_Momentum:, HUD_MomentumBar, % MMTNow
		GuiControl, HUD_Momentum:, HUD_MomentumPerc, % MMTNow . "%"
		MomentumLastUpdate := ProfileGet("MMTLastUpdate")
	}
	return
}