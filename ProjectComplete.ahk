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
	; Get the difficulty to know how many points to award and the skill to show in notification
	CompletedProject := db.OpenRecordSet("SELECT * FROM projects WHERE id = " SelectedProjectID)
	while (!CompletedProject.EOF)
	{
		DifficultyToAward 	:= CompletedProject["difficulty"]
		SkillToIncrease 		:= CompletedProject["skill"]
		CompletedProject.MoveNext()
	}
	CompletedProject.Close()
	
	; Mark project as done:
	db.Query("UPDATE projects SET difficulty = 0, importance = '', dateDone = " . A_Now . ", levelDone = " . LevelGet() . " WHERE id = " SelectedProjectID)
	
	/*
	; Get the level count for the skill if the project has one:
	if (SkillToIncrease)
	{
		Table := db.Query("SELECT COUNT(skill) FROM projects WHERE skill = '" . SkillToIncrease . "' AND difficulty = 'Done'")
		columnCount := table.Columns.Count()
		for each, row in table.Rows
	   {
			Loop, % columnCount
				SkillLevel := row[A_index]
	   }
	}
	*/
	
	; Get the amount of points to award for the chosen level
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
	if (SkillToIncrease)
		Notification("SKILL INCREASED", SkillToIncrease . " increased to " . SkillLevel)
}