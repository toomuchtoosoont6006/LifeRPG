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

SkillAutoComplete:
Critical
Gui, ProjectManager:Submit, NoHide
If (!GetKeyState("BackSpace","P") && ProjectSkillEdit && Pos := InStr(SkillsDB, "|" . ProjectSkillEdit))
{
	Found := SubStr(SkillsDB, pos+1, InStr(SkillsDB, "|", 1, Pos + 1) - Pos - 1)
	GuiControl, ProjectManager:Text, ProjectSkillEdit, %Found%
	SendInput % "{End}" . "+{Left " . StrLen(Found) - StrLen(ProjectSkillEdit) . "}"
}
return

ProjectManagerSubmit:
Gui, ProjectManager:Submit, NoHide
if (ProjectNameEdit = "")
{
	MsgBox, 8192, Error, Can't make a project with no name!
	return
}
if (ProjectSkillEdit = "All" || ProjectSkillEdit = "None")
{
	MsgBox, 8192, Error, "All" and "None" can't be used as skill names!
	return
}	
if (Action = "Add" || Action = "QuickDone" || Action = "QuickAdd")
{
	Record 				:= {}
	Record.Project 		:= ProjectNameEdit
	Record.Difficulty 	:= ProjectDifficultyEdit
	Record.Importance 	:= ProjectImportanceEdit
	Record.Skill 			:= Capitalize(ProjectSkillEdit)
	Record.dateEntered	:= A_Now
	S := db.Insert(Record, "projects")
	if (Action = "QuickDone" || Action = "QuickAdd")
	{
		Gui, ProjectManager:Cancel
		Gui, 1:Default
		if (Action = "QuickDone")
		{
			table := db.Query("SELECT MAX(id) FROM projects")
			columnCount := table.Columns.Count()
			for each, row in table.Rows
		   {
				Loop, % columnCount
					QuickID := row[A_index]
		   }
			CompleteProject(QuickID)
		}
	}
}
else if (Action = "Edit")
{
	db.Query("UPDATE projects SET project = '" SafeQuote(ProjectNameEdit) "' WHERE ID = " SelectedProjectID )
	db.Query("UPDATE projects SET difficulty = '" SafeQuote(ProjectDifficultyEdit) "' WHERE ID = " SelectedProjectID )
	db.Query("UPDATE projects SET importance = '" SafeQuote(ProjectImportanceEdit) "' WHERE ID = " SelectedProjectID )
	; Make sure skill is title cased, just to look good:
	StringUpper, ProjectSkillEdit, ProjectSkillEdit, T	
	db.Query("UPDATE projects SET skill = '" SafeQuote(ProjectSkillEdit) "' WHERE ID = " SelectedProjectID )
}
;UpdateList(Selection, FilterImportanceSelected, FilterSkillSelected)
;Notification(Selection . FilterImportanceSelected . FilterSkillSelected, "")
;GuiControlGet, FilterSkillSelected, , FilterSkill
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


ProjectManage(Action)	
{
	;global db, ProjectNameEdit, ProjectDifficultyEdit, ProjectImportanceEdit, ProjectSkillEdit
	global
	ProjectNameEdit =
	ProjectDifficultyEdit =
	ProjectImportanceEdit =
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
				ProjectDifficulty 	:= ProjectInfo["difficulty"]
				ProjectImportance 	:= ProjectInfo["importance"]
				ProjectSkill 			:= ProjectInfo["skill"]
				ProjectInfo.MoveNext()
			}
			ProjectInfo.Close()
		}
	}
	else if (Action = "Add" || Action = "QuickDone" || Action = "QuickAdd")
	{
		ProjectName =
		ProjectDifficulty =
		ProjectImportance =
		ProjectSkill =
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
	Gui, ProjectManager:Add, Text, , &Difficulty:
	DifficultyList := ListDifficulties(ProjectDifficulty)
	Gui, ProjectManager:Add, DropDownList, vProjectDifficultyEdit, %DifficultyList%
	
	; Importance:
	if (Action <> "QuickDone")
	{
		Gui, ProjectManager:Add, Text, , &Importance:
		PriorityList := ListPriorities(ProjectImportance)
		Gui, ProjectManager:Add, DropDownList, vProjectImportanceEdit, %PriorityList%
	}
	
	; Skill:
	Gui, ProjectManager:Add, Text, x+20 y52, Set S&kill:
	; To set this, we need to go through all the skills on the table and get all the distinct skills:
	SkillsDB := ListSkills(ProjectSkill)
	Gui, ProjectManager:Add, ComboBox, vProjectSkillEdit gSkillAutoComplete w130 r7, % SkillsDB ;% ListSkills(ProjectSkill) 	;Diplomacy|Art|Piracy|Cleaning|Hunting
	
	; Submit button:
	Gui, ProjectManager:Add, Button, Default gProjectManagerSubmit w80 x15 y+70, &Submit
	
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

; Kind of duplicate with other skills get function I just made
