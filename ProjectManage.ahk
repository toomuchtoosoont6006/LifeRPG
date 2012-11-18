; QuickAdd:
#If !WinExist("ahk_group exclude")
^!d::
Action := "QuickDone"
ProjectManage(Action)
return
#If

#If !WinExist("ahk_group exclude")
^!a::
Action := "QuickAdd"
ProjectManage(Action)
return
#If

; Add a new project:
AddProject:
Action := "Add"
ProjectManage(Action)
return

; Edit a selected project:
EditProject:
Action := "Edit"
ProjectManage(Action)
return

SkillsAutoComplete:
Critical
Gui, ProjectManager:Submit, NoHide
if (!ProjectSkillsEdit)
	return
else
{
	SkillACStopKeys := ["Tab", "`,", "Enter"]
	for k, v in SkillACStopKeys
	{
		Hotkey, %v%, SkillInsertAC, On
	}
	SkillACToolTip =
	SkillACObj := {}
	Loop, Parse, ProjectSkillsEdit, CSV
	{
		SkillToAC = %A_LoopField%
		SkillACObj.Insert(SkillToAC)
	}
	;Notification(SkillACObj[SkillACObj.MaxIndex()])
	SkillInputLast := SkillACObj[SkillACObj.MaxIndex()]
	if SkillInputLast is Space
	{
		SkillACShutOff()
		return
	}
	else
	{
		SkillACList := db.OpenRecordSet("SELECT DISTINCT skill FROM skills WHERE skill LIKE '" . SafeQuote(SkillInputLast) . "%' ORDER BY skill")
		while (!SkillACList.EOF)
		{
			SkillACToolTip .= SkillACList["skill"] . "`n"
			SkillACList.MoveNext()
		}
		SkillACList.Close()
		if SkillACToolTip is Space
		{
			SkillACShutOff()
			return
		}
		else	
			ToolTip, %SkillACToolTip%, A_CaretX, A_CaretY + 20
	}
}
return

SkillACShutOff()
{
	global SkillACStopKeys
	ToolTip
	for k, v in SkillACStopKeys
		Hotkey, %v%, Off
}

SkillInsertAC:
;Notification(SkillInputLast)
GuiControlGet, SkillsEditFocus, ProjectManager:FocusV
;Notification(SkillsEditFocus)
if (SkillsEditFocus = "ProjectSkillsEdit")
{
	Loop, Parse, SkillACToolTip, `n
	{
		Send % "{Backspace " . StrLen(SkillInputLast) . "}"
		SendRaw % A_LoopField
		for k, v in SkillACStopKeys
			Hotkey, %v%, Off
		Send `,	;%A_Space%
		if (A_Index = 1)
			break
	}
}
ToolTip
for k, v in SkillACStopKeys
	Hotkey, %v%, Off
return


ProjectManagerSubmit:
Gui, ProjectManager:Submit, NoHide
SkillACShutOff()
if (ProjectNameEdit = "")
{
	MsgBox, 8192, Error, Can't make a project with no name!
	return
}

if (ProjectSkillEdit = "All" || ProjectSkillEdit = "None")	; Sort this out during parse of skills
{
	MsgBox, 8192, Error, "All" and "None" can't be used as skill names!
	return
}	
if (Action = "Add" || Action = "QuickDone" || Action = "QuickAdd")
{
	Record 				:= {}
	Record.Project 		:= ProjectNameEdit
	Record.Difficulty 	:= KeyGet(DifficultyLevels, ProjectDifficultyEdit)
	Record.Importance 	:= KeyGet(ImportanceLevels, ProjectImportanceEdit)
	Record.dateEntered	:= A_Now
	db.Insert(Record, "projects")
	
	
	NewProjectID := LastProjectID()
	SkillsIDSetting := NewProjectID
	
	if (Action = "QuickDone" || Action = "QuickAdd")
	{
		Gui, ProjectManager:Cancel
		Gui, 1:Default
		if (Action = "QuickDone")
		{
			CompleteProject(LastProjectID())
		}
	}
}
else if (Action = "Edit")
{
	; Update project name:
	db.Query("UPDATE projects SET project = '" SafeQuote(ProjectNameEdit) "' WHERE ID = " SelectedProjectID )
	; Update Difficulty level:
	db.Query("UPDATE projects SET Difficulty = '" KeyGet(DifficultyLevels, ProjectDifficultyEdit) "' WHERE ID = " SelectedProjectID )
	; Wipe the existing skills tied to this project:
	db.Query("DELETE FROM skills WHERE projectID = " . SelectedProjectID)
	SkillsIDSetting := SelectedProjectID
	; Update Importance level:
	db.Query("UPDATE projects SET Importance = '" KeyGet(ImportanceLevels, ProjectImportanceEdit) "' WHERE ID = " SelectedProjectID )
}
; Insert skills:
Loop, parse, ProjectSkillsEdit, CSV
{
	if A_LoopField is Space
		continue
	SkillToInsert = %A_LoopField%	;This removes any leading space due to parse
	SkillToInsert := Capitalize(SkillToInsert)
	SkillsInsert := {}
	SkillsInsert.skill := SkillToInsert
	SkillsInsert.projectID := SkillsIDSetting
	db.Insert(SkillsInsert, "skills")	; Insert new skill to skills table
}
if (Action = "Add" || Action = "Edit")
{
	GuiChildClose("ProjectManager")
}
else if (Action = "QuickAdd" || Action = "QuickDone")
{
	Gui, ProjectManager:Cancel
	Gui, 1:Default
}
gosub FilterUpdate
RefreshSkillsList(FilterSkillSelected)
return

; Fall through below to close window.
ProjectManagerGuiEscape:
ProjectManagerGuiClose:
ToolTip
try
{
	for k, v in SkillACStopKeys
		Hotkey, %v%, Off
}
if (Action = "Add" || Action = "Edit")
{
	GuiChildClose("ProjectManager")
}
else if (Action = "QuickAdd" || Action = "QuickDone")
{
	Gui, ProjectManager:Cancel
	Gui, 1:Default
}
return

; Functions for Project Management: =============================================================


LastProjectID()
{
	global db
	table := db.Query("SELECT MAX(id) FROM projects")
	columnCount := table.Columns.Count()
	for each, row in table.Rows
   {
		Loop, % columnCount
			QuickID := row[A_index]
   }
   return QuickID
}

DBGetVal(Query, Val)
{
	global db
   R := db.OpenRecordSet(Query)
   while (!R.EOF)
	{
		V := R[Val]
		R.MoveNext()
	}
	R.Close()
	return V
}

ProjectManage(Action)	
{
	global
	ProjectNameEdit =
	ProjectDifficultyEdit =
	ProjectSkillEdit =
	; Get the row number of the selected project from the main project ListView:
	Selection := LV_GetNext("","F")
	; If editing, get the ID number of that project:
	if (Action = "Edit")
	{
		LV_GetText(SelectedProjectID, Selection, 1)	; Get project ID number from hidden column of ListView
		; If no row is selected and edit is called, do nothing and go back:
		If (SelectedProjectID == "ID")
		{
			return
		}
		else	; Get the data for the selected project to populate the edit fields:
		{
			ProjectInfo := db.OpenRecordSet("SELECT * FROM projects WHERE id = " SelectedProjectID )
			while(!ProjectInfo.EOF)
			{
				ProjectName 			:= ProjectInfo["project"]
				ProjectDifficulty		:= ProjectInfo["Difficulty"]
				ProjectImportance		:= ProjectInfo["importance"]
				ProjectInfo.MoveNext()
			}
			ProjectInfo.Close()
			
			ProjectSkill =
			CommaAdd =
			SkillsStringBuild := db.OpenRecordSet("SELECT * FROM skills WHERE projectID = " . SelectedProjectID )
			while (!SkillsStringBuild.EOF)
			{
				if (A_Index > 1)
					CommaAdd := ", "
				ProjectSkill .= CommaAdd . SkillsStringBuild["skill"] 
				SkillsStringBuild.MoveNext()
			}
			SkillsStringBuild.Close()
			
		}
	}
	else if (Action = "Add" || Action = "QuickDone" || Action = "QuickAdd")
	{
		ProjectName =
		ProjectDifficulty =
		ProjectSkill =
		ProjectImportance =
	}
	; Build the GUI window to either add or edit a project:
	; Initiate a modal child window owned by the main window (by default):
	if (Action = "Add" || Action = "Edit")
		GuiChildInit("ProjectManager")
	else if (Action = "QuickDone" || Action = "QuickAdd")
	{
		Gui, ProjectManager:New
		Gui, ProjectManager:Default
	}
	
	; Name of project:
	Gui, ProjectManager:Add, Text, , &Project Name:
	Gui, ProjectManager:Add, Edit, vProjectNameEdit W270 r1, %ProjectName%
	
	; Difficulty:
	Gui, ProjectManager:Add, Text, Section, &Difficulty:
	Gui, ProjectManager:Add, DropDownList, vProjectDifficultyEdit, % ListDifficulty(ProjectDifficulty)
	
	; Skill:
	Gui, ProjectManager:Add, Text, ys, Set S&kills:
	Gui, ProjectManager:Add, Edit, vProjectSkillsEdit gSkillsAutoComplete w130 r1, % ProjectSkill
	
	; Importance:
	Gui, ProjectManager:Add, Text, xm, Impo&rtance:
	Gui, ProjectManager:Add, DropDownList, vProjectImportanceEdit, % ListImportance(ProjectImportance)
	
	; Submit button:
	Gui, ProjectManager:Add, Button, Default gProjectManagerSubmit w80 xm y+20, &Submit
	
	; Set size of this window:
	Width = 300
	Height = 200
	
	; Calculate position for centering this child GUI window on wherever the main project list window is:
	xc := CenterX(300)
	yc := CenterY(200)
	; Show window:
	StringUpper, Action, Action, T
	if (Action = "QuickDone")
	{

		StringReplace, PMTitle, Action, done, Done
	}
	else if (Action = "QuickAdd")
		StringReplace, PMTitle, Action, add, Add
	else
		PMTitle := Action
	Gui, ProjectManager:Show, w%Width% h%Height% x%xc% y%yc%, %PMTitle% Project
	return
}