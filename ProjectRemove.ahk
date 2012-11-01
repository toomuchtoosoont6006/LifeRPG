;~ ===============================================================================
;~ Confirm project deletion/removal:

RemoveProject:
Selection := LV_GetNext("","F")
LV_GetText(SelectedProjectID, Selection, 1)
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
	;Notification("RefreshSkillList(",FilterSkillSelected)
	gosub FilterUpdate
	;Notification(Selection . ", " . FilterImportanceSelected . ", " . FilterSkillSelected,"")
	UpdateList(Selection, FilterImportanceSelected, FilterSkillSelected)
	return
	
	RemoveProjectNo:
	RemoveProjectGuiClose:
	RemoveProjectGuiEscape:
	GuiChildClose("RemoveProject")
	return
}
return