;@cleanupnuke
BAD_FILE_COUNTER := 0
file_contents := ""

RETRY_LOAD:

if BAD_FILE_COUNTER > 3
    ExitApp
FileSelectFile, SourceFile, 3, , % "Please Pick Sols Rng", % "fishSol-*.ahk"

if (SourceFile = "")
{
    MsgBox, % "Patch Cancelled`n         Bye!"
    ExitApp
}
if(SourceFile ~= "_PATCHED")
{
    BAD_FILE_COUNTER++
    MsgBox, % "Please dont re-patch a known patched file!"
    goto RETRY_LOAD
}

Loop, Read, %SourceFile%
{
    file_contents .= A_LoopReadLine . "`r`n"
}

if instr(file_contents, "DOTHETHING")
{
    BAD_FILE_COUNTER++
    MsgBox, % "Please dont re-patch a patched file!`n`nUpon checking this file i can see its already been patched`nif this wasn't a mistake redownload fishsols 1.9.2 and run the patcher again!"
    goto RETRY_LOAD
}
file_contents    := RegExReplace(file_contents , "[`r]", "", R_1)
patched_contents := file_contents

gosub GET_KEY_BINDS
Gui WINDOW:new
Gui WINDOW:add, Text,                         , % "text"
Gui WINDOW:add, Checkbox,                     , % "Patch Fishing Offset"
Gui WINDOW:add, Checkbox,                     , % "Patch Biome Loop Fix"
Gui WINDOW:add, Checkbox,                     , % "Patch For Snowman"
Gui WINDOW:add, Checkbox,                     , % "Patch Keybinds"
Gui WINDOW:add, Text, xm  w40                 , % "Start"
Gui WINDOW:add, Text, x+m w40 vKeyVaribleStart, % Hotkeys.START.KEY
Gui WINDOW:add, Text, xm  w40                 , % "Pause"
Gui WINDOW:add, Text, x+m w40 vKeyVariblePause, % Hotkeys.PAUSE.KEY
Gui WINDOW:add, Text, xm  w40                 , % "Stop" 
Gui WINDOW:add, Text, x+m w40 vKeyVaribleStop_, % Hotkeys.STOP .KEY
Gui WINDOW:Show

return

NON_PATCH_GET_VERSION:
VERSION_REGEX := "(?i)(?P<Line>Gui..Add..Text..(?:(?:x\d+|y\d+|w\d+|h\d+|center|backgroundtrans|c0x[[:xdigit:]]+?)(?:\s+?|,))+?\sfishsol.+?(?P<VersionNumber>v(?:[\d]*+(?:[\.]|))*).*$)"
;patched_contents := RegExReplace(patched_contents , Test_Regex , DTT)

getRegexObject(file_contents,VERSION_REGEX,RegexObject)
if (RegexObject.Matches.1.Group.VersionNumber.Value) ~= "v1.9.2"
    MsgBox, % "Version is v1.9.2"
Else
    ExitApp 
Return

PATCH_KEY_BINDS:
; REGEX_START_PAUSE_STOP_Location := "(?i)(?:(^.+?|^)(?P<Start>[\w]+?)=start.+?(?P<Pause>[\w]+?)=pause.+?(?P<Stop>[\w]+?)(=stop.{0,100}?$))"
REGEX_SPS_REPLACER                := "(?i)(?:(^.+?hotkeys..)(?P<Start>[\w]+)(=start...)(?P<Pause>[\w]+?)(=pause...)(?P<Stop>[\w]+?)(=stop.{0,100}?$))"
TEST_STRING                       := "Gui, Add, Text, x45 y185 w240 h15 BackgroundTrans, Hotkeys: F1=Start - F2=Pause - F3=Stop"
REGEX_SPS_REPLACE_CODE            := "$1" . KB_START . "$3" . KB_PAUSE . "$5" . KB_STOP . "$7"
REGEX_REPLACE                     :=  KEY "$2"

patched_contents := RegExReplace(patched_contents , DTT_REGEX , DTT)


GET_KEY_BINDS:
; REGEX_MainInOne_KEYS  := "(?:(?:(?P<START>[\w]{2,})(?=::\n.*if.*\(!res\)))|(?:(?<=Started.{5}\d{7}..\n.\n.{6}\n\n)(?P<PAUSE>[\w]{2,})(?=::)(?!.*if.+\(!res\)))|(?:(?<!Started.{5}\d{7}..\n.\n.{6}\n\n)(?P<STOP>[\w]{2,})(?=::\nif.\(biomeDetectionRunning\))))(?P<VAR>::)"
; REGEX_SPS_REPLACER    := "(?i)(?:(^.+?hotkeys..)([\w]+)(=start...)([\w]+?)(=pause...)([\w]+?)(=stop.{0,100}?$))"
; REGEX_KEYBIND_START   := "(?i)((?P<HOTKEY>[\w]*)(::)(?=.*if.+\(!res\)))"
; REGEX_KEYBIND_PAUSE   := "(?i)(?<=Started.{5}\d{7}..\n.\n.{6}\n\n)(?i)(?P<Line>(?P<HOTKEY>[\w]*)(::)(?!.*if.+\(!res\)))"
; REGEX_KEYBIND_STOP    := "(?i)(?<!Started.{5}\d{7}..\n.\n.{6}\n\n)(?i)(?P<Line>(?P<HOTKEY>[\w]*)(::)(?=\nif.\(biomeDetectionRunning\)))"

REGEX_ALL_KEYS           := "(?P<KEYBIND>[\w]{2,})(?P<VAR>::)"
REGEX_GUI_KEYBIND_       := "(?i)(?=.*?hotkeys..)(.+?)(?P<START>[\w]+)(=start...)(?P<PAUSE>[\w]+?)(=pause...)(?P<STOP>[\w]+?)(=stop.{0,100}?)"
REGEX_SPS_REPLACE_CODE   := "$1" . KB_START . "$3" . KB_PAUSE . "$5" . KB_STOP . "$7"
REGEX_REPLACE            :=  KEY "$2"

; getRegexObject( file_contents , REGEX_KEYBIND_START , RegexObjectStr )
; getRegexObject( file_contents , REGEX_KEYBIND_PAUSE , RegexObjectPau )
; getRegexObject( file_contents , REGEX_KEYBIND_STOP  , RegexObjectStp )
getRegexObject( file_contents , REGEX_ALL_KEYS      , RegexObjectAll )
getRegexObject( file_contents , REGEX_GUI_KEYBIND_  , RegexGui )

Hotkeys := Object()

Hotkeys.START := Object()
Hotkeys.PAUSE := Object()
Hotkeys.STOP  := Object()

Hotkeys.START.REPLACE := "$2"
Hotkeys.START.MATCH   := RegexObjectAll.Matches[1]
Hotkeys.START.KEY     := RegexObjectAll.Matches[1].Group.KEYBIND.Value
Hotkeys.START.OFFSET  := RegexObjectAll.Matches[1].Position
Hotkeys.START.DEFAULT := "F1"

Hotkeys.PAUSE.REPLACE := "$2"
Hotkeys.PAUSE.MATCH   := RegexObjectAll.Matches[2]
Hotkeys.PAUSE.KEY     := RegexObjectAll.Matches[2].Group.KEYBIND.Value
Hotkeys.PAUSE.OFFSET  := RegexObjectAll.Matches[2].Position
Hotkeys.PAUSE.DEFAULT := "F2"

Hotkeys.STOP .REPLACE := "$2"
Hotkeys.STOP .MATCH   := RegexObjectAll.Matches[3]
Hotkeys.STOP .KEY     := RegexObjectAll.Matches[3].Group.KEYBIND.Value
Hotkeys.STOP .OFFSET  := RegexObjectAll.Matches[3].Position
Hotkeys.STOP .DEFAULT := "F3"

;set current keys in gui

return

PATCH_CONTENTS:
;;;;IDENTIFIES PATCHED CONTENT ASWELL AS ADD MOVEOVER FUNCTION TO SNOW GOLEM
DTT_REGEX  := "(?:#SingleInstance Force\K)"
DTT        := "`n;;;;;;;;;;;;;PATCHED FILE;;;;;;;;;;;;;;`n`n`nglobal DOTHETHING := false`nglobal SNOWGOLEM := true`nglobal FIX_COUNTER := 0`n`n`n;;;;;;;;;;;;;PATCHED FILE;;;;;;;;;;;;;;`n`n"
patched_contents := RegExReplace(patched_contents , DTT_REGEX , DTT)
return

PATCH_SNOWMAN_MOVE:
;;;;SNOW MAN CODE
OLD_CODE_1 := "(MouseMove, [\d]{3}, [\d]{3}, 3([\s\n]+)sleep 220\n(.*)\g3Click, Left[\s\n]+sleep 220)[\s\n]+Click, WheelUp [\d][\d][\s\n]+sleep 500[\s\n]+Click, WheelDown [\d][\d][\s\n]+sleep 300\K"
NEW_CODE_1 := "$2$2$2if SNOWGOLEM$2{$2$3Send {s Down}$2$3sleep 4000$2$3Send {s Up}$2$3sleep 300$2$3Send {%keyW% Down}$2$3sleep 800$2$3Send {%keyW% Up}$2$3sleep 300$2$3Send {s Down}$2$3sleep 100$2$3Send {s Up}$2$3sleep 800$2$3Send {%keyA% Down}$2$3sleep 5000$2$3Send {%keyA% Up}$2$3sleep 300$2$3$2$3Send {s Down}$2$3sleep 500$2$3Send {s Up}$2$3sleep 300$2$3$2$3$2$3Send {%keyA% Down}$2$3sleep 2000$2$3Send {%keyA% Up}$2$3sleep 300$2$3$2$3Send {s Down}$2$3sleep 1200$2$3Send {s Up}$2$3sleep 300$2$3$2$3$2$3Send {Space Down}$2$3sleep 25$2$3Send {s Down}$2$3sleep 600$2$3Send {Space Up}$2$3sleep 520$2$3Send {s Up}$2$3sleep 300$2$3$2$3$2$3Send {e Down}$2$3sleep 150$2$3Send {e Up}$2$3sleep 150$2$3Send {e Down}$2$3sleep 150$2$3Send {e Up}$2$3sleep 150$2$3Send {e Down}$2$3sleep 150$2$3Send {e Up}$2$3sleep 150$2$3Send {e Down}$2$3sleep 150$2$3Send {e Up}$2$3sleep 150$2$3$1 $2$3Send, {Esc}$2$3Sleep, 650$2$3Send, R$2$3Sleep, 650$2$3Send, {Enter}$2$3sleep 2600$2$3$2$2$3sleep 220$2$3$2}$2"
patched_contents := RegExReplace(patched_contents , OLD_CODE_1, NEW_CODE_1)
return

PATCH_BOIME_LOOP_FIX:
;;;;ATTEMPT TO ADD FIX FOR LOOPING BIOMES -MIGHT NOT WORK
OLD_CODE_3 := "(?:Run[^Aa][a-zA-Z]+er\(\) \{([\n\s]+)global res[\n\s]+global itemWebhook\K)"
NEW_CODE_3 := "$1FIX_COUNTER := 0" 
OLD_CODE_2 := "(?=(\n[ ]+?)PixelSearch, Px, Py, [\d]{1,4}, [\d]{1,4}, [\d]{1,4}, [\d]{1,4}, .{8}, 3, Fast RGB\g1if \(!ErrorLevel\) [\{]\n[\s]+break\n([\s]+)\g2{2}[\}] else [\{][\n\s]+MouseMove, [\d]{1,4}, [\d]{1,4}, 3[\n\s]*sleep 300[\n\s]*MouseClick, Left[\n\s]*sleep 300[\n\s]*MouseMove, [\d]{1,4}, [\d]{1,4}, 3[\n\s]*sleep 300[\n\s]*MouseClick, Left[\n\s]*sleep 300[\n\s]*\})\K"
NEW_CODE_2 := "$1FIX_COUNTER++$1if (FIX_COUNTER > 5)$1$2break"
patched_contents := RegExReplace(patched_contents , OLD_CODE_2, NEW_CODE_2)
patched_contents := RegExReplace(patched_contents , OLD_CODE_3, NEW_CODE_3)
Return

PATCH_SAME_SPOT_FIX:
;;;;MOVES PLAYER OVER TO THE RIGHT WHILE FISHING IF YOU SET THE SETTING AT TOP OF FILE TO TRUE
OLD_CODE_4 := "(?:Send, \{%keyA% Down\}[\s\n]+sleep 1400([\s\n]+)Send, \{%keyA% Up\}\n([\s]*)(?:\g2{2})sleep 75[\s\n]+Send, \{%keyW% Down\}[\s\n]+sleep 2670[\s\n]+Send, \{%keyW% Up\}\K)"
NEW_CODE_4 := "$1if (mod(loopCount, 3) = 2) and (DOTHETHING)$1{$1$2sleep 200$1$2Send, {%keyA% Down}$1$2sleep 1400$1$2Send, {%keyA% Up}$1$2sleep 75$1$2Send, {%keyW% Down}$1$2sleep 100$1$2Send, {%keyW% Up}$1}"
patched_contents := RegExReplace(patched_contents , OLD_CODE_4, NEW_CODE_4)
Return



;patched_contents := RegExReplace(patched_contents , OLD_CODE_1, NEW_CODE_1)
;patched_contents := RegExReplace(patched_contents , OLD_CODE_2, NEW_CODE_2)
;patched_contents := RegExReplace(patched_contents , OLD_CODE_3, NEW_CODE_3)
;patched_contents := RegExReplace(patched_contents , OLD_CODE_4, NEW_CODE_4)

Patch_Start_Write:
file_contents1 := SubStr(file_contents1, 1, StrLen(file_contents1) - 1)
new_ahk := StrReplace(SourceFile, ".ahk", "_PATCHED.ahk")
BAD_FILE_COUNTER := 0

RETRY_SAVE:

if BAD_FILE_COUNTER > 3
    ExitApp

FileSelectFile, outputFile, S26, % new_ahk, % "Save", % "*_PATCHED.ahk"

if (outputFile = "") or InStr(outputFile, SourceFile)
{
    MsgBox, % "Please don't save over the original file!`nIDK HOW YOU DID IT BUT YOU KNOW WHO YOU ARE!!"
    BAD_FILE_COUNTER++
    goto RETRY_SAVE
}

FileDelete, %outputFile%
FileAppend, %file_contents1%, %outputFile%

Loop, Read, %outputFile%
{
    file_contents .= A_LoopReadLine . "`r`n"
}

msgbox done!

return




getRegexObject(haystack, needle, byref VaribleOut, Study := false)
{
    VarOutValue := Object()
    VarOutValue.Matches := Object()
    
    
    if needle ~= "(?i)"
        REGEX .= "i"

    if not (needle ~= "$|^")
        REGEX .= "m"
    
    if Study
        REGEX .= "S"

    REGEX .= "O)" needle
    


    Match := 1
    lastPos := 1
    if not RegExMatch(haystack, REGEX, VarOut)
        return
    
    loop
    {
        curPos := RegExMatch(haystack, REGEX, VarOut, lastPos)
        if (curPos = 0)
            break

        VarOutValue.Matches[Match] := Object()
        if VarOut.Pos  [0] > 0
            VarOutValue.Matches[Match].Position := VarOut.Pos  [0]
        if VarOut.Len  [0] > 0
            VarOutValue.Matches[Match].Length   := VarOut.Len  [0]
        if VarOut.Value[0] != ""
            VarOutValue.Matches[Match].Value    := VarOut.Value[0]
        if VarOut.Name [0] != ""
            VarOutValue.Matches[Match].Name     := VarOut.Name [0]
        if VarOut.Mark() != ""
            VarOutValue.Matches[Match].Mark     := VarOut.Mark()

        if ((VarOut.Count()) > 1)
        {
            VarOutValue.Matches[Match].Count    := VarOut.Count()
            VarOutValue.Matches[Match].Group := Object()
            loop % VarOut.Count() 
            {
                index := A_Index
                if(VarOut.Name [A_Index])
                    index := VarOut.Name [A_Index]
                VarOutValue.Matches[Match].Group[index] := Object()
                VarOutValue.Matches[Match].Group[index].Position := VarOut.Pos  [A_Index]
                VarOutValue.Matches[Match].Group[index].Length   := VarOut.Len  [A_Index]
                VarOutValue.Matches[Match].Group[index].Value    := VarOut.Value[A_Index]
                if VarOut.Name [A_Index] != ""
                    VarOutValue.Matches[Match].Group[index].Name     := VarOut.Name [A_Index]
                VarOutValue.Matches[Match].Group[index].Index    := A_Index
                if (VarOutValue.Matches[Match].Group[index].Length = 0) and (VarOutValue.Matches[Match].Group[index].Position = 0) and (VarOutValue.Matches[Match].Group[index].Value = "")
                    something := VarOutValue.Matches[Match].Group.Delete(index)
            }
        }
        
        lastPos := (VarOut.Pos[0] + VarOut.Len[0])
        Match++
    }
    VarOutValue.Count := Match - 1
    VaribleOut := VarOutValue
    return tempOut
}
