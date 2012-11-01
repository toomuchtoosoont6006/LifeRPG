; Project Log Dialog/Window: ============================================

;#If !WinActive(ProjectLogTitle . " ahk_class AutoHotkeyGUI") && WinActive("LifeRPG ahk_class AutoHotkeyGUI")
;^l::
ProjectLog:
ProjectLogTitle := "Project Log"
GuiChildInit("ProjectLog")
;Notification(FilterSkillSelected,"")
Gui, ProjectLog:Add, Button, gProjectLogDateMoveBack, <
Gui, ProjectLog:Add, DateTime, vProjectLogDate gProjectLogRefresh x+1, LongDate
Gui, ProjectLog:Add, Button, gProjectLogDateMoveForward x+1, >
ColProjLogTime = 1
ColProjLogName = 2
ColProjLogSkill = 3
ColProjLogLevel = 4
PLw = 600
PLh = 400
Gui, ProjectLog:Add, ListView, y+1 xm w%PLw% r10 -Multi vProjectLogList gProjectLogRefresh, Time|Project|Skill|Level		; Set up skills list LV
PLx := CenterX(PLw)
PLy := CenterY(PLh)
gosub ProjectLogRefresh
Gui, ProjectLog:Show, x%PLx% y%PLy%, % ProjectLogTitle	;Project Log		; Show Project Log window
Send {Right 2}
return

ProjectLogRefresh:
Gui, ProjectLog:ListView, ProjectLogList
GuiControlGet, ProjectLogDate, , ProjectLogDate
LV_Delete()
ProjectLogSet := db.OpenRecordSet("SELECT * FROM projects WHERE dateDone LIKE '" . FormatTime(ProjectLogDate,"yyyyMMdd") . "%'")
while (!ProjectLogSet.EOF)
{
	ProjectLogTime := ProjectLogSet["dateDone"]
	ProjectLogName := ProjectLogSet["project"]
	ProjectLogSkill := ProjectLogSet["skill"]
	ProjectLogLevel := ProjectLogSet["levelDone"]
	LV_Add("", ProjectLogTime, ProjectLogName, ProjectLogSkill, ProjectLogLevel)
	ProjectLogSet.MoveNext()
}
ProjectLogSet.Close()	
GuiControl, -Redraw, ProjectLogList
LV_ModifyCol(ColProjLogTime, "sortasc")
Loop % LV_GetCount()
{
	LV_GetText(PLRow, A_Index, ColProjLogTime)
	LV_Modify(A_Index, "", FormatTime(PLRow, "Time"))
}
LV_ModifyCol()
Loop % LV_GetCount("Col")
{
	LV_ModifyCol(A_Index, "AutoHDR")
}
GuiControl, +Redraw, ProjectLogList
return

ProjectLogDateMoveBack:
ProjectLogDateMove("Backward")
return

ProjectLogDateMoveForward:
ProjectLogDateMove("Forward")
return

ProjectLogDateMove(Direction)
{
	GuiControlGet, ProjLogCurrDate, , ProjectLogDate
	if (Direction = "Forward")
		ProjLogCurrDate += 1, Days
	else if (Direction = "Backward")
		ProjLogCurrDate += -1, Days
	GuiControl, ProjectLog:, ProjectLogDate, % ProjLogCurrDate
	gosub ProjectLogRefresh
}

ProjectLogGuiEscape:
ProjectLogGuiClose:
GuiChildClose("ProjectLog")
return