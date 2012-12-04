; Edit app Sound: ===================================================
;#If !WinActive("Skill Stats ahk_class AutoHotkeyGUI") && WinActive("LifeRPG ahk_class AutoHotkeyGUI")
;^s::
SoundEdit:
GuiChildInit("SoundEdit")
; Define size and positions:
SoundW = 400
SoundH = 140
SoundX := CenterX(SoundW)
SoundY := CenterY(SoundH)

; Create content and fields:
; Level Up Sound:
Gui, SoundEdit:Add, Text, , Select sound file to use for &Level-Up Sound:
SoundLocationLevelUp := SettingGet("Sound","LevelUp")
if (SoundLocationLevelUp = "Error")
	SoundLocationLevelUp := ""
Gui, SoundEdit:Add, Edit, vSoundEditLevelUpEdit w300 r1, % SoundLocationLevelUp
Gui, SoundEdit:Add, Button, x+1 gLevelUpSoundBrowse w80, &Browse
Gui, SoundEdit:Add, Button, y+1 xm gSoundTestLevelUp w40, Test
Gui, SoundEdit:Add, Button, x+1 gSoundTestLevelUpStop w40, Stop

; Save button:
Gui, SoundEdit:Add, Button, Default y+30 xm w80 gSoundEditSubmit, &Save
; Cancel:
Gui, SoundEdit:Add, Button, x+10 w80 gSoundEditGuiClose, &Cancel

; Show GUI:
Gui, SoundEdit:Show, w%SoundW% h%SoundH% x%SoundX% y%SoundY%, %SoundTitle%
; hang out here until user saves or closes:
return

LevelUpSoundBrowse:
Gui +OwnDialogs
FileSelectFile, NewLocationLevelUpSound, , , Select a sound file , Audio (*.wav; *.mp3)
if (NewLocationLevelUpSound <> "")
	GuiControl, SoundEdit:, SoundEditLevelUpEdit, % NewLocationLevelUpSound
return

SoundTestLevelUp:
GuiControlGet, LUSFile, SoundEdit:, SoundEditLevelUpEdit
SoundPlay % LUSFile
return

SoundTestLevelUpStop:
SoundPlay 341589134759384759348.wav
return

; What do to when user submits:
SoundEditSubmit:
Gui, SoundEdit:Submit, NoHide
SettingSet("Sound","LevelUp", SoundEditLevelUpEdit)
LevelUpSound := SoundEditLevelUpEdit


; What to do when user closes or escapes window:
SoundEditGuiClose:
SoundEditGuiEscape:
GuiChildClose("SoundEdit") ; Close up GUI child window.
return