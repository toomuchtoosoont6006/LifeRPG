; Help menu items:========================================================================
ReferenceHotkeys:
GuiChildInit("RefHkeys")
RHw = 300
RHh = 250
RHx := CenterX(RHw)
RHy := CenterY(RHh)

HKRefText =
(
To toggle the Heads-Up Display, press: Alt+F2

To quickly add a project to your list for later, from anywhere; when you're doing anything, press:
Ctrl+Alt+A

To quickly log a finished project without having to add it to the list first, press:
Ctrl+Alt+D

To quickly give yourself points, use the following:
5 Points:	Ctrl+Shift+1
10 Points:	Ctrl+Shift+2
25 Points:	Ctrl+Shift+3
100 Points (Instantly go up a whole level!):	Ctrl+Shift+4
)

Gui, RefHkeys:Add, Edit,% "ReadOnly w" RHw-20 " h" RHh-20, % HKRefText

Gui, RefHkeys:Show, w%RHw% h%RHh% x%RHx% y%RHy%, Reference
return

RefHKeysGuiEscape:
RefHKeysGuiClose:
GuiChildClose("RefHKeys")
return

Discussion:
Run http://www.reddit.com/r/LifeRPG
return