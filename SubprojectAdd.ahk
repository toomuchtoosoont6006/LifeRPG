;~ ===============================================================================
;~ Add subproject for a selected project:

AddSubproject:
Selection := LV_GetNext("","F")
LV_GetText(SelectedProjectID, Selection, 1)
If (SelectedProjectID == "ID")
{
	return
}
else
{
	ProjectInfo := db.OpenRecordSet("SELECT * FROM projects WHERE id = " SelectedProjectID )
	while(!ProjectInfo.EOF)
	{
		ParentProjectName := ProjectInfo["project"]
		ProjectInfo.MoveNext()
	}
	ProjectInfo.Close()
	;UpdateList(Selection)
}
GuiChildInit("AddSubproject")
Gui, AddSubproject:Add, Text, w270, Parent Project:`n%ParentProjectName%
;Gui, AddSubproject:Add, Text, vParentName W270, %ParentProjectName%

Gui, AddSubproject:Add, Text, , Subproject Name:
Gui, AddSubproject:Add, Edit, vProjectName W270,

Gui, AddSubproject:Add, Text, section, &Difficulty:
Gui, AddSubproject:Add, DropDownList, vProjectDifficulty, ;% ListDifficulties("Really Easy")

Gui, AddSubproject:Add, Text, ys, Set S&kill:
SPSkills := ListSkills()
Gui, AddSubproject:Add, ComboBox, vProjectSkill gSPSkillAutoComplete w130 r7, % SPSkills

Gui, AddSubproject:Add, Text, xm, Impo&rtance:
Gui, AddSubproject:Add, DropDownList, vProjectImportance, % ListImportance("Must")

Gui, AddSubproject:Add, Button, Default gAddSubprojectSubmit w80 xm y+20, &Submit

WinGetPos,xd,yd,wd,hd,%WindowFind%
xc := CenterX(300)
yc := CenterY(200)
Gui, AddSubproject:Show, w300 h240 x%xc% y%yc%, Add Subproject
return

SPSkillAutoComplete:
Critical
Gui, AddSubproject:Submit, NoHide
If (!GetKeyState("BackSpace","P") && ProjectSkill && Pos := InStr(SPSkills, "|" . ProjectSkill))
{
	Found := SubStr(SPSkills, pos+1, InStr(SPSkills, "|", 1, Pos + 1) - Pos - 1)
	GuiControl, AddSubproject:Text, ProjectSkill, %Found%
	SendInput % "{End}" . "+{Left " . StrLen(Found) - StrLen(ProjectSkill) . "}"
}
return

AddSubprojectSubmit:
Gui, AddSubproject:Submit, NoHide
Record	:= {}
Record.Project	:= ProjectName
Record.Difficulty	:= ProjectDifficulty
Record.Importance	:= ProjectImportance
Record.Parent		:= SelectedProjectID
Record.skill		:= ProjectSkill
Record.dateEntered	:= A_Now
S := db.Insert(Record, "projects")
gosub FilterUpdate
RefreshSkillsList(FilterSkillSelected)

AddSubprojectGuiEscape:
AddSubprojectGuiClose:
GuiChildClose("AddSubproject")
;UpdateList(Selection)
return