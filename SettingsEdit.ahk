; Edit app settings: ===================================================
;#If !WinActive("Skill Stats ahk_class AutoHotkeyGUI") && WinActive("LifeRPG ahk_class AutoHotkeyGUI")
;^s::
SettingsEdit:
GuiChildInit("SettingsEdit")
; Define size and positions:
SettingsW = 400
SettingsH = 140
SettingsX := CenterX(SettingsW)
SettingsY := CenterY(SettingsH)

; Create content and fields:
; Level Up Sound:
Gui, SettingsEdit:Add, Text, , Select sound file to use for &Level-Up Sound:
SettingLocationLevelUp := SettingGet("Sound","LevelUp")
if (SettingLocationLevelUp = "Error")
	SettingLocationLevelUp := ""
Gui, SettingsEdit:Add, Edit, vSettingsEditLevelUpEdit w300 r1, % SettingLocationLevelUp
Gui, SettingsEdit:Add, Button, x+1 gLevelUpSoundBrowse w80, &Browse
Gui, SettingsEdit:Add, Button, y+1 xm gSoundTestLevelUp w40, Test
Gui, SettingsEdit:Add, Button, x+1 gSoundTestLevelUpStop w40, Stop

; Save button:
Gui, SettingsEdit:Add, Button, Default y+30 xm w80 gSettingsEditSubmit, &Save
; Cancel:
Gui, SettingsEdit:Add, Button, x+10 w80 gSettingsEditGuiClose, &Cancel

; Show GUI:
Gui, SettingsEdit:Show, w%SettingsW% h%SettingsH% x%SettingsX% y%SettingsY%, %SettingsTitle%
; hang out here until user saves or closes:
return

LevelUpSoundBrowse:
Gui +OwnDialogs
FileSelectFile, NewLocationLevelUpSound, , , Select a sound file , Audio (*.wav; *.mp3)
GuiControl, SettingsEdit:, SettingsEditLevelUpEdit, % NewLocationLevelUpSound
return

SoundTestLevelUp:
GuiControlGet, LUSFile, SettingsEdit:, SettingsEditLevelUpEdit
SoundPlay % LUSFile
return

SoundTestLevelUpStop:
SoundPlay 341589134759384759348.wav
return

; What do to when user submits:
SettingsEditSubmit:
Gui, SettingsEdit:Submit, NoHide
SettingSet("Sound","LevelUp", SettingsEditLevelUpEdit)
LevelUpSound := SettingsEditLevelUpEdit


; What to do when user closes or escapes window:
SettingsEditGuiClose:
SettingsEditGuiEscape:
GuiChildClose("SettingsEdit") ; Close up GUI child window.
return