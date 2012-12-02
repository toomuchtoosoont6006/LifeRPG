;~ ===============================================================================
;~ Hotkeys:

;~ Pressing Alt+V focuses user on the ListView:
#If WinActive(WindowFind)
!x::
GuiControl, Focus, MainList
LV_Modify(1, "Select Focus")
return

;~ Enables Ctrl+Backspace deletion in edit fields:
#If WinActive("ahk_class AutoHotkeyGUI")
^BS:: 
send, ^+{left}{delete}
return

;~ Give yourself points manually:
#If		; Clear out context sensitivity
; Easy tasks
^+1::
UpdateProgress("Really Easy Achievement", 5, "increase.wav")
return

; Medium difficulty
^+2::
UpdateProgress("Pretty Easy Achievement", 10, "medium.wav")
return

; Heavy lifting
^+3::
UpdateProgress("Medium Achievement", 25, "hard.wav")
return

; Completed big project
^+4::
UpdateProgress("Hard Achievement", 100, "goal.wav")
return

!F2::
HUD_Progress()
return

;~ !F1::
;~ if (WinActive(WindowFind))
	;~ WinMinimize, %WindowFind%
;~ else 
	;~ WinActivate, %WindowFind%
;~ return

^1::
^2::
^3::
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