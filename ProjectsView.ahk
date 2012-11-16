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
Gui, Add, Text, x+10 vConfidenceChooseText, &Confidence: 
Gui, Add, DropDownList, vConfidenceChoose gFilterUpdate x+5 w60, All||	; Filtering subroutines are located in Search.ahk
GuiControl, , ConfidenceChoose, % ListConfidence("All")

; Filter view by skill:
Gui, Add, Text, x+10 vSkillChooseText, S&kill:
Gui, Add, DropDownList, vFilterSkill gFilterSkillUpdate x+5 r10, All||None|
GuiControl, , FilterSkill, % ListSkills()

; Show done or not:
Gui, Add, Checkbox, vFilterShowDone gFilterUpdate x+10, Show do&ne


;~ ListView:
Gui, Add, ListView, x0 y+15 r20 Grid AltSubmit -Multi Count%CountUp% vMainList hwndColored_LV_1, ID|ConfidenceID|ParentID|ColorID|Confidence|Project|Parent
}
Colored_LV_1_BG = 4 ;ColorIDCol
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
GuiControl, MoveDraw, ConfidenceChooseText, % "x" 50 + SearchBarWidth + 55 
GuiControl, MoveDraw, ConfidenceChoose, % "x" 50 + SearchBarWidth + 120 
GuiControl, MoveDraw, SkillChooseText, % "x" 50 + SearchBarWidth + 190
GuiControl, MoveDraw, FilterSkill, % "x" 50 + SearchBarWidth + 220
GuiControl, MoveDraw, FilterShowDone, % "x" 50 + SearchBarWidth + 350
return

;~ ===============================================================================
;~ What to do when main window is closed:
GuiClose:
ExitApp



;Main ListView-related Functions==================================================
; Call to refresh skills list after adding a new skill:
RefreshSkillsList(SkillChosen="All")
{
	global
	if (SkillChosen = "All" || SkillChosen = "")
	{
		GuiControl, , FilterSkill, |All||None|
		GuiControl, , FilterSkill, % ListSkills()
	}
	else if (SkillChosen = "None")
	{
		GuiControl, , FilterSkill, |All|None||
		GuiControl, , FilterSkill, % ListSkills()
	}
	else
	{
		PickSkill := ListSkills()
		if (InStr(PickSkill, SkillChosen))
		{
			GuiControl, , FilterSkill, |All|None|
			StringReplace, PickedSkill, PickSkill, %SkillChosen%, %SkillChosen%|
			GuiControl, , FilterSkill, % PickedSkill
		}
		else
		{
			GuiControl, , FilterSkill, |All||None|
			GuiControl, , FilterSkill, % ListSkills()
		}
	}
	GuiControlGet, FilterSkillSelected, , FilterSkill
}


ListSkills(Selected="")
{
	global db
	SkillList := Object()
	Skills := db.OpenRecordSet("SELECT DISTINCT skill FROM skills ORDER BY skill")
	while(!Skills.EOF)
	{
		Skill := Skills["skill"]
		If (Skill <> "")
			SkillList.Insert(Skill)
		Skills.MoveNext()
	}
	Skills.Close()
	SkillComboList =
	For Num, Skill in SkillList
	{
		SkillComboList .= Skill . "|"
		if (Selected and Skill = Selected)
			SkillComboList .= "|"
	}
	return SkillComboList
}

ListConfidence(SetConfidence="")
{
	global ConfidenceList
	For k, v in ConfidenceList
	{
		if (k = SetConfidence)
			v := v . "|"
		else if (k = 1 && SetConfidence <> "All")
			v := v . "|"
		ConfidenceFormatted .= v . "|"
	}
	return ConfidenceFormatted
}

KeyGet(obj, val)
{
	for k, v in obj
	{
		if (v = val)
			return k
	}
}

ListPriorities(SetPriority="")
{
	global Priorities
	For k, imp in Priorities
	{
		if (imp = SetPriority)
			imp := imp . "|"
		else if (k = 1 && SetPriority <> "All")
			imp := imp . "|"
		PriorityList .= imp . "|"
	}
	return PriorityList
}

UpdateList(NextSelection="", ConfidenceSelected="All", Skill="All")
{
	global
	; A number from the database:
	IDCol = 1	
	; A number from the database:
	ConfIDCol = 2	
	; Number from the database:
	ParentIDCol = 3		
	
	; A number added from confidence rank info:
	ColorIDCol = 4			
	
	; Text to be deciphered from rank code:
	ConfidenceCol = 5		
	; Text from the database:
	ProjNameCol 	= 6		
	; Text to be deciphered from database number:
	ParentCol = 7			
		
	
	Critical
	Gui, 1:Default
	GuiControlGet, SearchString, , SearchQuery
	GuiControl, -ReDraw, MainList
	LV_Delete()
	;~ if (Skill = "All") 
	;~ {
		;~ Filter := "Select * from projects "
	;~ }
	;~ else if (Skill <> "All" && Skill <> "None")
	;~ {
		;~ Filter := "SELECT p.* FROM projects p, skills s WHERE s.projectID = p.ID AND (s.skill IN ('" . Skill . "')) "
	;~ }
	;~ else if (Skill = "None")
		;~ filter .= ""
	;~ if (ConfidenceSelected <> "" || FilterShowDone <> "" || Skill <> "" || SearchString <> "")
		;~ Filter .= "WHERE "
	;~ if (SearchString <> "")
		;~ Filter .= "project LIKE '%" SafeQuote(SearchString) "%' AND"
	;~ if (FilterShowDone <> 1)
		;~ Filter .= " confidence is not null "	; change this to 0 eventually
	;~ else if (FilterShowDone = 1)
		;~ Filter .= " confidence = 0 OR confidence is null"
	;~ if (ConfidenceSelected && ConfidenceSelected <> "All")
		;~ Filter .= " AND confidence = " KeyGet(ConfidenceList, ConfidenceSelected) " "
	
	; Skills:
	if (Skill = "All")
	{
		Filter := "SELECT * FROM Projects "
	}
	else if (Skill <> "None")
	{
		Filter := "SELECT p.* FROM projects p, skills s WHERE s.projectID = p.ID AND (s.skill IN ('" . Skill . "')) "
	}
	else if (Skill = "None")
	{
		Filter := "SELECT * FROM projects WHERE ID NOT IN (SELECT projectID FROM skills) "
	}
	; Completion state:
	if (Skill <> "None" && Skill <> "All" || Skill = "None")
		Filter .= "AND "
	else
		Filter .= "WHERE "
	if (FilterShowDone = 1)
		Filter .= "confidence = 0 or confidence is null "
	else 
		Filter .= "confidence is not null "
	
	; Confidence level
	if (ConfidenceSelected <> "All")
		Filter .= "AND confidence = " . KeyGet(ConfidenceList, ConfidenceSelected) . " "
	
	; Search string:
	if (SearchString <> "")
		Filter .= "AND project LIKE '%" . SafeQuote(SearchString) "%'"
		
	;Notification(ConfidenceSelected, Filter)
	
	Projects := db.OpenRecordSet(Filter)
	while (!Projects.EOF)
	{
		ID := Projects["id"]
		Confidence := Projects["confidence"]
		Project := Projects["project"]
		Parent := Projects["parent"]
		LV_Add("", ID, Confidence, Parent,"","", Project,"" )	; This where database info is added to main ListView
		Projects.MoveNext()
	}
	Projects.Close()
	GuiControl, -ReDraw, MainList
	LV_ModifyCol(IDCol, "Integer sortdesc")	; Enable this to sort by ID, which could show most recent or oldest first, depending.
	LV_ModifyCol(ConfIDCol, "sort")
	
	If (NextSelection)
		LV_Modify(NextSelection, "Focus Select Vis")
	
	; Display language from database codes and set colors:
	Times := LV_GetCount()
	Loop % Times
	{
		ThisLine := A_Index
		
		; Display parent projects names:
		LV_GetText(ParentID, ThisLine, ParentCol)
		GetParent := db.OpenRecordSet("SELECT project FROM projects WHERE id = " ParentID)
		while (!GetParent.EOF)
		{
			ParentName := GetParent["project"]
			GetParent.MoveNext()
		}
		GetParent.Close()
		LV_Modify(ThisLine, "Col" . ParentCol,ParentName)
		
		; Display confidence level names and set color codes:
		for k, v in ConfidenceList
		{
			LV_GetText(ConfidenceCode, ThisLine, ConfIDCol)
			if (k = ConfidenceCode)
			{
				LV_Modify(ThisLine, "Col" . ConfidenceCol, v)
				LV_Modify(ThisLine, "Col" . ColorIDCol, Colors[k])
			}
			else if (ConfidenceCode = "" || ConfidenceCode = 0)
			{
				LV_Modify(ThisLine, "Col" . ConfidenceCol, "Done")
				LV_Modify(ThisLine, "Col" . ColorIDCol, BGR("F5FFFA"))
			}
		}
		
		; Display parent project names:
		LV_GetText(ParentID, ThisLine, ParentIDCol)
		GetParent := db.OpenRecordSet("SELECT project FROM projects WHERE id = " ParentID)
		while (!GetParent.EOF)
		{
			ParentName := GetParent["project"]
			GetParent.MoveNext()
		}
		GetParent.Close()
		LV_Modify(ThisLine, "Col" . ParentCol, ParentName)
		
	}
	
	; Resize columns here. Hide anything unfriendly/coded:
	LV_ModifyCol()
	MainColCount := LV_GetCount("Col")
	Loop % MainColCount
		LV_ModifyCol(A_Index,"AutoHdr")
	LV_ModifyCol(IDCol, 0)	; Hide ID column
	LV_ModifyCol(ColorIDCol, 0)	; Hide Color column
	LV_ModifyCol(ConfIDCol, 0)	; etc.
	LV_ModifyCol(ParentIDCol, 0)
	
	; Enable ListView coloring:
	OnMessage( WM_NOTIFY := 0x4E, "WM_NOTIFY" )
	GuiControl, +ReDraw, MainList
	return
}