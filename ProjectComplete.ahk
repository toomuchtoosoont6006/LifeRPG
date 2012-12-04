;~ ===============================================================================
;~ Confirm Project completion:

CompleteProject:
Gui, ListView, MainList
Selection := LV_GetNext("","F")
LV_GetText(SelectedProjectID, Selection, 1)
LV_GetText(ProjectCompletionState, Selection, 2)
If (SelectedProjectID == "ID" || ProjectCompletionState = "Done")
{
	return
}
else
{
	GuiMsgBox("CompleteProject", "Complete Project", "Done with project?")
	return
	
	CompleteProjectYes:
	Gui, CompleteProject:Submit, NoHide
	GuiChildClose("CompleteProject")
	
	CompleteProject(SelectedProjectID)
	MomentumPrev := ProfileGet("momentum")
	if (MomentumPrev < 100)
	{
		Anim := 100 - MomentumPrev
		Loop % Anim
		{
			GuiControl, HUD_Momentum:, HUD_MomentumBar, % MomentumPrev + A_Index
			GuiControl, HUD_Momentum:, HUD_MomentumPerc, % MomentumPrev + A_Index . "%"
			Sleep 10
		}
		ProfileSet("momentum", 100)
		Notification(Uppercase("Momentum Restored"), "Your MMT is back to 100%")
	}
	gosub FilterUpdate
	RefreshSkillsList(FilterSkillSelected)
	return
	
	CompleteProjectNo:
	CompleteProjectGuiClose:
	CompleteProjectGuiEscape:
	GuiChildClose("CompleteProject")
	return
}
return

CompleteProject(SelectedProjectID)
{
	global db, DifficultyLevels, AwardLevels
	; Get the difficulty to know how many points to award:
	CompletedProject := db.OpenRecordSet("SELECT * FROM projects WHERE id = " SelectedProjectID)
	while (!CompletedProject.EOF)
	{
		DifficultyToAward 	:= CompletedProject["difficulty"]
		CompletedProject.MoveNext()
	}
	CompletedProject.Close()
	
	; Mark project as done:
	db.Query("UPDATE projects SET difficulty = 0, dateDone = " . A_Now . ", levelDone = " . LevelGet() . " WHERE id = " SelectedProjectID) ; removed importance = '', 
	
	; Get the amount of points to award for the chosen level:
	for Num, Difficulty in DifficultyLevels
	{
		if (DifficultyToAward = Num)
			for Key, Award in AwardLevels
			{
				if (Num = Key)
					AwardGiven := Award
			}
	}
	
	UpdateProgress(DifficultyLevels[DifficultyToAward] . " Achievement", AwardGiven)
	
	; Show notifications for skill level increases:
	SkillIncreaseList := db.OpenRecordSet("SELECT * FROM skills WHERE projectID = " . SelectedProjectID)
	while (!SkillIncreaseList.EOF)
	{
		SkillToNotify := SkillIncreaseList["skill"]
		Table := db.Query("SELECT COUNT(id) FROM projects WHERE id IN (SELECT projectID FROM skills WHERE skill = '" . SafeQuote(SkillToNotify) . "') AND difficulty = 0")
		ColumnCount := Table.Columns.Count()
		for each, row in Table.Rows
	   {
			Loop, % ColumnCount
				SkillLevel := row[A_index]
			Notification("SKILL INCREASED", SkillToNotify . " increased to " . SkillLevel)
	   }
		SkillIncreaseList.MoveNext()
	}
	SkillIncreaseList.Close()
}