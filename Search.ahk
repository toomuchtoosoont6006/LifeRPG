;~ ===============================================================================
;~ Filter ListView by priority:


;~ UpdateList(,FilterImportanceSelected,FilterSkillSelected)
;~ return

;~ ===============================================================================
; Filter main projects ListView by available skills:
Search:
FilterUpdate:
ImportanceUpdate:
FilterSkillUpdate:
Critical
GuiControlGet, FilterImportanceSelected, 1:, ImportanceChoose
GuiControlGet, FilterSkillSelected, 1:, FilterSkill
GuiControlGet, FilterShowDone, 1:, FilterShowDone
UpdateList(Selection,FilterImportanceSelected,FilterSkillSelected, SideListGet())
return

;~ ===============================================================================
;~ Clear the search bar and reset the ListView:

ClearSearch:
Critical
;GuiControl, , ImportanceChoose, |All||
;GuiControl, , ImportanceChoose, % ListImportance()
SLResetAll()
GuiControl, Choose, ImportanceChoose, 1

GuiControl, , FilterSkill, |All||None|	; Put | at start to reset out the DDL
GuiControl, , FilterSkill, % ListSkills()

GuiControl, , FilterShowDone, 0
GuiControl, , SearchQuery
GuiControl, Focus, SearchQuery
return

;~ ===============================================================================
;~ Search subroutine:
/*
Search:
Critical
GuiControlGet, SearchString, , SearchQuery
GuiControlGet, FilterDifficultySelected, , DifficultyChoose
GuiControlGet, FilterSkillSelected, , FilterSkill
GuiControlGet, FilterShowDone, 
;SLResetAll()
UpdateList(Selection, FilterDifficultySelected, FilterSkillSelected)
return
*/

;===================================================================================
SideListUpdate:
if (A_GuiEvent = "K" && (A_EventInfo = 33 || A_EventInfo = 34 || A_EventInfo = 35 || A_EventInfo = 36 || A_EventInfo = 38 || A_EventInfo = 40)) OR (A_GuiEvent = "Normal")
{
	GuiControl, Choose, ImportanceChoose, 1
	RefreshSkillsList()
	gosub FilterUpdate
}
else
	return
return

SideListGet()
{
	global
	Gui, ListView, SideList
	SideListFocRow := LV_GetNext()
	LV_GetText(SideListFocusedID, LV_GetNext(), SLParentIDCol)
	Gui, ListView, MainList
	if (SideListFocusedID = "ID" || SideListFocusedID = 0)
		return
	else
		return SideListFocusedID
}

; Move selector back to "All" (first row):
SLResetAll()
{
	global
	Gui, ListView, SideList
	LV_Modify(1, "Focus Select Vis")
}