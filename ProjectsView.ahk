;~ ===============================================================================
;~ Building and Displaying the Main GUI:
Send !{F2}

; Improves performance for adding elements to ListView:
CountUp := db.Query("SELECT * FROM projects")
CountUp := CountUp.Rows.Count()	

WinVis = true
; Buttons for Main Gui Window:
Gui, 1:Default
Gui, Add, Button, y3 x15 gAddProject, &Add Project		; Press Alt+A to add project
Gui, Add, Button, y3 x+1 gEditProject, &Edit Project	; Edit project (Alt+E, and so on)
Gui, Add, Button, y3 x+1 gAddSubproject, Su&bproject		; Create subproject for selected task
Gui, Add, Button, y3 x+1 gCompleteProject, Project &Done	; Confirm project is done
Gui, Add, Button, y3 x+1 gRemoveProject, &Remove Project	; Confirm project deletion

;~ Search bar:
Gui, Add, Text, x15 y+1, &Search:%A_Space%	; Pressing Alt+C once focuses on search box
try {
Gui, Add, Edit, vSearchQuery gSearch x+1 w320 h20,
Gui, Add, Button, gClearSearch vClearSearchButton x+1, &Clear	; Pressing Alt+C again clears the search and thus resets the ListView


;~ Filter view by importance:
Gui, Add, Text, x+10 vImpChooseText, &Importance: 
Gui, Add, DropDownList, vImportanceChoose gImportanceUpdate x+5 w60, All||	; Filtering subroutines are located in Search.ahk
GuiControl, , ImportanceChoose, % ListPriorities("All")

; Filter view by skill:
Gui, Add, Text, x+10 vSkillChooseText, S&kill:
Gui, Add, DropDownList, vFilterSkill gFilterSkillUpdate x+5 r10, All||None|
GuiControl, , FilterSkill, % ListSkills()

; Show done or not:
Gui, Add, Checkbox, vFilterShowDone gFilterUpdate x+10, Show do&ne


;~ ListView:
Gui, Add, ListView, x0 y+15 r20 Grid AltSubmit -Multi Count%CountUp% vMainList hwndColored_LV_1, ID|Difficulty|Project|Importance|Parent|Color
}
Colored_LV_1_BG = 6
GuiControl, Focus, SearchQuery	; Focus on search bar by default
Gui, Show, w827 h600, %AppTitle%	; Show the GUI we've created
UpdateList()	; Show all projects
Gui, +Resize +MinSize621x	; Make GUI resizable
return

;~ ===============================================================================
;~ Main GUI Resizing information:

GuiSize:
if A_EventInfo = 1  ; The window has been minimized.  No action needed.
	return
; Otherwise, the window has been resized or maximized. Resize the controls to match.
GuiControl, Move, Mainlist,  % "H" . (A_GuiHeight - 55) . " W" . (A_GuiWidth)
; Resize search bar to fit dropdown filter controls:
if (A_GuiWidth > 811) ;827)
{
	SearchBarWidth := Round(A_GuiWidth*.40)
}
else if (A_GuiWidth <= 811)
{
	SearchBarWidth := Round(A_GuiWidth*.20)
}
GuiControl, MoveDraw, SearchQuery, % "w" SearchBarWidth
GuiControl, MoveDraw, ClearSearchButton, % "x" 50 + SearchBarWidth + 10
GuiControl, MoveDraw, ImpChooseText, % "x" 50 + SearchBarWidth + 55 
GuiControl, MoveDraw, ImportanceChoose, % "x" 50 + SearchBarWidth + 120 
GuiControl, MoveDraw, SkillChooseText, % "x" 50 + SearchBarWidth + 190
GuiControl, MoveDraw, FilterSkill, % "x" 50 + SearchBarWidth + 220
GuiControl, MoveDraw, FilterShowDone, % "x" 50 + SearchBarWidth + 350
return

;~ ===============================================================================
;~ What to do when main window is closed:
GuiClose:
ExitApp