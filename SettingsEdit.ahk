; Edit general application settings: ===================================================

SettingsEdit:
GuiChildInit("SettingsEdit")
; Define size and positions:
SettingsW = 400
SettingsH = 80
SettingsX := CenterX(SettingsW)
SettingsY := CenterY(SettingsH)

; Create content and fields:
; Show HUD on program start checkbox:
Gui, SettingsEdit:Add, Checkbox, vSettingHUDShowOnStartup, Show the Heads-Up Display (HUD) on program start.
StateHUDShow := SettingGet("HUD","ShowOnStartup")
if (StateHUDShow = "Error")
	StateHUDShow = 0

GuiControl, SettingsEdit:, SettingHUDShowOnStartup, % StateHUDShow

; Save button:
Gui, SettingsEdit:Add, Button, Default y+30 xm w80 gSettingsEditSubmit, &Save
; Cancel:
Gui, SettingsEdit:Add, Button, x+10 w80 gSettingsEditGuiClose, &Cancel

; Show GUI:
Gui, SettingsEdit:Show, w%SettingsW% h%SettingsH% x%SettingsX% y%SettingsY%, %SettingsTitle%
return

; What do to when user submits:
SettingsEditSubmit:
Gui, SettingsEdit:Submit, NoHide
SettingSet("HUD","ShowOnStartup", SettingHUDShowOnStartup)

; What to do when user closes or escapes window:
SettingsEditGuiClose:
SettingsEditGuiEscape:
GuiChildClose("SettingsEdit") ; Close up GUI child window.
return