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
if (SideListGet())
	Action := "SideAdd"
else
	Action := "Add"
ProjectManage(Action)
return

; Add a new subproject:
AddSubproject:
Action := "Subproject"
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
	SkillACStopKeys := ["Tab", "Enter"]
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
		Send `,%A_Space%
		if (A_Index = 1)
			break
	}
}
ToolTip
for k, v in SkillACStopKeys
	Hotkey, %v%, Off
return


ProjectManagerSubmit:
;Notification(Action, "Action")
ListSelected := "MainList"	; Allows Side List to be updated as well
Gui, ProjectManager:Default
Gui, ProjectManager:Submit, NoHide
SkillACShutOff()	; Use +Owndialogs instead
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
if (Action = "Add" || Action = "QuickDone" || Action = "QuickAdd" || Action = "Subproject" || Action = "SideAdd")
{
	Record 				:= {}
	Record.Project 		:= ProjectNameEdit
	Record.Difficulty 	:= KeyGet(DifficultyLevels, ProjectDifficultyEdit)
	Record.Importance 	:= KeyGet(ImportanceLevels, ProjectImportanceEdit)
	Record.dateEntered	:= A_Now
	if (Action = "Subproject" || Action = "SideAdd")
	{
		Record.Parent		:= SelectedProjectID
	}
	else
	{
		LV_GetText(NewParentSelectionID, LV_GetNext(), 1)
		;Notification(NewParentSelectionID, "NewParentSelectionID")
		if (NewParentSelectionID <> 0)
			Record.Parent		:= NewParentSelectionID
	}
	db.Insert(Record, "projects")
	
	
	NewProjectID := LastProjectID()
	SkillsIDSetting := NewProjectID
	
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
	; Update parent field:
	LV_GetText(NewParentSelectionID, LV_GetNext(), 1)
	if (NewParentSelectionID = 0)
		db.Query("UPDATE projects SET parent = '' WHERE ID = " . SelectedProjectID)
	else
		db.Query("UPDATE projects SET parent = " . NewParentSelectionID . " WHERE ID = " . SelectedProjectID)
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
	if (Action = "QuickDone")
	{
		CompleteProject(LastProjectID())
	}
}
gosub FilterUpdate
RefreshSkillsList(FilterSkillSelected)

; Fall through below to close window.
ProjectManagerGuiEscape:
ProjectManagerGuiClose:
ToolTip
try
{
	for k, v in SkillACStopKeys
		Hotkey, %v%, Off
}
if (Action = "Add" || Action = "Edit" || Action = "Subproject" || Action = "SideAdd")
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

ProjectManage(Action)	
{
	global
	if (Action = "SideAdd")
		Gui, ListView, SideList
	else
	{
		Gui, ListView, %ListSelected%
	}
	ProjectNameEdit =
	ProjectDifficultyEdit =
	ProjectSkillEdit =
	; Get the row number of the selected project from the main project ListView:
	Selection := LV_GetNext("","F")
	; If editing or adding subproject, get the ID number of that project:
	if (Action = "Edit" || Action = "Subproject" || Action = "SideAdd")
	{
		LV_GetText(SelectedProjectID, Selection, 1)	; Get project ID number from hidden column of ListView
		; If no row is selected and edit is called, do nothing and go back:
		If (SelectedProjectID == "ID" || !SelectedProjectID)
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
				ParentOptCurrID		:= ProjectInfo["parent"]
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
		if (ListSelected = "SideList")
			LV_GetText(SelectedProjectID, Selection, 1)	; Get project ID number from hidden column of "side" ListView, cause we be adding a new stand-alone project
		ParentOptCurrID =
		if (Action = "QuickAdd" || Action = "QuickDone")
			SelectedProjectID = 0
	}
	if (Action = "Subproject" || Action = "SideAdd")
	{
		; Temporary, working on where (if) to include parent project name in subproject-add box):
		SubProjParentName := ProjectName
		ProjectName =
		ProjectDifficulty =
		ProjectSkill =
		ProjectImportance =
	}	
	; Build the GUI window to either add or edit a project:
	; Initiate a modal child window owned by the main window (by default):
	if (Action = "Add" || Action = "Edit" || Action = "Subproject" || Action = "SideAdd")
		GuiChildInit("ProjectManager")
	else if (Action = "QuickDone" || Action = "QuickAdd")
	{
		Gui, ProjectManager:New
		Gui, ProjectManager:Default
	}
	
	; GUI elements/controls: ==========================================================================
	
	; Set size of this window:
	Width = 300
	Height = 200
	
	; Tab options:
	Gui, ProjectManager:Add, Tab2, x0 y0 w300 h200 -Wrap, Project|Parent|Scheduling|Rewards|Misc.
	
	; Project Tab: ============================================
	; Name of project:
	if (Action = "SideAdd" || Action = "Subproject")
		Gui, ProjectManager:Add, Text, ,% StringClip(SubProjParentName, 45) . " >>"
	else
		Gui, ProjectManager:Add, Text, , &Project Name:
	Gui, ProjectManager:Add, Edit, vProjectNameEdit W270 r1, %ProjectName%
	
	; Difficulty:
	Gui, ProjectManager:Add, Text, Section, &Difficulty:
	Gui, ProjectManager:Add, DropDownList, vProjectDifficultyEdit, % ListDifficulty(ProjectDifficulty)
	
	; Importance:
	Gui, ProjectManager:Add, Text, ys, Impo&rtance:
	Gui, ProjectManager:Add, DropDownList, vProjectImportanceEdit, % ListImportance(ProjectImportance)
	
	; Skill:
	Gui, ProjectManager:Add, Text, xs, S&kills (separate with a comma):
	Gui, ProjectManager:Add, Edit, vProjectSkillsEdit gSkillsAutoComplete w240 r1, % ProjectSkill
	
	; Submit button:
	Gui, Tab
	Gui, ProjectManager:Add, Button, Default gProjectManagerSubmit w80 xm y+10, &Submit
	
	; Parent Tab: ============================================
	Gui, Tab, 2
	; Search box:
	Gui, ProjectManager:Add, Text, , Search:
	Gui, ProjectManager:Add, Edit, % "x+1 gParentChangeSearch vParentChangeEdit r1 w" Width - 80,
	; ListView:
	if (ParentOptCurrID) 
		ParentListH = 5
	else
		ParentListH = 6
	Gui, ProjectManager:Add, ListView, % "y+3 xm vParentChangeList -Multi -Hdr r" ParentListH " w" Width - 20, ID|Project
	
	; Fill in ListView:
	if (!SelectedProjectID || SelectedProjectID = 0)
		ParentExcludeFilter := ""
	else
		ParentExcludeFilter := " AND id <> " . SelectedProjectID
	;Notification(SelectedProjectID, "SelectedProjectID")
	ParentOptions := db.OpenRecordSet("SELECT * FROM projects WHERE difficulty <> 0 " . ParentExcludeFilter)
	Gui, ProjectManager:Default
	while (!ParentOptions.EOF)
	{
		ParentOptID := ParentOptions["id"]
		ParentOptName := ParentOptions["project"]
		LV_Add("",ParentOptID, ParentOptName)	; Add projects to parents list
		ParentOptions.MoveNext()
	}
	ParentOptions.Close()
	
	; Sort possible parent projects alphabetically:
	LV_ModifyCol(2, "Sort AutoHdr")
	
	; Insert "None" option at the top:
	LV_Insert(1,"","0","None")
	
	; Hide ID col:
	LV_ModifyCol(1, 0)
	
	; Highlight current parent:
	if (ParentOptCurrID)
	{
		Loop % LV_GetCount()
		{
			POSelRow := A_Index
			LV_GetText(ParentOptMatch, POSelRow, 1)
			if (ParentOptMatch = ParentOptCurrID)
			{
				LV_Modify(POSelRow, "Focus Select")
				LV_Modify(POSelRow+4, "Vis")
			}
		}
		; Display current parent project:
		Gui, ProjectManager:Add, Text, , % StringClip(DBGetVal("SELECT project FROM projects WHERE id = " . ParentOptCurrID, "project"), 50)
	}
	else
		LV_Modify(1, "Focus Select Vis")
	
	; Calculate position for centering this child GUI window on wherever the main project list window is:
	xc := CenterX(Width)
	yc := CenterY(Height)
	
	; Show window:
	; Select title for Project Manager window:
	if (Action = "QuickAdd")
		PMTitle := "QuickAdd New Project"
	else if (Action = "QuickDone")
		PMTitle := "QuickDone Project"
	else if (Action = "Add")
		PMTitle := "Add New Project"
	else if (Action = "Edit")
		PMTitle := "Edit Project"
	else if (Action = "SideAdd" || Action = "Subproject")
		PMTitle := "Add New Subproject"
	
	if (Action = "QuickAdd" || Action = "QuickDone")	; If calling QuickAdd/Done windows, don't set XY coordinates so that they will center everywhere:
		Gui, ProjectManager:Show, w%Width% h%Height%, %PMTitle%
	else
		Gui, ProjectManager:Show, w%Width% h%Height% x%xc% y%yc%, %PMTitle%
	; Remove the skill auto-complete tooltip if LifeRPG window loses focus:
	SetTimer, ACWinWatch, 300
	return
	ACWinWatch:
	GuiControlGet, SkillEditWatch, ProjectManager:FocusV
	if (!WinActive("ahk_class AutoHotkeyGUI") || SkillEditWatch <> "ProjectSkillsEdit")
		SkillACShutOff()
	return
}

ParentChangeSearch:
Critical
Gui, ProjectManager:Default
; Update project list to show possible parents
LV_Delete()
GuiControlGet, ParentSearchQuery, , ParentChangeEdit
ParentOptions := db.OpenRecordSet("SELECT * FROM projects WHERE difficulty <> 0 " . ParentExcludeFilter . " AND project LIKE '%" . SafeQuote(ParentSearchQuery) . "%'")
GuiControl, -ReDraw, ParentChangeList
while (!ParentOptions.EOF)
{
	ParentOptID := ParentOptions["id"]
	ParentOptName := ParentOptions["project"]
	LV_Add("",ParentOptID, ParentOptName)
	ParentOptions.MoveNext()
}
ParentOptions.Close()

; Sort possible parent projects alphabetically:
LV_ModifyCol(2, "Sort AutoHdr")

; Insert "None" option at the top:
LV_Insert(1,"","0","None")

; Hide ID col:
LV_ModifyCol(1, 0)
GuiControl, +ReDraw, ParentChangeList
return