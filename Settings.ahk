;~ Autoload and initial settings loading section:============================================

;~ Set icon for window corner:
IconFile := "res/WP_RPG_VG.ico"
if FileExist(IconFile)
	Menu, Tray, Icon, %IconFile%
Menu, Tray, NoStandard

;~ Project confidence levels:
ConfidenceLevels := ["High", "Medium", "Low"]

; For DB conversion:
DifficultyLevels := ["Easy", "Medium", "Hard"] 

; Award points for each difficulty:
AwardLevels := [5, 10, 25]

; Difficulty colors:
Colors := [BGR("ADFF2F"), BGR("FFD700"), BGR("FF6347")]

;~ Priorities:
ImportanceLevels := ["Very High", "High", "Medium", "Low"]

BGR(RGB)
{
	R := SubStr(RGB, 1, 2)
	G := SubStr(RGB, 3, 2)
	B := SubStr(RGB, 5, 2)
	return "0x" . B . G . R
}

;~ The window title text:
AppTitle := "LifeRPG"

;~ Make it easier for the script to identify its own window if need be:
WindowFind := AppTitle . " ahk_class AutoHotkeyGUI"

;~ Level up sound location:
LevelUpSound := SettingGet("Sound", "LevelUp")
if (LevelUpSound = "Error" || !FileExist(LevelUpSound))
	LevelUpSound := ""

; Open connection to SQLite database:
ConnectionString := SettingGet("File", "LastOpened")		; Get last used database from settings.
if (ConnectionString = "Error" || ConnectionString = "")		; That means it's the first time it was run, so load the default db.
	ConnectionString := "data/LifeRPG.db"
AskLoad:
if (!FileExist(ConnectionString))	; User must have deleted or moved last used db, so ask to pick another or make a new one.
{
	Gui +OwnDialogs
	MsgBox, 51, %AppTitle% Error, Last loaded database `n"%connectionString%" `nwas not found.`n`nWould you like to open a different database?`nIf not, you must create a new one before you can continue.`n`nOtherwise, hit Cancel to quit the program.
	IfMsgBox Yes
	{
		gosub FileOpen
		if (!IsObject(db))
			gosub AskLoad
	}
	else IfMsgBox No
	{
		gosub FileNew
		if (!IsObject(db))
			gosub AskLoad
	}
	else
		ExitApp
}
else	; we can go ahead and load the last used db:
	db := DBA.DataBaseFactory.OpenDataBase("SQLite", ConnectionString)

db.Query("VACUUM")

; Hotkey do not activate list:
GroupAdd, exclude, New projects database
GroupAdd, exclude, Open a projects database
GroupAdd, exclude, Add Project ahk_class AutoHotkeyGUI
GroupAdd, exclude, Reference ahk_class AutoHotkeyGUI
GroupAdd, exclude, Edit Project ahk_class AutoHotkeyGUI
GroupAdd, exclude, Add Subproject ahk_class AutoHotkeyGUI
GroupAdd, exclude, Remove Project ahk_class AutoHotkeyGUI
GroupAdd, exclude, Complete Project ahk_class AutoHotkeyGUI
GroupAdd, exclude, QuickDone Project ahk_class AutoHotkeyGUI
GroupAdd, exclude, QuickAdd Project ahk_class AutoHotkeyGUI
GroupAdd, exclude, Skill Stats ahk_class AutoHotkeyGUI
GroupAdd, exclude, About ahk_class AutoHotkeyGUI
GroupAdd, exclude, Edit Your Profile ahk_class AutoHotkeyGUI
GroupAdd, exclude, Project Log ahk_class AutoHotkeyGUI
SettingsTitle := "Edit LifeRPG Settings"
GroupAdd, exclude, % SettingsTitle . " ahk_class AutoHotkeyGUI"
