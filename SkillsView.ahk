; View the user's current levels in all the skills he has completed projects in:

SkillsView:
GuiChildInit("SkillsView")
;Notification(FilterSkillSelected,"")
ColSkillName = 1
ColSkillLevel = 2
Gui, SkillsView:Add, ListView, w300 r20 -Multi gSkillsListEvent vSkillsListView, Skill|Level		; Set up skills list LV
Gui, SkillsView:Add, Button, Hidden Default w0 h0 gSkillsListEvent, OK
SVw = 300
SVh = 400
SVx := CenterX(SVw)
SVy := CenterY(SVh)
; Populate the Skill Stats ListView with skills and stats:
; 1. Get the skills count for all done items from the projects table
;    First we need to add all skills to the LV
; SELECT DISTINCT skill FROM projects WHERE difficulty <> 'Done' ORDER BY skill
; 2. Add to ListView
SkillsList := db.OpenRecordSet("SELECT DISTINCT skill FROM projects WHERE skill IS NOT NULL AND skill <> '' ORDER BY skill")
while (!SkillsList.EOF)
{
	SkillListName := SkillsList["skill"]
	LV_Add("", SkillListName)
	RowNum := A_Index
	Table := db.Query("SELECT COUNT(skill) FROM projects WHERE skill = '" . SkillListName . "' AND difficulty = 'Done'")
	columnCount := table.Columns.Count()
	for each, row in table.Rows
   {
		Loop, % columnCount
		;msgbox % row[A_index]
		LV_Modify(RowNum,"Col2", row[A_Index])
   }
	SkillsList.MoveNext()
}
SkillsList.Close()
;LV_ModifyCol()
LV_ModifyCol(ColSkillLevel, "AutoHDR integer sortdesc")
Loop % LV_GetCount("Col")
{
	LV_ModifyCol(A_Index, "AutoHDR")
}
Gui, SkillsView:Show, x%SVx% y%SVy%, Skill Stats		; Show skills list window
SkillCount := LV_GetCount()
if (FilterSkillSelected = "All" || FilterSkillSelected = "None" || !FilterSkillSelected)
	return	
else 
{
	Loop % SkillCount
	{
		HighlightLine := A_Index
		LV_GetText(SkillToHighlight, HighlightLine, ColSkillName)
		if (SkillToHighlight = FilterSkillSelected)
		{
			LV_Modify(HighlightLine, "Focus Select Vis")
		}
	}
}
return

SkillsListEvent:	; Jump to double-clicked skill
GuiControlGet, FocusedControl, FocusV
if (FocusedControl = "SkillsListView")
{
	if (LV_GetNext(0, "Focused") = 0)
		return
	else
		LV_GetText(SDC, LV_GetNext(0, "Focused"))
}
else if (A_GuiEvent = "DoubleClick" )
	LV_GetText(SDC, A_EventInfo)
GuiChildClose("SkillsView")
RefreshSkillsList(SDC)
UpdateList(,,FilterSkillSelected)
return

SkillsViewGuiEscape:
SkillsViewGuiClose:
GuiChildClose("SkillsView")
return

ExploreObj(Obj, NewRow="`n", Equal="  =  ", Indent="`t", Depth=12, CurIndent="") {
    for k,v in Obj
        ToReturn .= CurIndent . k . (IsObject(v) && depth>1 ? NewRow . ExploreObj(v, NewRow, Equal, Indent, Depth-1, CurIndent . Indent) : Equal . v) . NewRow
    return RTrim(ToReturn, NewRow)
}