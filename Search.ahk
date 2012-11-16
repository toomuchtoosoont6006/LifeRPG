;~ ===============================================================================
;~ Filter ListView by priority:


;~ UpdateList(,FilterImportanceSelected,FilterSkillSelected)
;~ return

;~ ===============================================================================
; Filter main projects ListView by available skills:
FilterUpdate:
ImportanceUpdate:
FilterSkillUpdate:
GuiControlGet, FilterConfidenceSelected, 1:, ConfidenceChoose
GuiControlGet, FilterSkillSelected, 1:, FilterSkill
GuiControlGet, FilterShowDone, 1:, FilterShowDone
UpdateList(Selection,FilterConfidenceSelected,FilterSkillSelected)
return

;~ ===============================================================================
;~ Clear the search bar and reset the ListView:

ClearSearch:
Critical
GuiControl, , ImportanceChoose, |All||
GuiControl, , ImportanceChoose, % ListPriorities()

GuiControl, , FilterSkill, |All||None|	; Put | at start to reset out the DDL
GuiControl, , FilterSkill, % ListSkills()

GuiControl, , FilterShowDone, 0
GuiControl, , SearchQuery
GuiControl, Focus, SearchQuery
return

;~ ===============================================================================
;~ Search subroutine:

Search:
Critical
GuiControlGet, SearchString, , SearchQuery
GuiControlGet, FilterConfidenceSelected, , ConfidenceChoose
GuiControlGet, FilterSkillSelected, , FilterSkill
GuiControlGet, FilterShowDone, 
UpdateList(Selection, FilterConfidenceSelected, FilterSkillSelected)
return