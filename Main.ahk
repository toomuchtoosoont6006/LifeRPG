#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines -1	
#SingleInstance force
#NoTrayIcon

/* ===============================================================================
 * LifeRPG r2 - Motivation and Confidence Building System
 * Initial Release 9/20/2012
 * 
 * Copyright (c) 2012 by Jayvant Javier Pujara
 * Licensed under GPL
 * JJPujara@gmail.com
 * 
 * 
 * ===============================================================================
 */

#Include <DBA>
#Include Settings.ahk
#Include HUD.ahk
#Include Momentum.ahk
#Include Functions.ahk
#Include MenuBar.ahk
#Include ProjectsView.ahk
#Include Hotkeys.ahk
#Include Search.ahk
#Include ProjectManage.ahk
#Include ProjectRemove.ahk
#Include ProjectComplete.ahk
#Include SubprojectAdd.ahk
#Include SkillsView.ahk
#Include ProjectLog.ahk
#Include ProfileEdit.ahk
#Include SettingsEdit.ahk
#Include About.ahk
#Include Help.ahk
#Include FileManage.ahk

MenuHandler:
return