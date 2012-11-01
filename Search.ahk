;~ ===============================================================================
;~ Filter ListView by priority:


;~ UpdateList(,FilterImportanceSelected,FilterSkillSelected)
;~ return

;~ ===============================================================================
; Filter main projects ListView by available skills:
FilterUpdate:
ImportanceUpdate:
FilterSkillUpdate:
GuiControlGet, FilterImportanceSelected, 1:, ImportanceChoose
GuiControlGet, FilterSkillSelected, 1:, FilterSkill
GuiControlGet, FilterShowDone, 1:, FilterShowDone
UpdateList(Selection,FilterImportanceSelected,FilterSkillSelected)
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
GuiControlGet, FilterImportanceSelected, , ImportanceChoose
GuiControlGet, FilterSkillSelected, , FilterSkill
GuiControlGet, FilterShowDone, 
UpdateList(Selection, FilterImportanceSelected, FilterSkillSelected)
return