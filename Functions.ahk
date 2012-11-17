;~ ===============================================================================
;~ Useful Functions:

; Stops user from being able to resize the listView columns on the main window:
;~ OnMessage(0x4E,"WM_NOTIFY")
;~ WM_NOTIFY(wParam, lParam, msg, hwnd)
;~ {   Critical
   ;~ Static HDN_BEGINTRACKA = -306, HDN_BEGINTRACKW = -326
   ;~ Code := -(~NumGet(lParam+0, 8))-1
   ;~ Return, Code = HDN_BEGINTRACKA || Code = HDN_BEGINTRACKW ? True : ""
;~ }



; Colored Listview rows and text

; OnMessage( WM_NOTIFY := 0x4E, "WM_NOTIFY" ) ; this line must be executed for the function to work

WM_NOTIFY( wparam, lparam, msg, hwnd ) {
   Static psz, pty, lvitem, itext, offset_code, offset_row, offset_color, LVM_GETITEMTEXT

; Up to 4 istviews can be colored at a time. Remeber to forcibly redraw them if more than one is
; fully drawn at once.
   Global Colored_LV_1, Colored_LV_2, Colored_LV_3, Colored_LV_4
   , Colored_LV_1_BG, Colored_LV_2_BG, Colored_LV_3_BG, Colored_LV_4_BG
   , Colored_LV_1_TX, Colored_LV_2_TX, Colored_LV_3_TX, Colored_LV_4_TX

   Critical

   If !( psz )
   {
; Prep the static vars on first run, including LVITEM for getting the color values from the listview.
      LVM_GETITEMTEXT := 0x1000 + ( A_IsUnicode ? 115 : 45 )
      psz := A_PtrSize ? A_PtrSize : 4
      pty := A_PtrSize = 8 ? "UPtr" : "UInt"
      offset_code := 2 * psz
      offset_row := 3 * psz + 24
      offset_color := 5 * psz + 28
      VarSetCapacity( lvitem, 52 + 2 * psz, 0 )
      VarSetCapacity( itext, 250 << !! A_IsUnicode, 0 )
      NumPut( 1, lvitem, 0, "UInt" )
      NumPut( &itext, lvitem, 20, pty )
      NumPut( 250, lvitem, 20 + psz, "UInt" )
   }

; Get the HWND of the controls sending this notification and see if it's one of our listviews
   ct_hwnd := NumGet( lparam + 0, 0, pty )
   If ( ( ct_hwnd = Colored_LV_1 && which_lv := "1" ) || ( ct_hwnd = Colored_LV_2 && which_lv := "2" )
   || ( ct_hwnd = Colored_LV_3 && which_lv := "3" ) || ( ct_hwnd = Colored_LV_4 && which_lv := "4" ) )
   && ( -12 = NumGet( lparam + 0, offset_code, "Int" ) ) ; NM_CUSTOMDRAW = -12
      If ( 1 = draw_stage := NumGet( lparam + 0, offset_code + 4, "Int" ) ) ; CDDS_PREPAINT = 1
         Return 0x20 ; CDRF_NOTIFYITEMDRAW = 0x20
      Else If ( draw_stage = 0x10001 ) ; CDDS_PREPAINT = 0x1, CDDS_ITEM = 0x10001
      {
; Now we know the notification is for an item prepaint, so we can adjust the text and bg colors.
; The colors are kept in the listview itself
         item := NumGet( lparam + 0, offset_row, "UInt" )
         If ( 0 < 0 | Colored_LV_%which_lv%_TX )
         {
            NumPut( Colored_LV_%which_lv%_TX - 1, lvitem, 8, "UInt" )
            SendMessage, LVM_GETITEMTEXT, item, &lvitem,, % "AHK_ID " ct_hwnd
            VarSetCapacity( itext, -1 )
            NumPut( Round( itext ), lparam + 0, offset_color, "UInt" )
         }
         If ( 0 < 0 | Colored_LV_%which_lv%_BG )
         {
            NumPut( Colored_LV_%which_lv%_BG - 1, lvitem, 8, "UInt" )
            SendMessage, LVM_GETITEMTEXT, item, &lvitem,, % "AHK_ID " ct_hwnd
            VarSetCapacity( itext, -1 )
            NumPut( Round( itext ), lparam + 0, offset_color + 4, "UInt" )
         }
      }
;      Else If ( draw_stage = 0x10002 ) ; CDDS_POSTPAINT = 0x2, CDDS_ITEM = 0x10001
;      {
;         ; Put here drawing to do after the item is drawn. E.g: draw custom grid lines.
;      }
	Static HDN_BEGINTRACKA = -306, HDN_BEGINTRACKW = -326
   Code := -(~NumGet(lParam+0, 8))-1
   Return, Code = HDN_BEGINTRACKA || Code = HDN_BEGINTRACKW ? True : ""
}

ProfileSet(setting, value)
{
	global db
	s := db.Query("UPDATE profile SET value = '" . SafeQuote(value) . "' WHERE setting = '" . setting . "'")
	return s
}

FormatTime(Time="", Format="")
{
	FormatTime, Out, %Time%, %Format%
	return Out
}

ProfileGet(setting)
{
	global db
	ProfileSet := db.OpenRecordSet("SELECT value FROM profile WHERE setting = '" . setting . "'")
	while (!ProfileSet.EOF)
	{
		Value := ProfileSet["value"]
		ProfileSet.MoveNext()
	}
	ProfileSet.Close()
	return Value
}

Uppercase(String)
{
	StringUpper, String, String
	return String
}

Capitalize(String)
{
	Initial := SubStr(String, 1, 1)
	StringUpper, Initial, Initial
	StringTrimLeft, String, String, 1
	return Initial . String
}

SafeQuote(string)		; Escape single quotes for sql update. Insert doesn't seem to need it because the DB library handles it.
{
	StringReplace, string, string, ','', All
	return string
}

CenterX(w)
{
	global WindowFind
	WinGetPos,Fx,Fy,Fw,Fh,A
	return Fx + Round(Fw/2) - Round(w/2)
}

CenterY(h)
{
	global WindowFind
	WinGetPos,Fx,Fy,Fw,Fh,A
	return Fy + Round(Fh/2) - Round(h/2)
}

GuiMsgBox(Name, Title, Text, w=170, h=60)
{
	GuiChildInit(Name)
	Gui, %Name%:Add, Text, w%w% Center, %Text%
	Gui, %Name%:Add, Button, % "Default g" Name "Yes w40 x" Round((w-80)/2), &Yes
	Gui, %Name%:Add, Button, Default x+1 g%Name%No w40, &No
	MX := CenterX(w)
	MY := CenterY(h)
	Gui, %Name%:Show, w%w% h%h% x%mx% y%my%, %Title%
	Gui, %Name%:-MinimizeBox -MaximizeBox
	return
}

GuiChildInit(Child, Parent=1)
{
	Gui, %Child%:New
	Gui, %Child%:+Owner%Parent%
	Gui, %Parent%:+Disabled
	Gui, %Child%:Default
	return
}

GuiChildClose(Child, Parent=1)
{
	Gui, %Parent%:-Disabled
	Gui, %Child%:Cancel
	Gui, %Parent%:Default
	return
}