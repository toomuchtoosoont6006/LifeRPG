;~ ===============================================================================
;~ Confirm project deletion/removal:

RemoveProject:
Selection := LV_GetNext("","F")
LV_GetText(SelectedProjectID, Selection, IDCol)
If (SelectedProjectID == "ID")
{
	return
}
else
{
	GuiMsgBox("RemoveProject", "Remove Project", "Delete this project?")
	return
	
	RemoveProjectYes:
	Gui, RemoveProject:Submit, NoHide
	db.Query("DELETE FROM projects WHERE id = " SelectedProjectID )
	GuiChildClose("RemoveProject")
	RefreshSkillsList(FilterSkillSelected)
	gosub FilterUpdate
	;UpdateList(Selection, FilterConfidenceSelected, FilterSkillSelected)
	return
	
	RemoveProjectNo:
	RemoveProjectGuiClose:
	RemoveProjectGuiEscape:
	GuiChildClose("RemoveProject")
	return
}
return