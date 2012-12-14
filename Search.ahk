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
if (A_GuiEvent = "K" && (A_EventInfo = 33 || A_EventInfo = 34 || A_EventInfo = 35 || A_EventInfo = 36 || A_EventInfo = 38 || A_EventInfo = 40)) OR (A_GuiEvent = "Normal")
{
	;Notification("MainList Selected")
	GuiControlGet, ListSelected, 1:FocusV
	GuiControl, Enable, ButtonSubproject
	Gui, ListView, % ListSelected
	LV_GetText(SBParent, LV_GetNext(), ParentCol)
	if (SBParent <> "Parent")
		SB_SetText(SBParent)
}
return