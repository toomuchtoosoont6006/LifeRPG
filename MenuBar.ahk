; Menu Bar: ===================================================================================
Gui, 1:Default
; File:==========================================
Menu, FileMenu, Add, &New...`tCtrl+N, FileNew
Menu, FileMenu, Add, &Open...`tCtrl+O, FileOpen

;~ ; Create another menu destined to become a submenu of the above menu.
;~ Menu, Submenu1, Add, Item1, MenuHandler
;~ Menu, Submenu1, Add, Item2, MenuHandler
;~ ; Create a submenu in the first menu (a right-arrow indicator). When the user selects it, the second menu is displayed.
;~ Menu, FileMenu, Add, Recently Opened, :Submenu1

;~ ^ Leave for later release

Menu, FileMenu, Add
Menu, FileMenu, Add, E&xit, GuiClose

; View:===========================================
Menu, ViewMenu, Add, &Skill Stats...`tCtrl+K, SkillsView
Menu, ViewMenu, Add, &Project Log...`tCtrl+L, ProjectLog
Menu, ViewMenu, Add, &Finances...`tCtrl+F, MenuHandler

; Options:=========================================
Menu, OptionsMenu, Add, &Profile...`tCtrl+P, ProfileEdit
Menu, OptionsMenu, Add, &Sounds...`tCtrl+S, SoundEdit
Menu, OptionsMenu, Add, S&ettings...`tCtrl+E, SettingsEdit

; Help:===========================================
Menu, HelpMenu, Add, &Reference..., ReferenceHotkeys
Menu, HelpMenu, Add, &Discussion, Discussion
Menu, HelpMenu, Add
Menu, HelpMenu, Add, &About, About


; Attach the sub-menus that were created above.
Menu, MenuBar, Add, &File, :FileMenu  
Menu, MenuBar, Add, &View, :ViewMenu
Menu, MenuBar, Add, &Options, :OptionsMenu
Menu, MenuBar, Add, &Help, :HelpMenu

Gui, Menu, MenuBar