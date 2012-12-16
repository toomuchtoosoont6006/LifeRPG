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
Critical
if ((A_GuiEvent = "K" && (A_EventInfo = 33 || A_EventInfo = 34 || A_EventInfo = 35 || A_EventInfo = 36 || A_EventInfo = 38 || A_EventInfo = 40)) OR (A_GuiEvent = "Normal") || A_GuiEvent = "RightClick")
{
	GuiControl, , SearchQuery	; Blank search box. By changing control, gLabel appears to trigger
	GuiControl, Choose, ImportanceChoose, 1	; Reset importance selector
	RefreshSkillsList()	; Reset skill selector
	GuiControlGet, ListSelected, 1:FocusV
	GuiControl, Disable, ButtonSubproject
}
else
	return
return

MainListSelect:
if (A_GuiEvent = "K" && (A_EventInfo = 33 || A_EventInfo = 34 || A_EventInfo = 35 || A_EventInfo = 36 || A_EventInfo = 38 || A_EventInfo = 40)) OR (A_GuiEvent = "Normal" && A_GuiControl <> "MainListSelector")
{
	;Notification("MainList Selected")
	GuiControlGet, ListSelected, 1:FocusV
	GuiControl, Enable, ButtonSubproject
	Gui, ListView, % ListSelected
	LV_GetText(SBParent, LV_GetNext(), ParentCol)
	if (SBParent <> "Parent")
		SB_SetText(SBParent)
}
else if (A_GuiEvent = "DoubleClick" || (A_GuiControl = "MainListSelector" && A_GuiEvent = "Normal" && ListSelected = "MainList"))	 ; on DoubleClick or Enter of the main list, get the Subproject count of the selected project
{
	;Notification("A_GuiControl: " . A_GuiControl, "A_GuiEvent: " . A_GuiEvent ", ListSelected: " . ListSelected)
	Gui, ListView, MainList
	if (A_GuiEvent = "DoubleClick")
		MainListRowSel := A_EventInfo
	else if (A_GuiEvent = "Normal")
		MainListRowSel := LV_GetNext()
	LV_GetText(SideListOpenProjID, MainListRowSel, IDCol)
	Gui, ListView, SideList
	Loop % LV_GetCount()
	{
		SLOLine := A_Index
		LV_GetText(SideListOpenMatch, A_Index, SLParentIDCol)
		if (SideListOpenProjID = SideListOpenMatch)
		{
			;GuiControl, Focus, SideList
			LV_Modify(SLOLine, "Focus Select Vis")
			gosub FilterUpdate
		}
	}
}
else if (A_GuiEvent = "K" && A_EventInfo = "8" && SideListGet() <> 0)
{
	;Notification("BACKSPACE!")
	Gui, ListView, SideList
	LV_Modify(1, "Focus Select Vis")
	gosub FilterUpdate
}
return
