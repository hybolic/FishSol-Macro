BAD_FILE_COUNTER := 0
BAD_FILE := false
file_contents := ""
CONFIG_ONLY_HOTKEYS := false
RETRYMODE := false

msgbox , 4 , , % "Are you only changing keybinds?"

IfMsgBox, Yes
	CONFIG_ONLY_HOTKEYS := true
IfMsgBox, No
	CONFIG_ONLY_HOTKEYS := false
	
RETRY_LOAD:

if BAD_FILE_COUNTER > 3
    ExitApp
FileSelectFile, SourceFile, 3, , % "Please Pick Sols Rng", % "fishSol-*.ahk"

if (SourceFile = "")
{
    MsgBox, % "Patch Cancelled`n         Bye!"
    ExitApp
}
	
if (not CONFIG_ONLY_HOTKEYS) and (SourceFile ~= "_PATCHED")
{
    BAD_FILE_COUNTER++
    MsgBox, % "Please dont re-patch a known patched file!"
    goto RETRY_LOAD
}

Loop, Read, %SourceFile%
{
    cur_line := A_LoopReadLine . "`r`n"
	if ((cur_line ~= "PATCHED FILE")) and (not CONFIG_ONLY_HOTKEYS)
	{
		BAD_FILE := true
	}
	file_contents .= cur_line
}

PATCH_CONTENTS:

;;;;;;;;;;;;IDENTIFIES FISHSOL VERSION NUMBER;;;;;;;;;;;;
RGX_VERSION:= "(?<=(?i)gui.{9}[\d]{3}..[\d]{3}..fishsol.v)(.*?(?=\n|\r))"
RegExMatch(file_contents,RGX_VERSION,VERSION)
VERSION := VERSION1
if not (VERSION ~= "1.9.3")
{
	MsgBox, 4, , % "Would you like to Update FishSol?`n`n    THIS WILL OPEN THE PATCHER FOLDER AND FISHSOL GITHUB PAGE!!"
	IfMsgBox, Yes
	{
		run, % "explorer.exe " . A_ScriptDir
		run, % "https://github.com/ivelchampion249/FishSol-Macro/releases/"
		ExitApp
	}
}	
if BAD_FILE
{
	BAD_FILE := false
	BAD_FILE_COUNTER++
	MsgBox, % "Please dont re-patch a patched file!`n`nUpon checking this file i can see its already been patched`nif this wasn't a mistake redownload fishsols v" VERSION " and run the patcher again!`nUnless you are changing keybinds!"
	if not RETRYMODE
	{
		MsgBox, 4, , % "Would you like to redownload FishSol?`NTHIS WILL OPEN THE PATCHER DIRECTORY AND FISHSOL GITHUB PAGE"
		IfMsgBox, Yes
		{
			run, % "explorer.exe " . A_ScriptDir
			run, % "https://github.com/ivelchampion249/FishSol-Macro/releases/"
		}
		IfMsgBox, No
			RETRYMODE := true
	}
	if RETRYMODE
		goto RETRY_LOAD
}

if not CONFIG_ONLY_HOTKEYS
{
	if not (VERSION ~= "1.9.3")
		msgbox % "You are using version " VERSION " snowman patch will be added!"
	else
		msgbox % "You are using version " VERSION " snowman patch will not be added!`nIt's already a part of the plugins!"

	REGEX_VARIBLES  := "(?:#SingleInstance Force\K)"
	VARIBLES_CODE   := "n`n`n;;;;;;;;;;;;;PATCHED FILE;;;;;;;;;;;;;;`n`n"
					 . "`nglobal G_EnableNudging := true"
					 . "`nglobal G_AlwaysOnNudging := true"
					 . "`nglobal G_WhenFailSafe := true"
					 . (((VERSION ~= "1.9.2") or (VERSION ~= "1.9.1")) ? "`nglobal SNOWGOLEM := true" : "`n;NO SNOW PATCH NEEDED")		; fixed in 1.9.3 so we auto disable it
		    		 . "`n`n`n;;;;;;;;;;;;;PATCHED FILE;;;;;;;;;;;;;;`n`n"

	;;;;SNOW MAN CODE
	PUSH_GOLEM_CODE := false
	if ((VERSION ~= "1.9.2") or (VERSION ~= "1.9.1"))
	{
		PUSH_GOLEM_CODE := true
		REGEX_GOLEM_PATCHES := "(MouseMove, [\d]{3}, [\d]{3}, 3([\s\n]+)sleep 220\n(.*)\g3Click, Left[\s\n]+sleep 220)[\s\n]+Click, WheelUp [\d][\d][\s\n]+sleep 500[\s\n]+Click, WheelDown [\d][\d][\s\n]+sleep 300\K"
		GOLEM_CODE := "`n;;;;;;;;;;;;;;;;;;;;;;;;;;;;NADIR GOLEM PATCHES;;;;;;;;;;;;;;;;;;;;;;;;;;;;" . "`n$2`n$2`n$2if SNOWGOLEM$2{"
					. "`n$2$3Send {s Down}" . "`n$2$3sleep 4000" . "`n$2$3Send {s Up}" . "`n$2$3sleep 300" . "`n$2$3Send {%keyW% Down}"
					. "`n$2$3sleep 800" . "`n$2$3Send {%keyW% Up}" . "`n$2$3sleep 300" . "`n$2$3Send {s Down}" . "`n$2$3sleep 100"
					. "`n$2$3Send {s Up}" . "`n$2$3sleep 800" . "`n$2$3Send {%keyA% Down}" . "`n$2$3sleep 5000" . "`n$2$3Send {%keyA% Up}"
					. "`n$2$3sleep 300" . "`n$2$3Send {s Down}" . "`n$2$3sleep 500" . "`n$2$3Send {s Up}" . "`n$2$3sleep 300" . "`n$2$3Send {%keyA% Down}"
					. "`n$2$3sleep 2000" . "`n$2$3Send {%keyA% Up}" . "`n$2$3sleep 300" . "`n$2$3Send {s Down}" . "`n$2$3sleep 1200" . "`n$2$3Send {s Up}"
					. "`n$2$3sleep 300" . "`n$2$3Send {Space Down}" . "`n$2$3sleep 25" . "`n$2$3Send {s Down}" . "`n$2$3sleep 600" . "`n$2$3Send {Space Up}"
					. "`n$2$3sleep 520" . "`n$2$3Send {s Up}" . "`n$2$3sleep 300" . "`n$2$3Send {e Down}" . "`n$2$3sleep 150" . "`n$2$3Send {e Up}"
					. "`n$2$3sleep 150" . "`n$2$3Send {e Down}" . "`n$2$3sleep 150" . "`n$2$3Send {e Up}" . "`n$2$3sleep 150" . "`n$2$3Send {e Down}"
					. "`n$2$3sleep 150" . "`n$2$3Send {e Up}" . "`n$2$3sleep 150" . "`n$2$3Send {e Down}" . "`n$2$3sleep 150" . "`n$2$3Send {e Up}"
					. "`n$2$3sleep 150" . "`n$2$3$1 " . "`n$2$3Send, {Esc}" . "`n$2$3Sleep, 650" . "`n$2$3Send, R" . "`n$2$3Sleep, 650" . "`n$2$3Send, {Enter}"
					. "`n$2$3sleep 2600" . "`n$2$3sleep 220" . "`n$2$3$2}$2" 
					. "`n;;;;;;;;;;;;;;;;;;;;;;;;;;;;END OF GOLEM PATCHES;;;;;;;;;;;;;;;;;;;;;;;;;;;"
	}
	
	;;;;ATTEMPT TO ADD FIX FOR LOOPING BIOMES -MIGHT NOT WORK
	REGEX_BIOME_FIX := "^((.{8})Loop)(?:\s|\s\d\s)({(?:(\n.{12})PixelSearch..Px..Py..[\d]{3,4}?..[\d]{3,4}?..[\d]{3,4}?..[\d]{3,4}?..0x[0-9A-Fa-f]{6}..\d.{10}\g4if.\(!ErrorLevel\))\C{300,330}?(?=\g2MouseMove..\d{3}..\d{3}..\d))"
	BIOME_CODE := "`n;;;;;;;;;;;;;;;;;;;;;;;;;;;;NADIR BIOME PATCHES;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
				. "`n$1 5 { `;IT IS THAT SIMPLE YOU JUST LIMIT THE LOOP COUNT$3"
				. "`n;;;;;;;;;;;;;;;;;;;;;;;;;;;;END OF BIOME PATCHES;;;;;;;;;;;;;;;;;;;;;;;;;;;`n"

	;;;;MOVES PLAYER OVER TO THE RIGHT WHILE FISHING IF YOU SET THE SETTING AT TOP OF FILE TO TRUE
	REGEX_NUDGE_CODE_LOCATION := "(?:Send, \{%keyA% Down\}[\s\n]+sleep \d{3,4}([\s\n]+)Send, \{%keyA% Up\}\n([\s]*)(?:\g2{2})sleep \d{2,3}[\s\n]+Send, \{%keyW% Down\}[\s\n]+sleep \d{3,4}[\s\n]+Send, \{%keyW% Up\}\K)"
	NUDGE_CODE := "`n;;;;;;;;;;;;;;;;;;;;;;;;;;;;NADIR NUDGE PATCHES;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
	. "$1if ((G_EnableNudging) and ((G_AlwaysOnNudging) or (WhenFailSafe = fishingFailsafeRan))) {" . "$1$2sleep 200"
	. "$1$2Send, {%keyA% Down}" . "$1$2sleep 1400" . "$1$2Send, {%keyA% Up}" . "$1$2sleep 75"
	. "$1$2Send, {%keyW% Down}" . "$1$2sleep 100" . "$1$2Send, {%keyW% Up}"	. "$1}"
	. "`n;;;;;;;;;;;;;;;;;;;;;;;;;;;;END OF NUDGE PATCHES;;;;;;;;;;;;;;;;;;;;;;;;;;;"



	THE_GUI:
	REGEX_GUI_tabList         := "(?<=tabList.{6}Credits.(\n))(?=(\n+?))"
	GUI_tabList_MODIFICATION  :=  ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;NADIR tabList PATCHES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
								. "$1tabList .= ""|PATCHES"""
								. "`n;;;;;;;;;;;;;;;;;;;;;;;;;;;;END OF tabList PATCHES;;;;;;;;;;;;;;;;;;;;;;;;;;;;"

	REGEX_PATCH_TAB := "(?=\nGui, Tab, Credits)"
	GUI_PATCHES_TAB := "`n;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;NADIR TAB PATCHES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
	 				. "`nGui, Tab, Patches" . "`nGui, Font, s20 cWhite Bold, Segoe UI" . "`nGui, Add, Text, x25 y85 w570 h45 Center BackgroundTrans c0x7F50FE, % ""NADIR PATCHES!!!"""
	 				. "`nGui, Font, s9 c0xCCCCCC Normal" . "`nGui, Font, s10 cWhite Bold, Segoe UI" . "`nGui, Add, Text, xm+10 y125 w180 BackgroundTrans, % ""NUDGING SETTINGS"""
	 				. "`nGui, Add, Checkbox, xm+10 y+m BackgroundTrans vEnableNudging   gUpdateCheckBoxPATCHES"
	 				. "`nGui, Add, Text, xp+20 w30 BackgroundTrans" . "`nGui, Add, Text, xp+15 w150 BackgroundTrans, % ""ENABLE NUDGER"""
	 				 . "`nGui, Add, Checkbox, xm+10 y+m BackgroundTrans vAlwaysOnNudging gUpdateCheckBoxPATCHES "
	 				. "`nGui, Add, Text, xp+20 w30 BackgroundTrans"
	 				. "`nGui, Add, Text, xp+15 vAlwaysOnNudging_TEXT  w150 BackgroundTrans, % ""[Only]"""
	 				 . "`nGui, Add, Text, xp+100 BackgroundTrans, % ""Nudge"""
	 				. "`nGui, Add, Checkbox, xm+10 y+m BackgroundTrans vWhenFailSafe gUpdateCheckBoxPATCHES"
	 				. "`nGui, Add, Text, xp+20 w30 BackgroundTrans"
	 				. "`nGui, Add, Text, xp+15 BackgroundTrans vWhenFailSafe_TEXT w160, % ""[After]"""
	 				 . "`nGui, Add, Text, xp+100 BackgroundTrans, % ""Failsafe"""
	 				. "`nGui, Add, Picture, x430 y500 w200 h192 BackgroundTrans, %A_ScriptDir%\gui\PATCHES_Vytal.png"
					. "`nGuiControl,, DisableNudging, %G_EnableNudging%" . "`nGuiControl,, AlwaysOnNudging, %G_AlwaysOnNudging%" . "`nGuiControl,, WhenFailSafe, %G_EnableNudging%"
					. "`nGosub, UpdateCheckBoxPATCHES"
	 				. "`n;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END OF TAB PATCHES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;"

	REGEX_INI         := "(?<=IniRead, tempAutoCrafterDetection, %iniFilePath%.{33}\n.{4}if .tempAutoCrafterDetection != .ERROR..\n.{4}{\n(.{8})autoCrafterDetection := .tempAutoCrafterDetection.{44}\n(.{4})\})(?=\n}\n\n; checks plugin folder\n)"
	INI_MODIFICATION  :=  "`n;;;;;;;;;;;;;;;;;;;;;;;;;;;;;NADIR INI PATCHES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
						. "`n$2IniRead, tempEnableNudging, %iniFilePath%, ""NadirPatches"", ""enableNudging"""
						. "`n$2if (tempEnableNudging != ""ERROR"")" . "`n$2{"
						. "`n$1G_EnableNudging := (tempEnableNudging = ""true"" || tempEnableNudging = ""1"")" . "`n$2}"
						. "`n$2IniRead, tempAlwaysOnNudging, %iniFilePath%, ""NadirPatches"", ""alwaysOnNudging"""
						. "`n$2if (tempAlwaysOnNudging != ""ERROR"")" . "`n$2{"
						. "`n$1G_AlwaysOnNudging := (tempAlwaysOnNudging = ""true"" || tempAlwaysOnNudging = ""1"")" . "`n$2}"
						. "`n$2IniRead, tempAutoCrafterDetection, %iniFilePath%, ""NadirPatches"", ""whenFailSafe"""
						. "`n$2if (tempWhenFailSafe != ""ERROR"")" . "`n$2{"
						. "`n$1G_WhenFailSafe := (tempWhenFailSafe = ""true"" || tempWhenFailSafe = ""1"")" . "`n$2}"
						. "`n;;;;;;;;;;;;;;;;;;;;;;;;;;;;END OF INI PATCHES;;;;;;;;;;;;;;;;;;;;;;;;;;;;"

	REGEX_END_OF_FILE :=  "(?=else.if..dev3_name.{4}[\w]{15}.{4}(\n(.{4}))Run..[:\w.\/@]+\n})\C*$\K"
	END_OF_FILE       :=  "`n;;;;;;;;;;;;;;;;;;;;;;;;;;;;NADIR EOF PATCHES;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
						. "`nUpdateCheckBoxPATCHES:" . "`nGui, Submit, NoHide" . "`nif EnableNudging" . "`n{" . "`n    GuiControl, enable, AlwaysOnNudging"
						. "`n    if AlwaysOnNudging" . "`n    {" . "`n        GuiControl, disable, WhenFailSafe"
						. "`n        Gui, Font, s10 cLime Bold, Segoe UI" . "`n        GuiControl, Font, AlwaysOnNudging_TEXT"
						. "`n        Gui, Font, s10 cGray Bold, Segoe UI" . "`n        GuiControl, Font, WhenFailSafe_TEXT"
						. "`n    }" . "`n    Else" . "`n    {" . "`n        GuiControl, enable, WhenFailSafe"
						. "`n        if WhenFailSafe" . "`n            Gui, Font, s10 cLime Bold, Segoe UI"
						. "`n        Else" . "`n            Gui, Font, s10 cYellow Bold, Segoe UI" . "`n        GuiControl, Font, WhenFailSafe_TEXT"
						. "`n        Gui, Font, s10 cLime Bold, Segoe UI" . "`n        GuiControl, Font, AlwaysOnNudging_TEXT"
						. "`n    }" . "`n}" . "`nelse" . "`n{" . "`n        Gui, Font, s10 cGray Bold, Segoe UI" . "`n        GuiControl, Font, AlwaysOnNudging_TEXT"
						. "`n        Gui, Font, s10 cGray Bold, Segoe UI" . "`n        GuiControl, Font, WhenFailSafe_TEXT"
						. "`n        GuiControl, disable, AlwaysOnNudging" . "`n        GuiControl, disable, WhenFailSafe" . "`n}"
						. "`nif G_EnableNudging != EnableNudging" . "`n    IniWrite, %EnableNudging%, %iniFilePath%, ""NadirPatches"", ""enableNudging"""
						. "`nif G_AlwaysOnNudging != AlwaysOnNudging" . "`n    IniWrite, %AlwaysOnNudging%, %iniFilePath%, ""NadirPatches"", ""alwaysOnNudging"""
						. "`nif G_WhenFailSafe != WhenFailSafe" . "`n    IniWrite, %WhenFailSafe%, %iniFilePath%, ""NadirPatches"", ""whenFailSafe""" . "`nG_EnableNudging   := EnableNudging"
						. "`nG_AlwaysOnNudging := AlwaysOnNudging" . "`nG_WhenFailSafe    := WhenFailSafe" . "`nGuiControl, , AlwaysOnNudging_TEXT, % ""["" (AlwaysOnNudging ? ""Always"" : ""Only"") ""]"""
						. "`nGuiControl, , WhenFailSafe_TEXT, % ""["" (AlwaysOnNudging ? ""AWLAYS OFF"" : (WhenFailSafe ? ""Before"" : ""After"")) ""]"""
						. "`nReturn"
						. "`n;;;;;;;;;;;;;;;;;;;;;;;;;;;END OF EOF PATCHES;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
}

KEYBINDS_PATCH:

gui, new, -ToolWindow -Border -Caption +AlwaysOnTop
gui, add, text,w300,% "Press the key you want for the macro to START`n[DEFAULT: ""F1""]"


REGEX_GUI_HOTKEYS := "(Gui, Add, Text, x[\d]* y[\d]* w[\d]* h[\d]* BackgroundTrans, Hotkeys: )(.*?)(=Start - )(.*)(=Pause - )(.*)(=Stop)"

RegExMatch(file_contents, REGEX_GUI_HOTKEYS, KEYS)

global KeyStart_WAITING := KEYS2
global KeyPause_WAITING := KEYS4
global KeyStop_WAITING  := KEYS6

RETRY_KEYBIND_START:
gui, show

KeyStart_WAITING := KeyWaitAny()
gui, hide
if checkKey(KeyStart_WAITING)
{
	msgbox % "You can't use that key: [" KeyStart_WAITING "]`nused by the macro or the game!"
	goto RETRY_KEYBIND_START
}
if  (KeyStart_WAITING ~= KeyStop_WAITING)
{
	msgbox % "Can't use the same key for Start[" KeyStart_WAITING "] and Stop[" KeyStop_WAITING "]"
	goto RETRY_KEYBIND_START
}
if  (KeyPause_WAITING ~= KeyStart_WAITING)
{
	msgbox % "Can't use the same key for Start[" KeyStart_WAITING "] and Pause[" KeyPause_WAITING "]"
	goto RETRY_KEYBIND_START
}

MsgBox, 4, , % "You Pressed: " KeyStart_WAITING "`nDo you want this to be your START Macro key"
IfMsgBox, No
    goto RETRY_KEYBIND_START
IfMsgBox, Timeout
    goto RETRY_KEYBIND_START

gui, new, -ToolWindow -Border -Caption +AlwaysOnTop
gui, add, text,w300,% "Press the key you want for the macro to PAUSE`n[DEFAULT: ""F2""]"

RETRY_KEYBIND_PAUSE:
gui, show

KeyPause_WAITING := KeyWaitAny()
gui, hide
if checkKey(KeyPause_WAITING)
{
	msgbox % "You can't use that key: [" KeyPause_WAITING "]`nused by the macro or the game!"
	goto RETRY_KEYBIND_PAUSE
}
if  (KeyPause_WAITING ~= KeyStop_WAITING)
{
	msgbox % "Can't use the same key for Pause[" KeyPause_WAITING "] and Stop[" KeyStop_WAITING "]"
	goto RETRY_KEYBIND_PAUSE
}
if  (KeyPause_WAITING ~= KeyStart_WAITING)
{
	msgbox % "Can't use the same key for Start[" KeyStart_WAITING "] and Pause[" KeyPause_WAITING "]"
	goto RETRY_KEYBIND_PAUSE
}

MsgBox, 4, , % "You Pressed: " KeyPause_WAITING "`nDo you want this to be your PAUSE Macro key"
IfMsgBox, No
    goto RETRY_KEYBIND_PAUSE
IfMsgBox, Timeout
    goto RETRY_KEYBIND_PAUSE

gui, new, -ToolWindow -Border -Caption +AlwaysOnTop
gui, add, text,w300,% "Press the key you want for the macro to STOP`n[DEFAULT: ""F3""]"

RETRY_KEYBIND_STOP:
gui, show

KeyStop_WAITING := KeyWaitAny()
gui, hide
if checkKey(KeyStop_WAITING)
{
	msgbox % "You can't use that key: [" KeyStop_WAITING "]`nused by the macro or the game!"
	goto RETRY_KEYBIND_STOP
}
if  (KeyPause_WAITING ~= KeyStop_WAITING)
{
	msgbox % "Can't use the same key for Pause[" KeyPause_WAITING "] and Stop[" KeyStop_WAITING "]"
	goto RETRY_KEYBIND_STOP
}
if  (KeyStart_WAITING ~= KeyStop_WAITING)
{
	msgbox % "Can't use the same key for Start[" KeyStart_WAITING "] and Stop[" KeyStop_WAITING "]"
	goto RETRY_KEYBIND_STOP
}

MsgBox, 4, , % "You Pressed: " KeyStop_WAITING "`nDo you want this to be your STOP Macro key"
IfMsgBox, No
    goto RETRY_KEYBIND_STOP
IfMsgBox, Timeout
    goto RETRY_KEYBIND_STOP

MsgBox, 4, , % "Start[" KeyStart_WAITING "]`nPause[" KeyPause_WAITING "]`nStop[" KeyStop_WAITING "]`nAre you sure you want these keys?"
IfMsgBox, No
    goto RETRY_KEYBIND_START
IfMsgBox, Timeout
    goto RETRY_KEYBIND_START


GUIHOTKEYS_CODE := "$1" . KeyStart_WAITING . "$3" . KeyPause_WAITING . "$5" . KeyStop_WAITING . "$7"
REGEX_START_HOTKEY := "\n\K[\w]*(?=::\nif.\(!res)"
REGEX_PAUSE_HOTKEY := "\n\K[\w]*(?=::)(?=::\nif \(toggle)"
REGEX_STOP_HOTKEY := "\n\K[\w]*(?=::\nif \(biome)"

file_contents1 := RegExReplace(file_contents , "[`r]", "", R_1)


if not CONFIG_ONLY_HOTKEYS
{
	file_contents1 := RegExReplace(file_contents1 , REGEX_VARIBLES , VARIBLES_CODE)
	if(PUSH_GOLEM_CODE)
	{
		;IF THE VERSION IS BELOW 1.9.3 WE APPLY THE GOLEM CODE
		file_contents1 := RegExReplace(file_contents1 , REGEX_GOLEM_PATCHES, GOLEM_CODE)
	}
	file_contents1 := RegExReplace(file_contents1 , REGEX_BIOME_FIX, BIOME_CODE)
	file_contents1 := RegExReplace(file_contents1 , REGEX_NUDGE_CODE_LOCATION, NUDGE_CODE)

	;save png for gui
	filepath := RegExReplace(SourceFile, "\\[-\w]*\.[\w\W]*") . "\gui"
	file := % filepath . "\PATCHES_Vytal.png"
	if not FileExist(file)
	{
		FileAppend, "", file
		ofl := SavePNG(file)
	}

	file_contents1 := RegExReplace(file_contents1 , REGEX_GUI_tabList, GUI_tabList_MODIFICATION) 
	file_contents1 := RegExReplace(file_contents1 , REGEX_PATCH_TAB, GUI_PATCHES_TAB) 
	file_contents1 := RegExReplace(file_contents1 , REGEX_INI, INI_MODIFICATION)
	file_contents1 := RegExReplace(file_contents1 , REGEX_END_OF_FILE, END_OF_FILE)
}
file_contents1 := RegExReplace(file_contents1 , REGEX_GUI_HOTKEYS, GUIHOTKEYS_CODE)
file_contents1 := RegExReplace(file_contents1 , REGEX_START_HOTKEY, KeyStart_WAITING)
file_contents1 := RegExReplace(file_contents1 , REGEX_PAUSE_HOTKEY, KeyPause_WAITING)
file_contents1 := RegExReplace(file_contents1 , REGEX_STOP_HOTKEY, KeyStop_WAITING)

file_contents1 := SubStr(file_contents1, 1, StrLen(file_contents1) - 1)

new_ahk := StrReplace(SourceFile, ".ahk", (CONFIG_ONLY_HOTKEYS ? ".ahk" : "_PATCHED.ahk"))

BAD_FILE_COUNTER := 0

RETRY_SAVE:

	if BAD_FILE_COUNTER > 3
		ExitApp

	FileSelectFile, outputFile, S26, % new_ahk, % "Save", % ("AHK (*.ahk)")
	
	if ErrorLevel = 1
	{
		MsgBox, % "Save Cancelled!!`nEnding Patcher!"
		ExitApp
	}

	if (outputFile = "") or InStr(outputFile, SourceFile) and (not CONFIG_ONLY_HOTKEYS)
	{
		MsgBox, % "Please don't save over the original file!`nIDK WHY YOU'D DO IT BUT YOUR A BAD PERSON!!"
		BAD_FILE_COUNTER++
		goto RETRY_SAVE
	}

	FileDelete, %outputFile%
	FileAppend, %file_contents1%, %outputFile%

	msgbox Done!!
exitapp

KeyWaitAny()
{
    ih := InputHook()
    ih.KeyOpt("{All}", "E")
    ih.Start()
    ih.Wait()
    return ih.EndKey
}

checkKey(Key)
{
	REGEX_KEYS_CHECK := "Escape|Button|Wheel|Space|Alt|Control|Shift|Win|Tab|Left|Right|Up|Down|Enter|Backspace|\b[wasdevcxqzfio\/0-9]\b" ; |" KeyStart "|" KeyPause "|" KeyStop
	if (Key ~= REGEX_KEYS_CHECK)
		return true
	return false
}

SavePNG(sFile) {
Static hBitmap := 0
VarSetCapacity(B64, 27764 << !!A_IsUnicode)
B64 := "iVBORw0KGgoAAAANSUhEUgAAAMgAAADACAYAAABBCyzzAAAaf3pUWHRSYXcgcHJvZmlsZSB0eXBlIGV4aWYAAHjarZtpchw5soT/4xRzBOzLcbCavRu848/nyCpKJMWZNtOILVaplkwgwsPDHUCb/f//d8y/+JOLjSamUnPL2fIntth850m1z59+fzsb7+/7Z77fc59fN/P1uvW8FHgMzz9rfn3+/br7"
B64 .= "uMDz0HmWfrtQfV3Jjc9vtPi6fv1yIf88BI1Iz9frQu11oeCfN9zrAv2Zls2tlt+nMPbzuN4zqc9fo1+xfh72t38XorcS9wne7+CC5bcP8RlA0N9kQucNz2/e0Afvcxvifb2+LkZA/hQn+9uozNesfDz7kpWT/pyUkJ9PGF74HMz88fjH11368vrrguaG+Lc7h/l65j+/vperX6fz/nvOquac/cyux0xI"
B64 .= "82tS7yneZ3xwEPJwv5b5KfxNPC/3p/FTDeidpHzZaQc/0zXnSctx0S3X3XH7Pk43GWL02xcevZ8+3NdqKL75GawhN1E/7vgSWlihkrdJegOv+o+xuHvfdm83meSyTBUwOC6mrHtzE/4/+PnxQucI8s7dYKYbK8blVRQMQ5nTbz5FQtx54yjdAL9/vv5RXgMZTDfMlQl2O55LjORe2BKOwk104IOJx6fW"
B64 .= "XFmvCxAi7p0YjAtkwGYXksvOFu+Lc8Sxkp/OhapqY5ACl5JfjNLHEDLJqV735jvF3c/65J+X4SwSkUIOhdS00MmViA38lFjBUE8hxZRSTiXV1FLPIceccs4li/x6CSWWVHIppZZWeg011lRzLbWa2mpvvgXIMbXcSquttd65aefKnW93PtD78COMONLIo4w62ugT+Mw408yzzGpmm335FRY8sfIqq662"
B64 .= "+nYbKO2408677Lrb7geonXDiSSefcuppp39kzZknrd9+/nnW3Dtr/mZKHywfWeOrpbwv4UQnSTkjYz46Ml6UAQDtlTNbXYzeKHXKmW2eqkieUSYlZzlljAzG7Xw67iN3vzL3KW8mxr/Km39nzih1/4vMGaXuh8x9z9sfsrbUbaYN5mZIZaig2kD58YFdu69dTe37I0OKY9l+Rso0v+rBvjuFYNfsYtll"
B64 .= "5b7bCm3FVvx0aRFbaDf728sDfazvWmI+tjKkHhOESpwc4+0tHzMm4/ZjQFQH2suhZ8LsU3JhblsW0wIce/rRL/VW1fjgkrY0X1afMZxWTjONQRe4cbbCMHoaCwJmlj1WhTr0nUftK3GX08kcka29tGFPLnGXE1zaw0VKpPfdU6pAD/5Cm3RXiT0fTJ3cj5ZOc3H71rYbejvlEbYdN1BkqIHIOEtDjZzR"
B64 .= "yyEA4J13SEicQtSKkjBu2ry7Pdszn1wc4Fl5hnBKS6sQsrzBbuzVKB1gNyohLaU4ILik6MK0gZtan+LKA3S5MkKfIS875vCOzJLCPo/dZYZlFkjNYr3dwwJ9B0LMDCOfbnmJ2uCd1f2p+cRJ2ikmcD7pULd31Zwq481mjGNPtb1RFS3XOnMhOPQy6k9f3q6OsedoC4FjQUQlKLv4sOY5R5gYqczozCEu"
B64 .= "M59MIe9WRl69MHRG7hx3cisc3/fJtZ+0Q/XUjZsth9ZWaqOU0U6gBkc3jvF3P3f2Y42S44nZzd7OJDl97JbGXoH/EgiaoZR83JxV4drFndhP0PTPpNOWmtzeIcLtQK8d7xr3mbad4/Q551qeUOZJYaVCz4Z9SDRAOyEzwkT1pmb23KKIDVVVcK/R71EZQIIEVhpKsIuJ/yQLf34090lSwlqa6QA9N3Jt"
B64 .= "PRZPhUegAzJVQ/3U0m1eY4S6FeZNPaYKj1AmqRhQMobPIfY921BNMkmXF8N1mQK4XynNIn5OX3Csbo8KcdKQvQfEcDwAyhBH0k+RwXAHTkoixeZtv5TBED7GD+4nRepgc2oFPhtwNliyGeqDs0NsHTjDmCuXSbG6zMhW8SD1+DZOd+K4XD3MSM2WwLDdqJsiDTaT6z2IMwzJoFfKsNw5YDaBi9Y3pQZG"
B64 .= "A+BscGNCh20GNlKAay2VCf1utfSyoA/fbDYFem4RhSgOBXWV2jkV9UU5tBjr1oS4Y9jMeNlCTFKBcShFrgfr23LmCMfsDpPnOn22IkhIfoDZXVKE6/OeL+GKZlSw0tr5W/ZpNCMZWGYxA6G67r3xJLNuH9N2LSpN1GCtAzyqAsLerS8b1kIRUnB9tAw8oMxlBt1ONiDzGp/3FOeCNpiPp1NCuEAV+HId"
B64 .= "vEMfaVZ31ulwIaD3EMeCUPyK5mkQ8WfUprXEN2dQonQiUaDLDz7HKXmfPShupta47dkHBNOG6Lp04dEeFG3ItPqfWhNJp3MIsJRnMjVwyaZ/VgjZE5QFMi+eqU1SskrQv2hk9Fk+SM/enVa8Z+m98PV7+2FAD4RwaLJ5JyJXw3MR3rMPcX28ySWYDziJKoJDo38y2ZH40fw5MmUuqgGE1LR1pRvdgrIA"
B64 .= "tHaIHNFGRxBh3OW4EAzVNV4YIXc3Nijrb497CwKHtA91/BsI2s6vRJhXJg4lWPUBZMbhhh5KhafnureAavP8Oa/Ad5twA4uag+tP4hI050V+Xyk5UhjpnRGGgfB5JkaHSTHOk+HNMCH/mz4vGrkJuiVDuo4urMt8ewuAnxkqJBTosHSQqfkb+rrG8+fYAOu9MpeI/uhKZyXKYnxLA0BiasIEFfRCHi3v"
B64 .= "hh5N+u0RybfVftFrBcahN9Kb3Y40fWtO6fJgixrkToF2P0E615sNKjrwKTdhCnSSKZ0DYW+i2KZDLCAr8qq9rjAMLA/A0B5Mt6EueFZlY5pcC22RpkssEAy0B8aBGCVJFWiCo7UTSYBadmumrwVrUsIbIm2RyowBZ3mTx68tOeeo/4KMyBljA+O5pxRH/UXoQnZCPQ9IZ0/oO3qfGpcaCwe0paQ6ghna"
B64 .= "tb24DZsPb6lppunQzZV8UD+l9WLqohoZ3EFskYommRcn7RVpG11vojVaFnE+PjNGWtk8kQERRKo0EEGMcJkGcxABQKHNN8n6sAWz2xaPLWCRnAa6SKVCxKRz0jZgM+isSWPGPonKDIa5I/gAWRy0nZXBqrfoRpo7bmKs5VD6SJY1pdBLYfIEArqPcMrihtApcsWajcuh1upAWYGl4ib5oVGgVSFVqK8l"
B64 .= "Tysf6AVJKJQ9willDEegSpaUHkzrj0EQ0QJRbASwoZRAk5uL1gQTZ9R+3eXBeasXsvS8LSOEwFHHbj5KjUdcNh3z4FGQWDjeQFhTYAiu13tdOqqc0YwV0BLTOcq61LdoCDQY9QIa5OkgmwpEQcKfY3tEE/BparYZKlCHZ1hLidiOqe/KNH1C1HYwDZ7WHqhaFLXptPMWaFpgB4XIYybr9B3apS/0zZkZ"
B64 .= "+6S5IhDFwQw7X40CjaCpQ0qwzjlYUfpkDXadNAYhChRbdKuvEwO3m5FxlD4i9aCiQ4TFHRgE3vHhVUSBnplXfZMaRFFIkw+CSkEBUqRYJnSAhSSAaxzu2KFuytUvJq0GCUdF4JwNaU3wN5wyiC+Eu5CZ/iBnShyV+3FRuR5KFt+T155XhK8dSWmR1fJwn68m3bVHmagkCzbHodgDzXR54L78vjIPgmB6"
B64 .= "WnUCqKiM17QQMSsnynt5FBtlFvkLnnAoCCL8Fymm98YGke6KwCCwcE4Fq4Jxt2R9OnVMt+TkZirDrGMns6L4RsYLAt4lNokY6zk6tIWZxqWV6DxTd9LfWNqEHWG8MBeaw3cCaRo6owhHAKq76LBuGGgMhFo31dDxDBn9diL0sY7DRNewcF+5H5KQgmuq+GRmlD7EwHlK8GzbKG38XvLqD0ju0TYxSZn4"
B64 .= "OcgwdIdMp5+kuqiGeHzBHcwYGVEgqxm+qngKCpvAI5VmFdmoZClG/BEGKCJlQkK2WGh+eK1USDgB8IYNMowbTQWJbrl0J2WLYRc1dxwNrJ+ciKg5aW6Q4gBSxYKcJBvoEEg04zyLgVkZAFGGBGWHoCXskict0Nyoiu7UfHJfu0OpTeoSLYLpmthUEkKXWNh1zE2EvRgsflJaeqLeEJN4cFqnCAQL5ki4"
B64 .= "w8Qn+F2GDFvFnFESgVlwHbSmqR5aPBWJjhzcYtmrgXwLOA11hqs3AinaeBJAnxv1DReMiafF2GFQfKzLuIxOo6VXmLlR8ji+eWqltjrAQ2VHYZ4xSwY3LYieDPufKSWAYWEgW6t45lykFCy9g3MoOqgauboZX6BcYZaGNOObOAmA0xHo0A/ukx5DHy6D+yaUsWEIc3bG2hHWmDWMUCzlumTkzYDHMNII"
B64 .= "BjkmNFND5IQ5g294j3ilKJzKxykRaHThMuig9FocwsDNO5IG027EBlJ6oLAp501na+ihuuhfSWLUShqrqZ9oYCK+AcDS5CM1wYHnCVciNUemmMKgv+OtqtxJyUHojdkymS1cE3O8CGadelhpq8w6ImHB0fME8DeRhhtWXbQ4PCZyFv4fMYB+QX6gjrH9ZcLC65gUEn4Y2kcpujIGCESrTs/lsHE1yiwh"
B64 .= "KnYC+niuoPVsrH9A+QS1vV2P1imyOTlZLVSQkZnrWFL2bQMYVATJpFSS+CenIKlCK5PA4T/aBdVh6eEKTdaSBqKYBpyySk5dErgBb9r0lNyYjRmjv3KMRA3HT7q3lXRHUS3q3gHsuekiEQ70MQaqlw6cIEcVAjeGEige2QoEloVW8G2EGfRY0RvKBmFDC4PgYCsDkVuJh4YOKVc+2eP4ZNh6u/gr6CGj"
B64 .= "dWU6NYtgOL1elxSBXh8oASSegc+j22QtJC1D9ryv06ato84S9iO3HmnhU/GyFAGgbNb5KJzAzL13lN5tkN5OpMjRGtiZBHPRvZHoEXMIYZasJS2MQWyK+iN96U/zi+0y1kP8m5rVGh0RxTXOEr1WW0HG2ZAapZGpeRhiaqHS4VVbkKhCzenaEXw547QqSpipdAxoyVyduAerZdmO5KpMUhK7BcCBR0Gv"
B64 .= "DBkBBJQcK05gg/RUDSEjdHMe6x/ZdKls9h/NAFSAYkGco8foSVqqOGCMC0Ew3AgbHjpUBj5ChvEl+NCfIJvUgSvyXOHVSoEETASl7x+7pd4DwRsCDjFeOsCDwTG2qqLR4bzITO87dM9dgiPTB8BTcb2c1hAcVHVCA7SYDD28SEH/6ECgRgjbNcoqyCtu6gGO1MIYRYbXB/30YEO/5uOT9taux2AaWsV7"
B64 .= "+R80xZaYPfRKK5F5stWKkD18m46uT6GW+JRBxpMLGiPdN87HBIL869DIPj0WE7qwnWdaitjzTW6tJVDY7LU4RH+RX/vs5ttTCg4BH8XvZyH5evIFSRIaKFJsYdILYTkMqhFV2gwqalyn+ANAjnictnKI60mvISweviP79cKGMbMg56lWzCIufFdyTDii/LOVq+CacB/v4EmkmZ7UK/Pmn6UeaSFUO1Hd"
B64 .= "18Qr77mZ/5D4JOkw34sG7cY/H/UF5JF6kXvZXepa1Y8aGYSzYGV4Hc1IMOFNRHDf7a6afOMHfFeg8aOSRr4LH3OY33Ic/muO/5TiV4KNOjicOW9Ppi9py6D/nEnuEDNlCdVlHCJFTOuCxYu5Ez6oU4ZBN6YZlXmgw18COP60lkH1wqtE0GWs6MPEGJ5IV7folJsrhJ/yi3FmaDnf1eSpdUMcJFRFA5IG"
B64 .= "O1ruIDTODZA9aAIrNkpDS4cBosW6Yy/DUNTpGEABTBd6oh1h4fku2SIL1+9cZT6TF1hBdHEvBNTwz0IUlnj5V4BwYvhshHZQoFBYJJgxHIKNthXpaf1lDKb7VDbCTLJn1OFpAQkdjbNsQGiRDvR6PqVahD96XAWELzHYj7IwS7JXKBRXQ8k4ClTT9SASLyvitrFFI0PKMQAF2SeGiKeZWNHWAKDBGcFZ"
B64 .= "3KjnjoFDg46OCL8DuAt/NNg24GNX8cV3PQJAaKdM11e7Hxl12c1TzdxHMKsZh9+ZHrhnXlrybNh8Wm9UVMKgraMA45oSvUfGVTs4x+aBp4UdYMKidc+K0tJyHkS0lkxKPjmOEwYIXy3KOmUtWmSlmjocUTHlUi6bJo3KREgLfiRSsfZIxHPHDVy4OznySeJYV1tVSxRaga9IwqHaRA74W7RamgtAkug3"
B64 .= "3phxU4tcW6sY4vpTJn6NaIA3TGF2qCOuPUPhX6daybbtTC3AXCvPh2HFhLu2KPxIMrQ8tD0iYUf6N5/jYrTpwqVR7uhkPxWuBh5w82YubbTgeLQO70LdmjMKAB1Frte9fyLLU0tMFsZDt0Zew+RKPWvra3i3sFk6m1BpbJf04SatPIVQtIDD0LBH4m03hS2S70cIY2rjh9B1yX6PZnTem9G5E3ID4dqC"
B64 .= "xIa9tDNIB00eHO+GFqZRNwBAM6TLqjb7wFm8V6YglGxm0IkBWrvOhmwtj8M8M+uB0sFeyOFrbY6ODwNqGwiahxm0jZG0oooKIeDIGqRlcFoFg/SfnTRyTeOaq8PZWgc4DQbxen+HePNXZWTDRMdtzCbG5RiIYvWozUot1NG+oEnEo5ueKbSg5RXpUkR2w2jEjOKvzYMXbeBhrXK4yzwWK4rOwY1YVAz0"
B64 .= "gzmPaCw0k6Ru0hIgYtPRxukiNCj8UNOO9qQDJ6SzdjoG/HGMC3NIBsANTsU9iKyEF8YHFibnOBa/Noy5vCBCEmubOcofVWx+anJPZM2OimiA75D/NNdyt2EoxQFDYi1xemU0AuPdgQS4gHYH1BgoO14HeZA86hnyD9hDnhKrlWRctJQT7/ajF4t1RnuXPZZ8JOrHQx2ovGddK0O6CHwuxBiHjih00gm1"
B64 .= "NC2ggGRipmXZdB151lZs0i4XyBPDaAvWKRdSzAgiWhVexK8SN/KrUck5ImqTdPYWz4LIMiPTXIhj+UIxVt4UekEASCFLxgKvnQxVA5VTPBiUo8rFkdVrWcL0Yn26HC3RxQ1lW22FIn21EapGI+/jIGGMk4HYtXQHcLE4WCMghBQAsmSziv8YZpZt1pIT+JDd1Bamf1bNJNLbApVmjyoP/l4X513bC0Ye"
B64 .= "FtU2lSeZo4YKZTqUAzFcuF5CrWIFKnggPrtPxdMSExQZqhcfvHRSQAINqweZkeI+kpbtAuWulV84QxshlkvxtY2PjVNLxBQtxcSMD1zLhVE/sD0lrD0KxBl9bdDmE/xN8e/T1mkbWog0HktGqlh9VHo+5N98kfmkI3eSQ1lWLex6egik33EAOEscX+w6fzW0OXPQ1CSl459AQsF6rmTumbJpXX00RoGt"
B64 .= "04eGQ0xrWeG9nJIlpkiMdgui9M4abRetfONpheNFkB3wTpGkUOE7l+TvsHBpUMV0d1OTJgxFYTiEKQBydV5OHdLY20zAF88iM/dwE90LtJzGNZmJ06KfTziDrgW/5lbGUQfos9O0tcSG74fukS+4Iyiy6BhE99pEABRc7WjZv1Nw7Y7Y6dDC0mGIENUCl3bwNj5Sx6vobrVVI5sBL0bZqyTkHq3HalER"
B64 .= "fx7HBOxtCAgNEYYGWFiXgW2UwA5e8C5UOw5SixsU6jvi8Frxpzet3I3skTNbVJpQnH3OpeUUkEoeKQ/nbu8l4p7eH/fjCRiQFj+PDrEgCp8ccgOV9hyWgkQGTSrQ0hCIWJHvpOJ0RENrxiYhvUo79zBIaST6UAcz4st1hoBOr2MGWs3XIuvdV47rgHCi0fqzlhQKHzLadWBEDM6fBFzzLLTZiSIJi2jf"
B64 .= "vV+LzcU+AinSgNcOgSmvIYwhNGgFQracOoUm0vToUZoWOpCQaC390LYksAn/Y2sIHLIoVrVtuA+GwrHTMVC4hproGJmkAzYO8VacfPyG52YWXdxTRiActbxgmaEjM/g1eOHDE1Su+d34fWzn0ilRPAvjyXgmEvDub6vIhM3F7LVNh1yDJetGjbhn0E4nHO/GZQ9Xd/xomYAQuuJopwmfppUkBCLK3+nE"
B64 .= "4l3B29y2wtFayHAKvZxZq6IdWFsrOOnZlURvnDOawgc44EreMOf1Ojr79U6nt+FLnt3K8bGLO+z8aVtbi3m0I3k3d7uUFq47rN6fFujsvcHaXQeZmrQIDUrr6OMJ8+/XNH8b5HeMzd8G+R1j87dBfsfY/G2Q3zE2fxvkb8H+FuQEeSya9dDBXKo+aR8qaWMKvUoRBztD1hnE3FF/y+icmUxUvc54LypY"
B64 .= "CzgLN0t5ZkyXKow2KeW9Eb5kjuqkGvmCNg+3trdCMqW+xjvSl/UOjIlrYT3nBq7GfBY2mntsIo1FaywLVoRBTXg6pFWHRPlS1PzofN2YU0ptaYuKppiwTiG4ibSr2i3z2vrXGROPxKGzGe3Gwj3xHpz6lNBf+RxzqcvCH9wcu7fkHOkJeY9pfeiwrqwozAnn9KX9MknfBfkuHYBxTq1l2kzDWzpkBGF1"
B64 .= "HKkO86JKy+O3RUu2P1n7fY2w+7af41WVKCPgatX2gzZbprZxCgx+N3GSzjYGeRedPMKLNMi4jnsiSuO425SOBuBmvsB6YHVBhTsoemOMNoejvWNF0rEN2b0Mvny+YNXsz8c9nkenXbaIw60+6HBjAWpFJyWmN5HC8gFxjvrUQcDdhLM9suvIe3oW/9CpTVm+ipYh7fcsA05n6XgigQiBMkZoddoejVre"
B64 .= "wQZN8J6GRCCeu7SNbnFYWcRSPjpBElTxdMS+cs0ekd4wlU27EFY7LVv/7wEmoQeypWpSfy0RyCDwERvoU+JqRSM17YiG6RV4wUxBLJWm0eHbmqe/ZsVrZT7BYeQa3d/IDSWyBkBihB0TI/gie+TdSaTW3yT+/Z4GJYQiqAepr50N5AVWWvbJ4yMKnpKupgOqpYEHlHlwB2uFET70dsANrLSf0o0OGaPH"
B64 .= "brVNFBtuJaMYpENDi5HAEMu8pRiR/cjkxjvoLHT5NcdeXkXmeOalg35W3irrHJ8XHDuyJlW0WnNuNAk2r/sgBRkjk5Eobbh4fHLRKdMM1brODBAiwM2JdJc2q7tWKUvQvrzW+nSW7i47emQ4EI8OwVfxufwHcxXomQZptQLgIW0iiLKjTdQVD6Hc6AMwDwaLltpaqguAFRUH5YWh0PHUphshdzDHuC3K"
B64 .= "SYdwW97adj2YwyujhlwMCOOWnYqNKcMMlhbhSQx0kapyD6eQeTQkunSPrVVXHbyAkDSxCSf04ZvMpLYXICC7dUbZpfgkxpLhBDoVtNWaeS0T/ufjl//g0fztBb5fCFutBTzzb84JImKEDXWUAAABhGlDQ1BJQ0MgcHJvZmlsZQAAeJx9kT1Iw0AcxV9TpaIVBzsUcchQnVoQFXGUKhbBQmkrtOpgcukX"
B64 .= "NGlIUlwcBdeCgx+LVQcXZ10dXAVB8APEXXBSdJES/5cUWsR4cNyPd/ced+8AoVllqtkzAaiaZaQTcTGXXxUDrwgijAH4EZWYqSczi1l4jq97+Ph6F+NZ3uf+HINKwWSATySeY7phEW8Qz2xaOud94hArSwrxOXHUoAsSP3JddvmNc8lhgWeGjGx6njhELJa6WO5iVjZU4mniiKJqlC/kXFY4b3FWq3XW"
B64 .= "vid/YbCgrWS4TnMUCSwhiRREyKijgiosxGjVSDGRpv24h3/E8afIJZOrAkaOBdSgQnL84H/wu1uzODXpJgXjQO+LbX+MAYFdoNWw7e9j226dAP5n4Err+GtNYPaT9EZHixwBQ9vAxXVHk/eAyx0g/KRLhuRIfppCsQi8n9E35YHhW6B/ze2tvY/TByBLXS3fAAeHwHiJstc93t3X3du/Z9r9/QCB23Kt"
B64 .= "t+ddvgAADRhpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+Cjx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDQuNC4wLUV4aXYyIj4KIDxyZGY6UkRGIHht"
B64 .= "bG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIgogICAgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9i"
B64 .= "ZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIKICAgIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIKICAgIHhtbG5zOkdJTVA9Imh0dHA6Ly93d3cuZ2ltcC5vcmcveG1wLyIKICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8x"
B64 .= "LjAvIgogICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIgogICB4bXBNTTpEb2N1bWVudElEPSJnaW1wOmRvY2lkOmdpbXA6ZGZkOWNlNDctMTBmYy00MWNhLWJhNTEtOTU5YmU1NjAyMjY0IgogICB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjJjOWMxYzU0LThjYmUt"
B64 .= "NDg3OS1hOWJjLTcyN2RlMjYwMzQ3MyIKICAgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjI1OTkyOThiLTdhZmQtNDMyYy05OTRjLTI1NmIyMzEwOGVhYSIKICAgZGM6Rm9ybWF0PSJpbWFnZS9wbmciCiAgIEdJTVA6QVBJPSIyLjAiCiAgIEdJTVA6UGxhdGZvcm09IldpbmRvd3Mi"
B64 .= "CiAgIEdJTVA6VGltZVN0YW1wPSIxNzY2NTc0MjU5ODEwMjM0IgogICBHSU1QOlZlcnNpb249IjIuMTAuMjQiCiAgIHRpZmY6T3JpZW50YXRpb249IjEiCiAgIHhtcDpDcmVhdG9yVG9vbD0iR0lNUCAyLjEwIj4KICAgPHhtcE1NOkhpc3Rvcnk+CiAgICA8cmRmOlNlcT4KICAgICA8cmRmOmxpCiAg"
B64 .= "ICAgIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiCiAgICAgIHN0RXZ0OmNoYW5nZWQ9Ii8iCiAgICAgIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6MTFlN2JhNGYtMDE1OC00YWQ1LTgyZWUtMjNlZWJlNTc5ZjZmIgogICAgICBzdEV2dDpzb2Z0d2FyZUFnZW50PSJHaW1wIDIuMTAgKFdpbmRvd3MpIgog"
B64 .= "ICAgICBzdEV2dDp3aGVuPSIyMDI1LTEyLTI0VDIyOjA0OjE5Ii8+CiAgICA8L3JkZjpTZXE+CiAgIDwveG1wTU06SGlzdG9yeT4KICA8L3JkZjpEZXNjcmlwdGlvbj4KIDwvcmRmOlJERj4KPC94OnhtcG1ldGE+CiAg"
loop 32
compressed .= "ICAg"
B64 .= compressed
compressed2 .= compressed . "ICAg"
loop 6
B64 .= "ICAK" compressed2 "IAog" compressed2 "CiAg" compressed
B64 .= "ICAK" compressed2 "IAogICAgICAgICAgICAgICAgICAgICAgICAgICAKPD94cGFja2V0IGVuZD0i"
B64 .= "dyI/PvEiOgQAAAAGYktHRAD/AP8A/6C9p5MAAAAJcEhZcwAACxMAAAsTAQCanBgAAAAHdElNRQfpDBgLBBNBRRmgAAAgAElEQVR42u2deVyU1f7H3zOsiuAGqLiBKIIiiiu4i/teaVk3s9I2M8s9930rcy1Ts+y237qVqbmDO5ori6ICgiAKCijIvs78/njOMwym92eKMsB5v163bl+Zmef5cD7nfM/3"
B64 .= "fMcHKiZVgU+APEBv9L90YBZgXYG0sANWALn3aJEBzKlgWlR4tMAbQKI6EFrWfUs/0ne/von9c8aDIxoYVs610ACjgVvqfXv5jtG/MtFf79ZquLEWV4HnK+qA0VSge+0MrAO8AWpX6UiflktwduiMVmNOoS6PyIS97AmZQWpumPqag8AEILScadER+BRoDVC7YUf6DFuMs1sXtGbmFBbkERm2nz2/fEhq"
B64 .= "okGLw8AHQIg0SPmiPvAx8KJywxYM9d5Cs3rPYGle5W8/nJ2XQnDMD+wNG6+GdMAmkW7cLuNa1AM+Av4FoNFoGfLq1zRv8xyW1vfRIjOFkJM/seenccZabAZmA8nSIGWbysBUYJr4/3RynUOHJm9jV6nu//viOxlRHA//lDPX1qqhVGAe8DlQUMa0qARMAaYbtOg/mw493sGu+kNokRTN8f3rOHOwmBbz"
B64 .= "hRb50iBljxfExrMBgLvjCLo1m06d6q3+0Zvo9Tribp9kf+gc4u4GqOFLIu3aV0a0GC4KEg0B3FoNp/ugmTg19P7nWkSfImDrfGLD96rhy8BEYI80SNmgldhndAGobuVJv1Yf0bh2L8y0lo/8pvmF2YTf2Mn2oHHk6RLV8A5gMhBpolq0BNYC3QCqOTSj/4sraNysF2bmj6FFfjbhwTvZ/t048rINWvwp"
B64 .= "tIiQBjFN7IGlwBiUShX9PTfg1fBFKllWK7EPychJ5Gz0VxwMn6mG8sQgXAykmYgWNYElKNU6M4B+L66npc9LVLKpXmIfkpmeyNmj33Bg6zRjLT4FFpqQFhXeIBbAe2JvUBWgXcOJ+Lq9R40qjZ7Yhybevcixy6sIjf9KDd0CZgD/RimNlgbmwDixN6gG0LbHBDr2Hk8NhyeoRfwlju1ZSegJgxaJwEzg"
B64 .= "a7GplwYpJfoBqwF3AOfq/fDznEd9+w5onsJt6fQFXE08wr6QWdzK/EsNnwXeB44/ZS36Ci08ABq698Vv6FwauPqg0WifvBa6AmIijrH/t9kkxASq4SBgPBAoDfJ0cQNWAQMBrM2cGOS9lqZOA7Ewq/TULya3IJ2LcVvZFvy6OmHqgf+gVM+uP+GPbwKsBAYDWFrbM3jU57i3GoSFRSlokZPOxbNb2fbv"
B64 .= "14wXUlWLOGmQJ4sdMFfMSpYAfk2X08Z1NDZWDqV+cXezrnPqykYCo5YY0nSUM4dPgOwS/jhblHOZD1QtejyznDZdXqeKnWOpa5GWEs+pQ5s4tmuhGspCOYv6+AloUeENorZELAUcAbyc3qCzxyQc7TxM7mLjU4I4HLaM8KT/qqFYlPOY/5aQFq8LLWoBtPB5nS79p+Do1Mz0tIgN4vDO5YQH/aKGronV"
B64 .= "5GdpkJKhk6gStQGlPaS31yJcHLui1Zib7EUX6vKIvLmfvcEfklLUtnJE7E8etVXDF6WE3RaU9pDezy3EpWk3tGYmrEVhPlfC9rP3vzO4c9PQsXNUaBEsDfJoFGuJ0GqsGNzyC5rVfw6r+7SHmCrZeSmExP6HPRfeNexngS9ROoYftlWjLrAcGAmg0ZozaOQXeLYbjpW1bdnRIiuF0L/+w+6fimmxBaXi"
B64 .= "lSQN8nD8rSWio+tMfJq8+1DtIabKnYxoTkR8yunYNWooFeW84DMe3KphbaSFDUDHfjPp4DeWqtXrlVktUpJjOL5/HacPrDZs"
B64 .= "34BFYnXMlwZ5MM+jtIcoLREOw+nefCZO1VtRHs4zlbaVUwScn09sarFWjUnA7nt+fLjQwhmgsdez+A2ejZOzd7nR4nr0KQK2LSTmkuHWw1FO43dKgxTHA9iAaImoaulBf+8VNKnd+7HaQ0yV/MJswuN38mfQRHIKDVXgnSiHfNbARqA7QFV7d/q/uIImzfs8VnuIqVKQn8PlkJ3s/HEC2ekGLXahHP5e"
B64 .= "lQZRWIBSvqWf53paNnyJSpbVKe9k5iZxNmoLB8Knq6G3Uap0iwD6jlhHK9+XqWRTo/xrkZ7EuWPfEPD7VDX0gUi5Sh0zE7iGHkC3Lo3n0dVjaqkc9pUGluY2NHToTE5uDtdTA0Fp+LMB/Dr1n023gdOxsKwgWljZ0LBJR7Kzs7gRfRyU7uCTpnBtWlMR6Wm0RJgiZloLqYU6GLVmpndNSCQSaRCJRBpE"
B64 .= "IpEGkUikQSQSaRCJRBpEIpEGkUikQSQSaRCJRCINIpFIg0gk0iASiTSIRCINIpFIg0gk0iASiTSIRCINIpFIg0gkEmkQiUQaRCKRBpFIpEEkEmkQiUQaRCKRBpFIpEEkEmkQiUQiDSKRSINIJNIgEok0iERSkQ2Snn2TgsKcCiV+XkEmadkJf9fi7k3y87Mrlha5maTfTTC56zKFZ151BXrcTDvDtcRz"
B64 .= "1Kziil3lumjKweOOH4ROX0BM0lF+PzmGqNt/qOHtKM+J73kr7ixx0eeo4eiKXXUnNJpyrIWukNjIQH7bMoaoC9vV8E7gdEU3iAb4F3AG5XnhPqk5V6yCrn1Fdk4G9nZNyuXTbpPTwtl/fi57w8aTnncNIBnlWelZQBAQBvikJl+xDjr2FVkZadjXbkolm3Koxc1w/H+fy57/jCM9JRbgNjAFSEV5JHZ8"
B64 .= "aV9jaU1NbYFPAR9AB3wNrAEmAK+rqd+AFhvxajgCa4tqZX4wZOYmcy763wRcNjzquAD4DNiB8ujnjoAe+DewCngfGKNq0f9fG/DqMIJKlcu+UbIybnMu8Fv8f51krMXnwDZgIdBJaPENMAO4WVEMUgtYDrx6n89OEwPlqBggHQFqWHvRr9VHuNbyw0xrWeYGQ0FhDuEJu9kZNJGsglg1vEfoMAp47T57"
B64 .= "wTRgCXAIWAl0Bqjm0IwBL36Ca7OemJmXQS3ycwgP3c2unyaReTdGDe8DlgIjgdH30SJd/PlqILe8GsRSrA6zAVuADkzFh7FkksQBFhHNn+rPRohl1gb4GKgP4O44gm7NZ1CnWssyMRj0eh3X75wm4PwCYlJ2G9/bDKARMAewA2jvPAnfJu+RlXebAxcWEXXbkItfASaLvckKVYum3iPoPmg6dRq0KiNa"
B64 .= "6LkRc4aAPxZw9eJO43ubDjQE5gJVAdr7TcKn1ziyM+5wcMdirpzfpv58lBgXf5Q3gwwWs2ATABcG4scc6tHesBEvIJcIdrOLKWQQZTzLzgaGAFPFIKFL43m0a/wWdpWcTHZApGTGcCLiM07FrLx3dYwSK4cbgEuNgfh5zqFeTSMtdLlExO9md/A00vMjjWfZWcBA4ENVi84D5tC+xzvYVTNdLVKTYznu"
B64 .= "/ymnAlYarwiLgEihRVMAZ/d++D0zj/qNOhiKEoUFeUSc38Pun6eRdjtcfb2/mGzDyrpBPMS+og+ADc4MYBVN6Y851vfPTUnmHN/iz2Tj3HS92KPMBF4A0GoqMaTVZprVewZLcxuTGQw5+amExP6H3effFSk0emAL8K1YOfoBWJs5Mch7He5OAzE3e4AWebcJuvo9+y9OuDdP3yLeawSA1syawaO+oHnr"
B64 .= "Z7G0rmI6WmTd5fypX9j54zug16lafC32FR8CAwCsbJwYPHId7i0HYG5R6YF7luATP7Dvlw/UUCGwAZgH3ClrBqkGLADeBcwBevIJbXiVytg/XHWDSAJZTRAbikJKShIuctGWAHVsO9PHazENHTqh1ZiX2mAo1OUTddOffaGzSM4OUsOB4pqHAOMAC4CeHp/Q2uVVbKweTovb6ZEEhq/lXNx6Q0i87yWh"
B64 .= "RSuAOs6d6DNsCQ3dOqHVlqIWhflEXQxg368zSY43aHFcXPNA4D2RcuP37Ee06fI6NrYOD6dFYhTH963h7OHP1NAdkZ5tFKYxaYNogbfE8mkP0Ip36MwE7JVV9B+ho5BrHGc/c7jBYTUcCkwU6dpiw+fUe5vO7pOwt3V76gMiISWYQxeXE574sxqKEzO8jbhGB4CWdd+ks/skHOzcHyGHL+Ra8l/sC53N"
B64 .= "jbRDavi80MK12Od0fJPO/SbhUMf96WsRF8KRnR9z6eyPaui6WPmtxTU6qtfYqe9EHJ08/rkWukKuRf2F/9a5xEUeUMMXRNoVYKoG6S7SqZYATnSlNwtpSGe0j3nUkk8WF9nGdt6hkDQ1/Kuo8rwqZiRlpfJYQWuX1x56dn4c0rLjOXXlC45dWVCUIcInYrZcrs7sTrZd6O21kIYOXdBqHlOLgiwu3djO"
B64 .= "9uCxFOhS1fDvYvC9Aow3aPHcClp3fg0b2yevRXpqAqcObeLoToMW2WLfeRRYBrRWV7lezy3EpWnXx17l8vOyuRS8ne3fjKUgL0UNbxX71ShTMYizqDQ9rywhNgxhE814BktKdm+QTgKn+ZIjzDWkuWJAbherVl8AG/NGDPD+hKZ1+j8wv38c8goyCIvbyvbg19EXreq/oJzrvGfYG2gqMbjlRprXfw5L"
B64 .= "85LdG2Tk3OJ01GYOR8wx1mKVGCALgf4AlezqM/Cl1bi3HIi5xRPQIjeDi+e2sf2bMegKc40nr3XAWOAlAK3WksGjNtO8zXMlvk/KuHuLM0e3cGjbTDWUK1LPpaIgUCoGsREbrSmGigrz6MBb2PJkKyq3OM9hPuYi36uhG+Ja0oVhlGpZjQH4ec6jXs12JdK2otMXEJN4DP/z84hPP6KGg0Wp0heYZtCi"
B64 .= "8RzaN37niVfabt29wNFLn3Ah4Rs1FC+uJ0XM4Eq1rNkA/IbOpZ5LOzSax2+/0+kKiY04xv6tc4mPNmgRIj67vfh9VAbo1G8WHfzGYle97pPV4kYYR3ev4MJJgxYJItX9Vq2YPC2D/Av4CKgH4M4IujOT2ng9vY0g+URziL1MJ5lzavgvYdhOoiRqB9DBeSq+buOoZtPwkT8vKe0yxy6vIuTGZkNIfEam"
B64 .= "SCEaADR1fIHuzWZQp3pLntYRk06XT3TiYfYETyc5+6waPolyfuKL8XlLz0n49hpPdXvnR9ci4TKB+9YQfGyTcQFlNkopexnKuQZurYbTY/As6jR4iloU5nM1/Ah7f51FYtxJNXxapJ4nn7RB2oilUznhpiX9WI4rfphROqe6OaRxgf/yJ28Y9nCijLgG+ADllFoDMKDFJtG2UvWh3z8zN0m0h0wr2hIp"
B64 .= "7SHbRSrTBaC6lSf9Wn1M49o9S+20Pzc/jQtxv7EjZLSxFt+J1Gs8yim1osXLG/FqPwLryg/fwpOZnkxQ4Df4/zbFWIvPjdK6rgDVa3nS7/nlNG7eu9RO+3Nz0rlw+ld2fFtMix/EyhZf0gapJTbERQKzES9GYI1p9EilEstfbOAvPirasijXfAzlBNoXwKFSW3q3XCzaViwe+H4FhTmEx+9ie9C75Bbe"
B64 .= "UsO7xQz5CvCGqkV/zw14NRxhMo2Vd7Pi+CtiPSeuGrTIEPn4YaFFR4CadVrR9/llStuK2f/QIj+H8NBd7PhuPDmZhrG1V+j7MvCmqGDS78X1tPR9yWT6xe7eiePkwY0c37PUWIvlIv3MeVyDWKI0zM1FtIe0ZzK+jKM6Lpgeeq5zhoMsJgpDq4banlBFCFMXwKPWv+jW7ENqV/O6p5yqI+72KQIuLCA2"
B64 .= "ZY8aDhczTyOUg6mqAO0aTqCj2/tUr2KaWty4c5ZDYcuITP5dDUYb7RkNKbJHm5foOmDa39pW9Ho916+e4sAfC7l6aZcajhR7LWdgvqpF2x4T6NhrPDUcG2GK3Ig5y6EdS4kMNWhxVVS7fntUgwwUS7ObUqrqR0/mF2sPMVUKyCWSvexkknHbSgBKPX4ISmt5JYCuTRbQzvVNbCvVISXjKscjPuV07GpD"
B64 .= "JRflwPOKqNQpLRHV+9HTc57SHqIx7S9kFupyiUjYy66gyaTnX1HDB8TmdZBxkaXLwPm07/4WttXqkJJ0lRP+n3HqwCpjLRai9JJ9DLgDNHDrRa9nF1LftYPpa1GQR+SFfez+ZRp3ky6p4UNiETj/sAZxF/l7XwAr6jCE9f+zPcRUyeI2QXzPfoq1amxCadWYCQxTyrFW+LhM5ni0YRnWAV9R1B4yAMBS"
B64 .= "68CQ1p+L9pBKZUqL7Lw7BMf8wN6w94vqHIoWX4l7HA6g0Zjj2/dDju9ZYpy7b0FpEZkuTIWltQNDRn1O05YDsbAsY1pk3iH4xI/s/Xm8sRabRaHh9oMMUlUsmUUtEXxMa17DBgfKMreJJJB1nKNYe8I8ilo1Whj9+FFR9RksNrZKS4T7x7Rp9Bo2VmVci/QrHA9fy9k4gxYpQoswoYVxzhkoBs0AUfCw"
B64 .= "BOjxzDLadBlNFTvHMq3FncQoju9fx5lD64y1WIDS+1dgbJC3xIbLHqAlb9GZiTjgTnlBj45YAglgPnEUa0+YjNKq8ZZIHSqLDa0jgJfTGDq7T8KxarPyo4Vex7XkEwScn8+1u/5qOEykWw2Bd8Rm3lpoUQvAy3cMnftNwtGpnGlx5QQBfyzgWsR+NXxRpOF7VYPoAZzoQi8W4EwXtJhTHskni0tsZzvj"
B64 .= "KChqAv0apbEyENESUbtKR/p4LcbZsUupNkE+US0Ks7h0fQc7gt8jX5dsrMUbwCmUsj61GvjQZ9hiXJp2Q2tWTrXIy+Zy8J/s+H48edmGquUPwEgNoB/EV3jxApZUoSKQwU1OsJ5AFqtVKh+xxDLIazMtGo7Ayty2YmiRk8hfkes5dmWhupJ4A3kAA0duxqvDCKysK4gWaYmcPLCBozvnA8QALlqApgyo"
B64 .= "MOYAqEJtmvHMff/Mve7gCmMOgCrWjnjUHXx/LVoNqjDmAKhi54iHd3Et5F8cJ5H8D6RBJBJpEIlEGkQikQaRSKRBJBJpEIlEGkQikQaRSKRBJBJpEIlEIg0ikUiDSCTSIBKJNIhEIg0ikUiDSCTSIBKJNIhEIg0ikUiDSCQSaRCJRBpEIpEGkUikQSQSaRCJRBpEIpEGkUikQSQSaRCJRCINIpFIg0gk"
B64 .= "0iASiTSIRFJ6BonhCAXkVpibziGVaA7e98+uJh6mQFeBtMhLJfrWofv+WfSlgxTk51QcLbLvEn25uBaGp9w2Zig9mE1d2lD0+PTyRSF5XGE/e5nFHULU8FbgZSAUaAzgWnMIPZrPol7NduVXC10+UbcC2Bs8g9s5wWr4d+AFlGfINwFo1HwwfkNmU8+lHWjKqRaF+URdDGDfb7NJvnFWDe8EBpkB+UCH"
B64 .= "O4RbnmMzOeRgjxvWVC1XIiQQzE4mcYhZZHML4BrKM8HXCYNMQHnSbYeU7HCrc7FfkpObjb1tU6wty5kWKcHsCprMwfAZZBfcBIhDeRT2GuA1ocVtwCclKcLq3LEvyc7OxL62G5UqVytXWtyMC2X3f6Zw8I/pZKUnAFwXWszAaHp0ApYDI9XYYLbgyTCssCvTAqRxg5NsVB/5DJAFrABWAWOAuUA1IB74"
B64 .= "EAgAlgGjVC0Gem2mRYPnsbYo20ZJz07g5JVNHLuyQA1lCy1WAq8D8420mA7sB5YK0yhajNxMi3bPY125jGuRmsCpQ1+oj3xWtVgpfJBpnGIZ0wH4FGgH4EAb+rKMRnRHi0WZEiCPDMLYynZGo6dADf8MTAWaA6sB9/u89C9gvNDmU6EJ9pVa06/Vclwcu2OmLWNaFGQQFreV7SFj0Ovz1fAvwDShwWrA"
B64 .= "4z4vPSW00ImV1hegRu2W9B/xEY08/DAzK2Na5GZy8dwfbP/mTXSF2Wr4VzEuYu79+fsllRoxey4HagN48ipdmEItPE1eAB2FXOUw/swlgUA1HAS8DySKWWIQgBV1GMRaXOhKODvZwRj15/XAt2KZ7SW0cAJoVnskXT2mUbtaC9PXQl9ITNJR/EPnEZ9+RA0HCy0SxCo6GMDSrBaDW63DxbEb4fG72BEy"
B64 .= "2liL74QWPYCPgLoAzdqOpOuAqdSu72X6WugKiY04iv8f87kRdVgNhwAfAIcf9DqzB8RDgC9ElatdIiHmZ9iAHnMcaIolVUxShEQusp/Z7GMCGcQhDDFBpE5vAt+oM2UPlvMsm6hHeyypghPeeDMGsOQ6gRqgFfCW0OJNoABon5QRan4mZgP6QnPs7dywMjdNLZLSLrE/dDb7wt4nPS8WIAmYJGbKMWLQ"
B64 .= "NwPo7raEZ9ttpn7N9liaV8GpujfeDceg1VciLuWoBmgJvC0KGW8CeUD7pPhQ8zOHN1Ko1+BQxx0raxPVIiEc/61z2PvzeNJTYgGSgcni9xvzv177MGWJxsAnwFAAc6ozlI24MwgLKpuEAJkkcZavOcCHRRkWfAYsBIYDS4BaAC0YTRcm46iMjfug5wZnOchSrrBVDUYBU8QAWQE8B2CmsWWo9xd41BuC"
B64 .= "hZmJaJGbxLnobwm4PEUN5Rtp8azYU9QGaFHndbp4TMGx6v/Q4s45DoYt4UqyQYtoYbIgocUwADMLW4aM2oSH9xAsrWxMQ4v0ZM4FfkPAb8W0+ByYB9x9mPf4J3W73qLK0QygHj3ozSIa4IPmgQvRkyWfbMLZxXbGkkeSGt4FTATsRd7cBqAWPvRlKc50QYv5/1/6I5cI9rCbaaQRoYb9xYpUW2jhCVDP"
B64 .= "rge9vBbSwN4XraZ0tCgozOFy/E62B71LXmGiGt4ttKghtGgL4GjTnr5eS3Gp1Q2t5iG00OURmbCPPSEfkpp7UQ0fEOmJA7AWaAHg1KgrfYYtpkHjjmi1paRFfg7hobvZ8f14cjJuqOG9QotL/+S9/mlh2xwYK2ajagBtGE9H3qemcoTwVNCjI46TBDCfWPap4ctCgAtiz/CycoPmDOZLmvMcVtj+48/K"
B64 .= "4g7B/MA+3i/yDmwUFZ8RQosaAK3rv0unphOpafsUtdDruH77FAEXFhGTsksNRwgtQoyqk2gwZ1DLzXjWH4aVxT/XIjvvDsExP7A3rJgWm4QWw4FFQE0A7y5j6dRnAva13Z6iFnquR5/iwLaFXL1UTIvJwJ+P8p6PevJTUwyMd8Q+hT6sxZuRVFLGyhPjDlGc4DNOs0YN3RW/oC1i8zkDlNyvIzPx4V3s"
B64 .= "lD3lY3GbKwSylnN8VnQpylL9sygVj1X3dL2brcHbeSSVrWo+US1SMq5yPGIdp2MNWqQBC4AvRfVpBmAD4NtoBj5NxlK1cv3H/x1kRHE8fB1nrq0zXIrQ4iehxbsGLZ5fjXfHV6hc5QlrkXyVE/7rORWw0liLRWLlzHvU933co1EvkWr0AKiKB/1Yjht9McOqRAXIJoUQfmIP44oKVrAZmAN0E/mwM4Ab"
B64 .= "w+jOTJzwpiRPwvXouMYJ/JlHHAFq+IJIu24JLXoC2Fm40d97BW51+mKmLWEt8lIIvfYzu8+PNdbiK2A20FnsGV0AGts/g1/zOTjVKGEt9Dqu3f4L/9B5xN31V8NhYuWKF6Xj3gBVajRmwIgVuHn1x9y8ZLXIyUol9OTP7PrxHWMtvgZmiiLNY1FSig0TvxRnZVf/DH7MKZEBqraH7GYaqRjy3yMi/1Xr"
B64 .= "890A7GjCAFbThN6YYfkE9z5ZXGIHO3iPfJLV8FaxefUSWjQCcK05FD/P2TjVaIPmcbXQ5XHlZgC7g6cY7wWOiZWzQOwFegDYWjRhoPdKGtfpg3kJG7SYFoXZXL7xJzuCxpOnu6WGt4mihqfQwhXA1XMIPYbMoa5zGzSP2bZSWJBH1KUD7PnlQ+7cDFXDx8XKea6k7q8km2ushSjTDcs6M/BhLFWp/0jz"
B64 .= "dTzBHGIJEfymBmPFIDwALBYlRzOAfqynJS8+8RTPmAxucYavOMQsNZQrZs6VooQ4A5SauG+j6fg0efcRUxw98SnBHL64nPDEX9TgNZSDPn+R7r6tatG3+TpaOb9MJcunqEXOLc5Eb+FQ+EzjSuIasbK/IWZ0WwCf3lPx6fke1Wo2eKTPSogL4dCOZYQH/ayG4lBK+T+V9H09ie6zuiiHSWKTbMYgNuPJ"
B64 .= "8IfeJN/lOifZwHGWFu2Vlc3mWpS2hwXFiwQfUFOZpEqFW4RxlBVc4BvD71CYwx+lbUW08GgYJNpWrCweroUnLTuek5EbCIwq1irzsTDiKGGO6gBtGoyno9v7T7VIcC+Jdy9y9NInnE/4Wg3dFObYK0rMowxavLIZz3bDsa70cG0raanxnDq4iWO7FhZl3ooBPxK6UBYMouJrXFqshQ+9WSTaVu5fWswl"
B64 .= "nTB+ZwdvoS/aV/0oZgcPYRAPgAb0oSfzRJm59L/WoqOAqxxmLzNI5LQaPi3SH73Qoj1ALRsfenstolGt7g8ss+YWZBAW9zt/hryFTm9ov/9JrNBuYnZuDlC/ak96tZhPA/uOaDQmoIWugKtJR9gXMpNbmSfV8BmhRaHQogOAQ7229Bm2BFcPP7Rm99ciLzeDsLNb2fHt28btIT+LcRH7JO/lSfcva1Ca"
B64 .= "4JZiOKh7nc5Mppbyuy02uPYzh5ucUMNnxT7jlkhZhih15qoM5QuTOqgsbvI0LvA7OxgtfIEe+F6sKL2FFnUAmtceRddmU6lVtaiFR6cvICbxKPtCZ3Mz47gaVltlEoQWQwHMNHYMbb0Zj7qDTOagsrjJ0wmL+50dwaPRo1O1+FGY3E+srk4AzduPokv/KdSu16KY0WIijrH/9zkkXD2mhoPFuDjyNO7h"
B64 .= "aTX424pq0/uglLe6s5S2jCGLZI6ykvNsKcpYYBZKM91sIYYVQA+W0YbRVMERU+cu1/mLzznBMjWUKcyxGaUuP8GghdtS2rqOJiv3NscuryI0/itDxiK0+Fn8+wOx16Ob22Laub5BFetapq9F1nVOXdlIYNQSYy2Wo5wnTRKVL+W+Bi+iXbc3yc5K4dieVYQc36y+JkmMh83qzFOeDKLSRMyAg4s+Xm+8"
B64 .= "qVuHUrsehlFLhCev0YXJZaJZ8t7N9Q3OcYhlRBYVGq6KQkOw8Wpwjxb5Rlo8I2baOgCedV6li8eUYqtOWSE+5RyHwpYSkWTQIkZocU5o8YwihRb0OmMtPhP7zrtP+5pL6ytifUQOrbZY/ylmkppiYLRT9y19WIwL3R6qPcRUKSSPSNrzPCgAAAeXSURBVPaxk0mkE6mGD4kVVW1bURuidgotqhvvWxxt"
B64 .= "OtDbaxGujj3QasuwFro8rtzcz+7gacal6iNCC3uxz1Tzb7VVJry0rrc0v0NpjnISH0lRe4hoidAyiC/LxRe2jMnmjjjsfK/IO0rKMB+lVSOKovaQVx618lUmtMhLIST2R/ZceK9oK6p0AMwVGUSsmCxKFVP4kvGzKN+9UM4LmI4P46hKPcort4niOGs5y6dqKFWkWtWAHwxauHxIB7d3qVa5QbnV4k5G"
B64 .= "NCciPjVul0kVk0WAKVyfmQlcw0tA73r4MYL/4s3Icvd9+HupTA3c6Esj+nKTcDKIs0b5JmMjoF9d22686Psr3i6vYG1RrVxrUcmyOk1q98HVoS8Jty+RkX/dGqWCedIUrs9k/l6sRnQr13+jyt+Xbi0N6Yir0hlSDBfHbtSt0bbiaKHR0sC+Iy6O3Uzu2uRfHCeRSINIJNIgEok0iEQiDSKRSINIJNIg"
B64 .= "Eok0iEQiDSKRSINIJBJpEIlEGkQikQaRSKRBJBJpEIlEGkQikQaRSKRBJBJpEIlEGkQikUiDSCTSIBKJNIhEIg0ikUiDSCTSIBKJNIhEIg0ikUiDSCQSaRCJRBpEIpEGkUikQSQSaRCJRBrkAdzgLMlEVCjxbxJK3H0exRefEkRS2uUKpcWtuxe4kXLO5K7LFB7iWRcYkkK49hSfYU5V7GmCBZXL7WBI"
B64 .= "5ybHWcNvvMBdogFygE1ANjA0JTvC7PTV9ZhpbHGwdcPCvPxqkZFzk8DwNfx65nnu5kSpWmwG05gtTeUpkR7AGqAPgA3ODGQVbgzAHKtyMxjyyOQS29jGaHTkquHfgSnAVfHf7sBqoB9AZfOGDGy1iqZOAzA3sy43WuQXZHHpxg62Bb1BoT5DDf8BTAZl1pAG+TtDgJVAY4BGDMaP2dSlHZoy/MRXHYVc"
B64 .= "4zj+zOM6B9XweeADKArcwyBgFdAEwKXGQPw851KvZtnWQq/XEZsciH/oPK6nGW79AjABE3k2uikbBMBSiDUbsAXowFR8eY9qNChzAyKZCAJZTRAb1dAdcW9fAIUPocUH4uftANo7T8bX7T2q2ziXPS3SIzkevpZzceuNtZgr0ssCU7xmU56KagPLgFfV6xzIF7TgBaypavKDIYtkgvie/UxUQwXABmAe"
B64 .= "kPIP385RaPG6QQuvL2jR4AWsLcqAFrm3CYr5nv0XJ6ihQqHF3EfQQhrkHtoCnwI+APa0pi/LaEQPzLAwuYstIJcIdvMnH5DFNTW8X6yKFx/z7dsILXwBalq3pG+r5bjW6omZ1gS1KMwl8uZe/gyaSGa+YVsRIFbFsLKw6pWVZFYDvAx8BDgBNONlujKN2niZRm6Nnhuc4QALieZPNXxFbDq3l7AWLwEf"
B64 .= "o1QA8aj1Mt2aTaN2NdPRIv7OWQIuLCT69g41HCWKEX+UpbTQrAxda6jIVQHaJXHe/Awb0WOOPW5YUaXULiyVWA6xhB28TopSnUwX6cOrJbBq3I/zQgsd0C4587zFmZiNFBZocLBripWFbelpkXmNwxeXsT34NVKyIwAyhBajysqqURZXkHtxAT4BngPQYs1QttCMoU/1/CSHu5znF3byNqBH/OPfwEzg"
B64 .= "5lO6DGdgBTAcQKuxZqj3FjzqDsHS3ObpaZGfxvlrv7Az9G3hW/TAN0KLhDI6zspwvVDBD1gLeALUozu9WEQDfNE+wcWxkHyiOcBeZpKM4fT3BPA+cKaUtOgutPACcLLtQh+vxTRw6IRW8wS10OUTfesg+0JmkZRtuPWTQotTZXx8lXmDqGni28AioAaAN2PpzERqKkcIJUoCIRzhIy7xkxq6AUwHvjcR"
B64 .= "Ld4EFgM1AbzrjaWT+wTsbd1K/MNupp7nyKWPuHjzBzUUL7T4jnKChvJDDWA+8K66t+rNGrwZSWVlrDwW6SRwii84yvyiDEtJ85YDmSamRXUjLcwBenmsorXLKCpblYAW2QmcjtrMkch5xlqsQilFZ5SjMVWuDKLSHKVtpRdAFVwZyCqa0PeR2lbyyOQiW9nO2+jIUsO/AlOBGBPXopnQojeAjXkjBnqv"
B64 .= "xK1Ov0dqW8kvyOLijW1sD3qbQn26Gr63VQZpkLLBM2KGdwVwZQh+zMGJNg/VqqGjkFgC8WceNzikhkNRaviHypgWQ4UWSgtPjUH4tZhL3RptH0oLvb6QmKRAAs7PN24P+f9aZaRBygBWwERgFih1YB8+xJdxVKX+A1+URDiBrCbYUFUmGZiD0h6iK8NaTBBaKC08zlPxdRtHNZuGD3xRcnoEgZfXEHR9"
B64 .= "gxq6TVF7SGE5Hz/l3iAqdShqW0GDGQPZiCcvYK20OAGQSTJBfIc/kwxZBUXtIanlRItiLTwatAzw2kSLBs8Xa1vJyk3m3NXv8L9k0EJtlZlbjrSQ3EMHlBKkHtA70l4/kn36GaTpn+c3vTVOevXPgD0obfjllXYopWk9oHeo3Fb/ss8e/czB6foX2m3VVzZvaKzFPrGfkVQQXkUpSeoBvQat8WCIQGk1"
B64 .= "ryi8glKqFlqYGWsRifIVBEkFpIpINXLEYLgrqjGWFVALG2Apyjca9UAaME3sWyQVHFdgAVBLSkEjqYVEInlo/g/N7eaKR28RJQAAAABJRU5ErkJggg=="
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
Return False
VarSetCapacity(Dec, DecLen, 0)
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
Return False
hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", &Dec, "UPtr", DecLen)
DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream)
hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", pBitmap)
DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
pBM:=VarSetCapacity(V,16,0)>>8
Ext:=LTrim(SubStr(sFile,-3),".")
E:=[0,0,0,0]
Enc:=0x557CF400|Round({"bmp":0, "jpg":1,"jpeg":1,"gif":2,"tif":5,"tiff":5,"png":6}[Ext])
NumPut(0x2EF31EF8,NumPut(0x0000739A,NumPut(0x11D31A04,NumPut(Enc+0,V,"UInt"),"UInt"),"UInt"),"UInt")
DllCall("Gdiplus.dll\GdipSaveImageToFile", "Ptr",pBitmap, "WStr", sFile, "Ptr",&V, "UInt",0)
DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
Return hBitmap
}
return