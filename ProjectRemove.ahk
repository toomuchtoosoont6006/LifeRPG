;~ ===============================================================================
;~ Confirm project deletion/removal:

RemoveProject:
Gui +OwnDialogs
Gui, ListView, MainList
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
	db.Query("DELETE FROM skills WHERE projectID = " . SelectedProjectID)
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
	
	/*
	MsgBox, 36, Remove Project, Remove this project?
	IfMsgBox Yes
	{
		db.Query("DELETE FROM projects WHERE id = " . SelectedProjectID )
		db.Query("DELETE FROM skills WHERE projectID = " . SelectedProjectID)
		RefreshSkillsList(FilterSkillSelected)
		gosub FilterUpdate
		return
	}
	else
		return
	*/
}
return