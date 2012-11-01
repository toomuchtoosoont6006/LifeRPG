; Edit User Profile:================================================================
ProfileEdit:
; Initialize modal child GUI window:
GuiChildInit("Profile")
; Define size and title etc:
ProfileW = 230
ProfileH = 140
ProfileX := CenterX(ProfileW)
ProfileY := CenterY(ProfileH)
ProfileTitle := "Edit Your Profile"

; Create content and fields:
; Name:
Gui, Profile:Add, Text, , Name:
Gui, Profile:Add, Edit, vProfileNameEdit w120 Limit21 r1, % ProfileGet("name")
; Title:
Gui, Profile:Add, Text, , Title:
Gui, Profile:Add, Edit, vProfileTitleEdit w200 r1, % ProfileGet("title")
; Save button:
Gui, Profile:Add, Button, Default y+10 w80 gProfileSubmit, Save
; Cancel:
Gui, Profile:Add, Button, x+10 w80 gProfileGuiClose, Cancel

; Show GUI:
Gui, Show, w%ProfileW% h%ProfileH% x%ProfileX% y%ProfileY%, %ProfileTitle%
; hang out here until user saves or closes:
return

; What do to when user submits:
ProfileSubmit:
Gui, Profile:Submit, NoHide
db.Query("UPDATE profile SET value = '" . SafeQuote(ProfileNameEdit) . "' WHERE setting = 'name'")
db.Query("UPDATE profile SET value = '" . SafeQuote(ProfileTitleEdit) . "' WHERE setting = 'title'")
GuiControl, HUD_Level:, HUD_Name, % ProfileGet("name")
GuiControl, HUD_Level:, HUD_Text, % HUD_LevelText . LevelCheck() . " " . ProfileGet("title")

; What to do when user closes or escapes window:
ProfileGuiClose:
ProfileGuiEscape:
GuiChildClose("Profile") ; Close up GUI child window.
return