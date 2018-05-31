#SingleInstance, force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include, %A_ScriptDir%\lib\JSON.ahk

GroupAdd, PoEWindowGrp, Path of Exile ahk_class POEWindowClass ahk_exe PathOfExile.exe
GroupAdd, PoEWindowGrp, Path of Exile ahk_class POEWindowClass ahk_exe PathOfExileSteam.exe
GroupAdd, PoEWindowGrp, Path of Exile ahk_class POEWindowClass ahk_exe PathOfExile_x64.exe
GroupAdd, PoEWindowGrp, Path of Exile ahk_class POEWindowClass ahk_exe PathOfExile_x64Steam.exe

;
; ========= Settings =========
;
global data := {}
Try {
    FileRead, JSONFile, %A_ScriptDir%\data.json
    data := JSON.Load(JSONFile)
    If (not data.acts.Length()) {
        MsgBox, 16, , Error reading zone data! `n`nExiting script.
        ExitApp        
    }
} Catch e {
    MsgBox, 16, , % e "`n`nExiting script."
    ExitApp
}
 
opacity := 140
gui_1_toggle := 0
gui_2_toggle := 0
linenumber := 1

global PoEWindowHwnd := ""
WinGet, PoEWindowHwnd, ID, ahk_group PoEWindowGrp

Gosub, DrawGUI1
Gosub, DrawGUI2_1
Gosub, DrawGUI3_1

Return


;
; ========= MAIN / GUI =========
;
 
 
 
;
; ========= HOTKEY =========
;
 
;========== Quest Rewards =======
+F3::
    if (gui_2_toggle = 0)
    {
        Gosub, DrawGUI2_1
    }

    else
    {
        Gui, 2:Destroy
        gui_2_toggle := 0
    }
    Gosub, ActivatePOE
    return
     
    ^F3::
        Gui, 2:Destroy
        Gosub, DrawGUI2_1
        return

    Gosub, ActivatePOE     
return
 
 
;========== XP Range =======
+F4::
    if (gui_1_toggle = 0)
    {
        Gosub, DrawGUI1
    }
    else
    {
        Gui, 1:Destroy
        gui_1_toggle := 0
    }
    Gosub, ActivatePOE
return
 
;========== Zone Layouts =======
+F1::   
    if (gui_3_toggle = 0)
    {
        Gosub, DrawGUI3_1
    }
    else
    {
        Gui, 3:Destroy
        gui_3_toggle := 0
    }
    Gosub, ActivatePOE
return

^F1::
    GuiControl, Choose,DdlA,3
return

!F1::
    Control, Choose,DdlA,2
return

^F2::
return

!F2::
return

 
;========== Subs =======
 
ActivatePOE:
    WinActivate, ahk_id %PoEWindowHwnd%
return
 
DrawGUI1:
    Gui, 1:+E0x20 -Caption +LastFound +ToolWindow +AlwaysOnTop
    WinSet, Transparent, %opacity%
    Gui, 1:Add, Text, x0 y5, XP Range
    Gui, 1:Add, Text, x0 y+5, 1-15 | 3
    Gui, 1:Add, Text, x0 y+5, 16-31 | 4
    Gui, 1:Add, Text, x0 y+5, 32-47 | 5
    Gui, 1:Add, Text, x0 y+5, 48-63 | 6
    Gui, 1:Add, Text, x0 y+5, 64-79 | 7
    Gui, 1:Add, Text, x0 y+5, 80+ | 8
    Gui, 1:Show, x1580 y8 w60 h130, Gui 1
    gui_1_toggle := 1
return
 
 
DrawGUI2_1:
    Gui, 2:+E0x20 -Caption +LastFound +ToolWindow +AlwaysOnTop
    Gui, 2:font, s10
    WinSet, Transparent, %opacity%
	
	Loop
	{
		FileReadLine, ReadLine, gemlist.txt, %linenumber%
		{
			if ErrorLevel = 0
			{
				linenumber += 1
			} else
			{
				linenumber = 1
				break
			}
			if ReadLine = 
			{
				break
			}
			Gui, 2:Add, Text, x0 y+5, %ReadLine%
		}
		if ReadLine = 
			{
				break
			}
	}
    
    Gui, 2:Show, x1248 y8 w330 h180, Gui 2
    gui_2_toggle := 1
return

DrawGUI3_1:
    Gui, 3:+E0x20 -Caption +LastFound +ToolWindow +AlwaysOnTop
    Gui, 3:font, s10
    Gui, 3:Add, DropDownList, VDdlA GchangeAct x0 y82 w90 h200 , % GetDelimitedActListString(data.zones, "Act I")
    Gui, 3:Add, DropDownList, VDdlZ GchangeZone x92 y82 w120 h250 , % GetDelimitedZoneListString(data.zones, "Act I")
    
    Loop, 5 {
        filepath := "" A_ScriptDir "\Overlays\" data.DdlA "\" data.DdlZ "_Seed_" A_Index ".png" ""
        xPos := (A_Index - 1) * 110
        If (FileExist(filepath)) {
            Gui, 3:Add, Picture, VPic%A_Index% x%xPos% y0 w110 h80 , %filepath%
        }        
    }
    Gui, 3:Show, x696 y8 h106 w550 NoActivate, Gui 3
    gui_3_toggle := 1
return

GetDelimitedActListString(data, act) {
	dList := ""

	For key, zone in data {        
        dList .= "|" . zone.act
        
        If (zone.act = act) {
            dList .= "|"
        }        
	}
    
	Return RegExReplace(dList, "^\|")
}

GetDelimitedZoneListString(data, act) {
	dList := ""

	For key, zone in data {
        If (zone.act = act) {
            For k, val in zone.list {
                dList .= "|" . val 
                If (val = zone.default) {
                    dList .= "|"
                }
            }
        }        
	}

	Return RegExReplace(dList, "^\|")
}

GetDefaultZone(zones, act) {
    For key, zone in zones {
        If (zone.act = act) {
            Return zone.default
        }        
	}
}

changeAct:
    Gui, Submit, NoHide

    GuiControl,,DdlZ, % "|" GetDelimitedZoneListString(data.zones, DdlA)
    DdlZ := GetDefaultZone(data.zones, DdlA)

    Loop, 5 {
        filepath := "" A_ScriptDir "\Overlays\" DdlA "\" DdlZ "_Seed_" A_Index ".png" ""    
        GuiControl,,Pic%A_Index%, *w110 *h80 %filepath%
    }
return

changeZone:
    Gui, Submit, NoHide
    
    Loop, 5 {
        filepath := "" A_ScriptDir "\Overlays\" DdlA "\" DdlZ "_Seed_" A_Index ".png" ""
        GuiControl,,Pic%A_Index%, *w110 *h80 %filepath%
    }
return


GuiClose:
ExitApp
