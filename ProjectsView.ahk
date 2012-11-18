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
Gui, Add, Text, x+10 vDifficultyChooseText, &Difficulty: 
Gui, Add, DropDownList, vDifficultyChoose gFilterUpdate x+5 w60, All||	; Filtering subroutines are located in Search.ahk
GuiControl, , DifficultyChoose, % ListDifficulty("All")

; Filter view by skill:
Gui, Add, Text, x+10 vSkillChooseText, S&kill:
Gui, Add, DropDownList, vFilterSkill gFilterSkillUpdate x+5 r10, All||None|
GuiControl, , FilterSkill, % ListSkills()

; Show done or not:
Gui, Add, Checkbox, vFilterShowDone gFilterUpdate x+10, Show do&ne


;~ ListView:
Gui, Add, ListView, x0 y+15 r20 Grid AltSubmit -Multi Count%CountUp% vMainList hwndColored_LV_1, ID|DifficultyID|ImportanceID|ParentID|ColorID|Difficulty|Project|Importance|Parent
}
Colored_LV_1_BG = 5 ;ColorIDCol
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
GuiControl, MoveDraw, DifficultyChooseText, % "x" 50 + SearchBarWidth + 55 
GuiControl, MoveDraw, DifficultyChoose, % "x" 50 + SearchBarWidth + 120 
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

ListDifficulty(SetDifficulty="")
{
	global DifficultyLevels
	For k, v in DifficultyLevels
	{
		if (k = SetDifficulty)
			v := v . "|"
		else if (k = 1 && SetDifficulty <> "All")
			v := v . "|"
		DifficultyFormatted .= v . "|"
	}
	return DifficultyFormatted
}

KeyGet(obj, val)
{
	for k, v in obj
	{
		if (v = val)
			return k
	}
}

ListImportance(SetImportance="")
{
	global ImportanceLevels
	For k, v in ImportanceLevels
	{
		if (k = SetImportance)
			v := v . "|"
		else if (k = 1 && SetImportance <> "All")
			v := v . "|"
		ImportanceFormatted .= v . "|"
	}
	return ImportanceFormatted
}

UpdateList(NextSelection="", DifficultySelected="All", Skill="All")
{
	global
	; The ID of the project - A number from the database:
	IDCol = 1	
	; The difficulty level - A number from the database:
	DiffIDCol = 2	
	; The importance level - A number from the database:
	ImpIDCol = 3
	; The ID number of the parent - A Number from the database:
	ParentIDCol = 4		
	
	; The color for the project - A number added from Difficulty rank info:
	ColorIDCol = 5			
	
	; Readable difficulty text - Text to be deciphered from rank code:
	DifficultyCol = 6		
	; Name of the project - Text from the database:
	ProjNameCol 	= 7	
	; Importance of the project - Text to be deciphered from rank number:
	ImportanceCol = 8
	; Name of parent project - Text to be deciphered from database number:
	ParentCol = 9			
		
	
	Critical
	Gui, 1:Default
	GuiControlGet, SearchString, , SearchQuery
	GuiControl, -ReDraw, MainList
	LV_Delete()
	
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
		Filter .= "Difficulty = 0 or Difficulty is null "
	else 
		Filter .= "Difficulty is not null "
	
	; Difficulty level
	if (DifficultySelected <> "All")
		Filter .= "AND Difficulty = " . KeyGet(DifficultyLevels, DifficultySelected) . " "
	
	; Search string:
	if (SearchString <> "")
		Filter .= "AND project LIKE '%" . SafeQuote(SearchString) "%'"
		
	;Notification(DifficultySelected, Filter)
	
	Projects := db.OpenRecordSet(Filter)
	while (!Projects.EOF)
	{
		ID := Projects["id"]
		Difficulty := Projects["Difficulty"]
		Project := Projects["project"]
		Importance := Projects["importance"]
		Parent := Projects["parent"]
		LV_Add("", ID, Difficulty,Importance,Parent,"","", Project,"","" )	; This where database info is added to main ListView
		Projects.MoveNext()
	}
	Projects.Close()
	GuiControl, -ReDraw, MainList
	LV_ModifyCol(IDCol, "Integer sortdesc")	; Enable this to sort by ID, which could show most recent or oldest first, depending.
	LV_ModifyCol(DiffIDCol, "sort")
	
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
		
		; Display Difficulty level names and set color codes:
		for k, v in DifficultyLevels
		{
			LV_GetText(DifficultyCode, ThisLine, DiffIDCol)
			if (k = DifficultyCode)
			{
				LV_Modify(ThisLine, "Col" . DifficultyCol, v)
				LV_Modify(ThisLine, "Col" . ColorIDCol, Colors[k])
			}
			else if (DifficultyCode = "" || DifficultyCode = 0)
			{
				LV_Modify(ThisLine, "Col" . DifficultyCol, "Done")
				LV_Modify(ThisLine, "Col" . ColorIDCol, BGR("F5FFFA"))
			}
		}
		
		; Display Importance level names:
		for k, v in ImportanceLevels
		{
			LV_GetText(ImportanceCode, ThisLine, ImpIDCol)
			if (k = ImportanceCode)
			{
				LV_Modify(ThisLine, "Col" . ImportanceCol, v)
			}
			else if (ImportanceCode = "" || ImportanceCode = 0)
			{
				LV_Modify(ThisLine, "Col" . ImportanceCol, "None")
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
	LV_ModifyCol(ColorIDCol, 0)	; Hide color code column
	LV_ModifyCol(DiffIDCol, 0)	; Hide difficulty code col
	LV_ModifyCol(ImpIDCol, 0)	; Hide importance code col
	LV_ModifyCol(ParentIDCol, 0)	; Hide parent ID col
	
	; Enable ListView coloring:
	OnMessage( WM_NOTIFY := 0x4E, "WM_NOTIFY" )
	GuiControl, +ReDraw, MainList
	return
}