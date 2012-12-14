;~ ===============================================================================
;~ Hotkeys:

;~ Pressing Alt+V focuses user on the ListView:
#If WinActive(WindowFind)
!x::
Gui, ListView, MainList
GuiControl, Focus, MainList
LV_Modify(1, "Focus Select Vis")
return

!z::
Gui, ListView, SideList
GuiControl, Focus, SideList
LV_Modify(LV_GetNext(), "Focus Select Vis")
return

;~ Enables Ctrl+Backspace deletion in edit fields:
#If WinActive("ahk_class AutoHotkeyGUI")
^BS:: 
send, ^+{left}{delete}
return

;~ Give yourself points manually:
#If		; Clear out context sensitivity so it works everywhere
; Easy tasks
^+1::
UpdateProgress(DifficultyLevels[1] . " Achievement", AwardLevels[1], "increase.wav")
return

; Medium difficulty
^+2::
UpdateProgress(DifficultyLevels[2] . " Achievement", AwardLevels[2], "medium.wav")
return

; Heavy lifting
^+3::
UpdateProgress(DifficultyLevels[3] . " Achievement", AwardLevels[3], "hard.wav")
return

; Completed big project
^+4::
UpdateProgress("Epic Achievement", 100, "goal.wav")
return

; Toggle HUD:
!F2::
HUD_Progress()
return


#If WinActive(WindowFind)
; Quickly assign new Difficulty to project via Ctrl+Number:
^1::
^2::
^3::
Gui, ListView, MainList
Selection := LV_GetNext("","F")
LV_GetText(SelectedProjectID, Selection, IDCol)
If (SelectedProjectID == "ID")
{
	return
}
else
{	
	StringTrimLeft, NewDifficulty, A_ThisHotkey, 1
	db.Query("UPDATE projects SET difficulty = " NewDifficulty " WHERE id = " SelectedProjectID )
	gosub FilterUpdate
	;UpdateList(Selection, FilterImportanceSelected, FilterSkillSelected)
	return
}
return

; Quickly assign new Importance to project via Shift+Number:
+1::
+2::
+3::
+4::
Gui, ListView, MainList
Selection := LV_GetNext("","F")
LV_GetText(SelectedProjectID, Selection, IDCol)
If (SelectedProjectID == "ID")
{
	return
}
else
{	
	StringTrimLeft, NewImportance, A_ThisHotkey, 1
	db.Query("UPDATE projects SET importance = " NewImportance " WHERE id = " SelectedProjectID )
	gosub FilterUpdate
	return
}
return
#If