; Database Open/Select: =====================================================
FileOpen:
Gui, +OwnDialogs
FileSelectFile, NewDB, , data, Open a projects database, LifeRPG Database (*.db)
if (NewDB <> "")
{
	if (IsObject(db))
	{
		OldDB := db
		OldDB.Close()
	}
	; Set the db var to the new database:
	db := DBA.DataBaseFactory.OpenDataBase("SQLite", NewDB)
	
	; Check to see if database is old and needs to be updated:
	if (ProfileGet("release") = "")
	{	
		MsgBox Updating Database
		; Add columns to projects table:
		ProjectsNewCols := {"dateDone":"NUMERIC", "dateEntered":"NUMERIC", "skill":"TEXT", "levelDone":"NUMERIC"}
		for col, type in ProjectsNewCols
		{
			db.Query("ALTER TABLE projects ADD " . col . " " . type)
		}	
		
		; Create inventory table:
		CreateInventory := "CREATE TABLE inventory ( id INTEGER PRIMARY KEY, item TEXT, description TEXT, value NUMERIC, date NUMERIC, category TEXT )"
		db.Query(CreateInventory)
		
		; Create finances table:
		CreateFinances := "CREATE TABLE finances ( date NUMERIC, id INTEGER PRIMARY KEY, description TEXT, amount NUMERIC, category TEXT )"
		db.Query(CreateFinances)
		
		; Create profile table and fill in settings:
		;	points: 	0
		;	threshold: 100
		;	name:
		;	momentum:  100
		;	MMTLastUpdate: Right now
		;	title:
		;	release:	2
		CreateProfile := "CREATE TABLE profile ( setting TEXT, value TEXT )"
		db.Query(CreateProfile)
		ProfileSettings := {"points": 0, "threshold": 100, "name":"Edit Profile", "momentum": 100, "MMTLastUpdate": FormatTime(,"yyyyMMdd"), "title":"", "release":2}
		for setting, value in ProfileSettings
		{
			ProfileRecord := {}
			ProfileRecord.Setting := setting
			ProfileRecord.value := value
			db.Insert(ProfileRecord, "profile")
		}
	}

	; Update GUI controls to display new database data (HUD and main projects ListView)
	FileOpenGUI_Refresh()
}
return

FileNew:
Gui, +OwnDialogs
; Present dialog to set database file name
FileSelectFile, NewDB_Path, S24, New LifeRPG.db, New projects database, LifeRPG Database (*.db)
if (NewDB_Path <> "")
{
	; Get the desired filename:
	SplitPath, NewDB_Path, NewDB_Name, NewDB_Dir, NewDB_Ext
	
	; Refresh everything needed to "load" database, set as default, add to recents menu
	if (NewDB_Ext = "")
	{
		NewDB_Name .= ".db"
		NewDB_Path .= ".db"
	}
	
	NewDB := NewDB_Path
	
	if (IsObject(db))
	{
		OldDB := db
		OldDB.Close()
	}
	
	if (FileExist(NewDB_Path))
		FileDelete, %NewDB_Path%
	; Copy blank database to selected location and rename to desired name:
	FileCopy, Res\Blank.db, %NewDB_Path%
	
	; Point the db var to the new database:
	db := DBA.DataBaseFactory.OpenDataBase("SQLite", NewDB)
	
	; Update GUI controls to display new database data (HUD and main projects ListView)
	FileOpenGUI_Refresh()
}
return

FileOpenGUI_Refresh()
{
	global
	if (OldDB)
	{
		gosub ClearSearch
		MomentumLastUpdate := ProfileGet("MMTLastUpdate")
		HUD_Refresh()
	}
	SettingSet("File", "LastOpened", NewDB)  ; Update settings file to point to new "current" database:
}

SettingSet(Section, Key, Value)
{
	IniWrite, %Value%, data/Settings.ini, %Section%, %Key%
}

SettingGet(Section, Key)
{
	IniRead, Setting, data/Settings.ini, %Section%, %Key%
	return Setting
}