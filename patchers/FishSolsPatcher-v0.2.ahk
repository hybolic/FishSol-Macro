;@cleanupnuke
BAD_FILE_COUNTER := 0
BAD_FILE := false
file_contents := ""
KEYONLY := false
RETRYMODE := false

msgbox , 4 , , % "Are you only changing keybinds?"

IfMsgBox, Yes
	KEYONLY := true
IfMsgBox, No
	KEYONLY := false
	
RETRY_LOAD:

if BAD_FILE_COUNTER > 3
    ExitApp
FileSelectFile, SourceFile, 3, , % "Please Pick Sols Rng", % "fishSol-*.ahk"

if (SourceFile = "")
{
    MsgBox, % "Patch Cancelled`n         Bye!"
    ExitApp
}
	
if (not KEYONLY) and (SourceFile ~= "_PATCHED")
{
    BAD_FILE_COUNTER++
    MsgBox, % "Please dont re-patch a known patched file!"
    goto RETRY_LOAD
}

Loop, Read, %SourceFile%
{
    cur_line := A_LoopReadLine . "`r`n"
	if ((cur_line ~= "PATCHED FILE") or (cur_line ~= "if SNOWGOLEM") or (cur_line ~= "loop 5 {") or (cur_line ~= "DOTHETHING")) and (not KEYONLY)
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

if not KEYONLY
{
	if not (VERSION ~= "1.9.3")
		msgbox % "You are using version " VERSION " snowman patch will be added!"
	else
		msgbox % "You are using version " VERSION " snowman patch will not be added!`nIt's already a part of the plugins!"

	DTT_REGEX  := "(?:#SingleInstance Force\K)"
	DTT        := "n`n`n;;;;;;;;;;;;;PATCHED FILE;;;;;;;;;;;;;;`n`n"
				. "`nglobal DOTHETHING := true"
				. (((VERSION ~= "1.9.2") or (VERSION ~= "1.9.1")) ? "`nglobal SNOWGOLEM := true" : "`n;NO SNOW PATCH NEEDED")		; fixed in 1.9.3
			. "`n`n`n;;;;;;;;;;;;;PATCHED FILE;;;;;;;;;;;;;;`n`n"

	;;;;SNOW MAN CODE
	do_golem_code := false
	if (VERSION ~= "1.9.2") or (VERSION ~= "1.9.1")
	{
		do_golem_code := true
		OLD_CODE_1 := "(MouseMove, [\d]{3}, [\d]{3}, 3([\s\n]+)sleep 220\n(.*)\g3Click, Left[\s\n]+sleep 220)[\s\n]+Click, WheelUp [\d][\d][\s\n]+sleep 500[\s\n]+Click, WheelDown [\d][\d][\s\n]+sleep 300\K"
		NEW_CODE_1 := "$2$2$2if SNOWGOLEM$2{$2$3Send {s Down}$2$3sleep 4000$2$3Send {s Up}$2$3sleep 300$2$3Send {%keyW% Down}$2$3sleep 800$2$3Send {%keyW% Up}$2$3sleep 300$2$3Send {s Down}$2$3sleep 100$2$3Send {s Up}$2$3sleep 800$2$3Send {%keyA% Down}$2$3sleep 5000$2$3Send {%keyA% Up}$2$3sleep 300$2$3$2$3Send {s Down}$2$3sleep 500$2$3Send {s Up}$2$3sleep 300$2$3$2$3$2$3Send {%keyA% Down}$2$3sleep 2000$2$3Send {%keyA% Up}$2$3sleep 300$2$3$2$3Send {s Down}$2$3sleep 1200$2$3Send {s Up}$2$3sleep 300$2$3$2$3$2$3Send {Space Down}$2$3sleep 25$2$3Send {s Down}$2$3sleep 600$2$3Send {Space Up}$2$3sleep 520$2$3Send {s Up}$2$3sleep 300$2$3$2$3$2$3Send {e Down}$2$3sleep 150$2$3Send {e Up}$2$3sleep 150$2$3Send {e Down}$2$3sleep 150$2$3Send {e Up}$2$3sleep 150$2$3Send {e Down}$2$3sleep 150$2$3Send {e Up}$2$3sleep 150$2$3Send {e Down}$2$3sleep 150$2$3Send {e Up}$2$3sleep 150$2$3$1 $2$3Send, {Esc}$2$3Sleep, 650$2$3Send, R$2$3Sleep, 650$2$3Send, {Enter}$2$3sleep 2600$2$3$2$2$3sleep 220$2$3$2}$2"
	}
	
	;;;;ATTEMPT TO ADD FIX FOR LOOPING BIOMES -MIGHT NOT WORK
	OLD_CODE_2 := "((?<=Loop) (?={(\n.*?)PixelSearch..Px..Py..[\d]{1,4}..[\d]{1,4}..[\d]{1,4}..[\d]{1,4}..0x[0-9A-Fa-f]{6}..\d.{1,10}\g2if.\(!ErrorLevel\)))"
	NEW_CODE_2 := "$15$1"

	;;;;MOVES PLAYER OVER TO THE RIGHT WHILE FISHING IF YOU SET THE SETTING AT TOP OF FILE TO TRUE
	OLD_CODE_4 := "(?:Send, \{%keyA% Down\}[\s\n]+sleep 1400([\s\n]+)Send, \{%keyA% Up\}\n([\s]*)(?:\g2{2})sleep 75[\s\n]+Send, \{%keyW% Down\}[\s\n]+sleep 2670[\s\n]+Send, \{%keyW% Up\}\K)"

	RETRY_PATHING_PATCH:
	MsgBox, 3, , % "Start with Side path when fishing?`n[Can be disabled by setting DOTHETHING to false]`nYES: Alter Path By Default Unless on Failsafe`nNo: Alter Path Only on Failsafe`nCancel: Force Off"

	IfMsgBox, Yes
		NEW_CODE_4 := "$1if ((DOTHETHING) and (not fishingFailsafeRan))$1{$1$2sleep 200$1$2Send, {%keyA% Down}$1$2sleep 1400$1$2Send, {%keyA% Up}$1$2sleep 75$1$2Send, {%keyW% Down}$1$2sleep 100$1$2Send, {%keyW% Up}$1}"
	IfMsgBox, No
		goto NEW_CODE_4 := "$1if ((DOTHETHING) and (fishingFailsafeRan))$1{$1$2sleep 200$1$2Send, {%keyA% Down}$1$2sleep 1400$1$2Send, {%keyA% Up}$1$2sleep 75$1$2Send, {%keyW% Down}$1$2sleep 100$1$2Send, {%keyW% Up}$1}"
	IfMsgBox, Cancel
	{
		NEW_CODE_4 := "$1if ((false) and (DOTHETHING) and (fishingFailsafeRan))$1{$1$2sleep 200$1$2Send, {%keyA% Down}$1$2sleep 1400$1$2Send, {%keyA% Up}$1$2sleep 75$1$2Send, {%keyW% Down}$1$2sleep 100$1$2Send, {%keyW% Up}$1}"
		StrReplace("DOTHETHING := true", "DOTHETHING := false")
	}
	IfMsgBox, Timeout
		goto RETRY_PATHING_PATCH
	;NEW_CODE_4 := "$1if (DOTHETHING and fishingFailsafeRan)$1{$1$2sleep 200$1$2Send, {%keyA% Down}$1$2sleep 1400$1$2Send, {%keyA% Up}$1$2sleep 75$1$2Send, {%keyW% Down}$1$2sleep 100$1$2Send, {%keyW% Up}$1}"
}

KEYBINDS_PATCH:

gui, new, -ToolWindow -Border -Caption +AlwaysOnTop
gui, add, text,w300,% "Press the key you want for the macro to START`n[DEFAULT: """"F1""""]"


OLD_CODE_5 := "(Gui, Add, Text, x[\d]* y[\d]* w[\d]* h[\d]* BackgroundTrans, Hotkeys: )(.*?)(=Start - )(.*)(=Pause - )(.*)(=Stop)"

RegExMatch(file_contents, OLD_CODE_5, KEYS)

global KeyStart := KEYS2
global KeyPause := KEYS4
global KeyStop  := KEYS6

RETRY_KEYBIND_START:
gui, show

KeyStart_WAITING := KeyWaitAny()
gui, hide
if checkKey(KeyStart_WAITING)
{
	msgbox % "You can't use that key: [" KeyStart_WAITING "]`nused by the macro or the game!"
	goto RETRY_KEYBIND_STOP
}

MsgBox, 4, , % "You Pressed: " KeyStart_WAITING "`nDo you want this to be your START Macro key"
IfMsgBox, No
    goto RETRY_KEYBIND_START
IfMsgBox, Timeout
    goto RETRY_KEYBIND_START

gui, new, -ToolWindow -Border -Caption +AlwaysOnTop
gui, add, text,w300,% "Press the key you want for the macro to PAUSE`n[DEFAULT: """"F2""""]"

RETRY_KEYBIND_PAUSE:
gui, show

KeyPause_WAITING := KeyWaitAny()
gui, hide
if checkKey(KeyPause_WAITING)
{
	msgbox % "You can't use that key: [" KeyPause_WAITING "]`nused by the macro or the game!"
	goto RETRY_KEYBIND_PAUSE
}

MsgBox, 4, , % "You Pressed: " KeyPause_WAITING "`nDo you want this to be your PAUSE Macro key"
IfMsgBox, No
    goto RETRY_KEYBIND_PAUSE
IfMsgBox, Timeout
    goto RETRY_KEYBIND_PAUSE

gui, new, -ToolWindow -Border -Caption +AlwaysOnTop
gui, add, text,w300,% "Press the key you want for the macro to STOP`n[DEFAULT: """"F3""""]"

RETRY_KEYBIND_STOP:
gui, show

KeyStop_WAITING := KeyWaitAny()
gui, hide
if checkKey(KeyStop_WAITING)
{
	msgbox % "You can't use that key: [" KeyStop_WAITING "]`nused by the macro or the game!"
	goto RETRY_KEYBIND_STOP
}

MsgBox, 4, , % "You Pressed: " KeyStop_WAITING "`nDo you want this to be your STOP Macro key"
IfMsgBox, No
    goto RETRY_KEYBIND_STOP
IfMsgBox, Timeout
    goto RETRY_KEYBIND_STOP
MsgBox, 4, , % KeyStart_WAITING " " KeyPause_WAITING " " KeyStop_WAITING "`nAre you sure you want these keys?"
IfMsgBox, No
    goto RETRY_KEYBIND_START
IfMsgBox, Timeout
    goto RETRY_KEYBIND_START


NEW_CODE_5 := "$1" . KeyStart_WAITING . "$3" . KeyPause_WAITING . "$5" . KeyStop_WAITING . "$7"
OLD_CODE_6 := "\n\K[\w]*(?=::\nif.\(!res)"
OLD_CODE_7 := "\n\K[\w]*(?=::)(?=::\nif \(toggle)"
OLD_CODE_8 := "\n\K[\w]*(?=::\nif \(biome)"

file_contents1 := RegExReplace(file_contents , "[`r]", "", R_1)


if not KEYONLY
{
	file_contents1 := RegExReplace(file_contents1 , DTT_REGEX , DTT)
	;if version = 1.9.2
	if(do_golem_code)
		file_contents1 := RegExReplace(file_contents1 , OLD_CODE_1, NEW_CODE_1)
	file_contents1 := RegExReplace(file_contents1 , OLD_CODE_2, NEW_CODE_2)
	file_contents1 := RegExReplace(file_contents1 , OLD_CODE_4, NEW_CODE_4)
}
file_contents1 := RegExReplace(file_contents1 , OLD_CODE_5, NEW_CODE_5)
file_contents1 := RegExReplace(file_contents1 , OLD_CODE_6, KeyStart_WAITING)
file_contents1 := RegExReplace(file_contents1 , OLD_CODE_7, KeyPause_WAITING)
file_contents1 := RegExReplace(file_contents1 , OLD_CODE_8, KeyStop_WAITING)


file_contents1 := SubStr(file_contents1, 1, StrLen(file_contents1) - 1)
new_ahk := StrReplace(SourceFile, ".ahk", (KEYONLY ? ".ahk" : "_PATCHED.ahk"))
BAD_FILE_COUNTER := 0

RETRY_SAVE:

if BAD_FILE_COUNTER > 3
    ExitApp

FileSelectFile, outputFile, S26, % new_ahk, % "Save", % (KEYONLY ? "*.ahk" : "*_PATCHED.ahk")

if (outputFile = "") or InStr(outputFile, SourceFile) and (not KEYONLY)
{
    MsgBox, % "Please don't save over the original file!`nIDK WHY YOU'D DO IT BUT YOUR A BAD PERSON!!"
    BAD_FILE_COUNTER++
    goto RETRY_SAVE
}

FileDelete, %outputFile%
FileAppend, %file_contents1%, %outputFile%

Loop, Read, %outputFile%
{
    file_contents .= A_LoopReadLine . "`r`n"
}

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
	REGEX_KEYS_CHECK := "Escape|Button|Wheel|Space|Alt|Control|Shift|Win|Tab|Left|Right|Up|Down|Enter|Backspace|\b[wasdevcxqzfio\/0-9]\b|" KeyStart "|" KeyPause "|" KeyStop
	if (Key ~= REGEX_KEYS_CHECK)
		return true
	return false
}