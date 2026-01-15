SetBatchLines -1
DllCall("QueryPerformanceCounter", "Int64*", TIMER_START)
TIMER_s1 := TIMER_START
DllCall("QueryPerformanceFrequency", "Int64*", TIMER_f)
;#Requires AutoHotkey v1.1
#NoEnv
#SingleInstance Force

global MAX_SPEED := -1 ;max speed
global STANDARD_SPEED := A_BatchLines ;store default speed
CoordMode, ToolTip, Screen
global list_of_times := []
stopBench(message,number:=1)
{
    global
    DllCall("QueryPerformanceCounter", "Int64*", TIMER_st)
    list_of_times.push({ stop:TIMER_st, start:TIMER_s1, toolnum:number, msg:message })
    DllCall("QueryPerformanceCounter", "Int64*", TIMER_st)
    TIMER_s1 := TIMER_st
}

calc_time()
{
    global list_of_times, TIMER_f, TIMER_s2, TIMER_st, TIMER_START, TIMER_DONE

    ToolTip, % "GUI SHOW!" . " IT TOOK " .  ((TIMER_DONE - TIMER_START) / TIMER_f) * 1000 . "ms!", 10, % (250) + 5, 11
    ToolTip, % "GUI SHOWN => DOING ASYNC OPERATIONS", 10, 300, 12

    for _, time in list_of_times
    {
        ToolTip, % time.msg . " took " . ((time.stop - time.start) / TIMER_f) * 1000 . "ms" . " to load! (" . ((time.stop - TIMER_START) / TIMER_f) * 1000 . "ms)", 10, % (25 * time.toolnum) + 5, % (time.toolnum + 1)
    }
}

goto pasttool
KILL_TOOLTIP:
    loop 20
        ToolTip,,,,%A_Index%
return
pasttool:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  RESOURCES  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global INI_FILE := {}
global sec := []
INI_LOAD()
{
    global
    local file, curline, last_catagory, last_name
    stopBench("INI PRELOAD",0)
    file := FileOpen(iniFilePath, "r")
    while not file.AtEOF
    {
        curline := file.ReadLine()
        Number := Ord(curline)
        if Ord(curline) = 91
        {
            RegExMatch(curline, "\[(.*)\]", cat)
            if strlen(last_name) != 0
            {
                sec[last_name] := "___" (INI_FILE.Count() + 1) "___" last_name
                INI_FILE["___" (INI_FILE.Count() + 1) "___" . last_name] := last_catagory
            }
            last_name := StrReplace(cat1, """", "") ;remove quotes
            last_catagory := {} ;start new catagory
        }
        Else
        {
            pairs := StrSplit(curline, "=", "`r`n")
            last_catagory[pairs[1]] := pairs[2]
        }
    }
    sec[last_name] := "___" (INI_FILE.Count() + 1) "___" last_name
    INI_FILE["___" (INI_FILE.Count() + 1) "___" . last_name] := last_catagory
    stopBench("INI LOAD", 0)
    file.Close()
}

Section_to_Numbered_Section(Section)
{
    global
    return sec[Section]
}

; reduce file IO
INI_READ(byref Value, Section, Key, WriteDefault := "")
{ ; this function assumes you aren't being stupid with varibles and naming the legal names
    global
    if WriteDefault != ""                         ; check if write default is a value
        if not INI_FILE[sec[Section]].HasKey(Key)      ;  check if key doesn't exist
            INI_WRITE(WriteDefault, Section, Key) ;   key doesn't exist write default value
    Value := INI_FILE[sec[Section]][Key]               ;retrieve value
}
INI_WRITE(Value, Section, Key)
{
    global
    if not INI_FILE[sec[StrReplace(Section, """", "")]]                              ; if section does not exist
        INI_FILE[sec[StrReplace(Section, """", "")]] := {}                           ;  make empty section
    INI_FILE[sec[StrReplace(Section, """", "")]][StrReplace(Key, """", "")] := Value ; write value to key in section

    SetTimer, %INI_WRITE_FILE_FUNC%, -60000 ; after 60 seconds
}
INI_WRITE_FILE_FUNC := Func("INI_WRITE_FILE")
INI_WRITE_FILE()
{
    global
    local file, test_f
    test_f := iniFilePath
    file := FileOpen(test_f, "w")
    file.Position := 0
    for section_name, Section in INI_FILE
    {
        if strlen(section_name) = 0 or Section.Count() = 0
            Continue
        file.WriteLine("[" . RegExReplace(section_name, "___\d+___", "") . "]")
        for key, value in Section
            file.WriteLine(key . "=" . value)
    }
    file.Close()
}

IMAGE_LOAD()
{
    global
    stopBench("IMAGE PRELOAD",14)
    
    PNG_MAIN_TAB := "HBITMAP:*" LoadPicture(A_ScriptDir "\gui\Main.png")
    PNG_MISC_TAB := "HBITMAP:*" LoadPicture(A_ScriptDir "\gui\Misc.png")
    PNG_FAIL_TAB := "HBITMAP:*" LoadPicture(A_ScriptDir "\gui\Failsafes.png")
    PNG_BIOM_TAB := "HBITMAP:*" LoadPicture(A_ScriptDir "\gui\Biomes.png")
    PNG_CRAF_TAB := "HBITMAP:*" LoadPicture(A_ScriptDir "\gui\Crafter.png")
    PNG_WEBH_TAB := "HBITMAP:*" LoadPicture(A_ScriptDir "\gui\Webhook.png")
    PNG_SNOW_TAB := "HBITMAP:*" LoadPicture(A_ScriptDir "\gui\Snowman.png")
    PNG_CRED_TAB := "HBITMAP:*" LoadPicture(A_ScriptDir "\gui\Credits.png")
    PNG_DISCORD_ := "HBITMAP:*" LoadPicture(A_ScriptDir "\img\Discord.png")
    PNG_ROBLOX__ := "HBITMAP:*" LoadPicture(A_ScriptDir "\img\Robux.png")
    dev_maxstellar_img      := "HBITMAP:*" LoadPicture(A_ScriptDir . "\img\maxstellar.png")
    dev_ivelchampion249_img := "HBITMAP:*" LoadPicture(A_ScriptDir . "\img\Ivel.png")
    dev_cresqnt_img         := "HBITMAP:*" LoadPicture(A_ScriptDir . "\img\cresqnt.png")

    GuiControl, , IMAGE_HANDLE_PNG_MAIN_TAB, %PNG_MAIN_TAB%
    GuiControl, , IMAGE_HANDLE_PNG_MISC_TAB, %PNG_MISC_TAB%
    GuiControl, , IMAGE_HANDLE_PNG_FAIL_TAB, %PNG_FAIL_TAB%
    GuiControl, , IMAGE_HANDLE_PNG_BIOM_TAB, %PNG_BIOM_TAB%
    GuiControl, , IMAGE_HANDLE_PNG_CRAF_TAB, %PNG_CRAF_TAB%
    GuiControl, , IMAGE_HANDLE_PNG_WEBH_TAB, %PNG_WEBH_TAB%
    GuiControl, , IMAGE_HANDLE_PNG_SNOW_TAB, %PNG_SNOW_TAB%
    GuiControl, , IMAGE_HANDLE_PNG_CRED_TAB, %PNG_CRED_TAB%

    GuiControl, , IMAGE_HANDLE_DEV_IMG_1, % (%dev1_img%) ;% < tells the line that its to use contents of variables as text
    GuiControl, , IMAGE_HANDLE_DEV_IMG_2, % (%dev2_img%) ;% (%var%) <use variable text as variable call, basically string lookup of variable name
    GuiControl, , IMAGE_HANDLE_DEV_IMG_3, % (%dev3_img%)
    
    loop %pushDrawHelpDonate_index%
    {
        GuiControl, , IMAGE_HANDLE_PNG_DISCORD_%A_Index%, %PNG_DISCORD_%
        GuiControl, , IMAGE_HANDLE_PNG_ROBLOX__%A_Index%, %PNG_ROBLOX__%
    }
    stopBench("IMAGE LOAD",14)
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GuiColors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;define colors so they can be adjusted quickly on mass
global GuiColorDefault      := "c" . "0x" . "CCCCCC" ; default font text color
global GuiColorText         := "c" . "0x" . "FFFFFF" ; text color
global GuiColorRed          := "c" . "0x" . "FF4444" ; warning status, OFF and limits
global GuiColorLBlue        := "c" . "0x" . "00D4FF" ; fishsol version, need help text and "recommended for..." text
global GuiColorLGreen       := "c" . "0x" . "00DD00" ; used for runtime, status text and ON text
global GuiColorGreen        := "c" . "0x" . "00FF00" ; used for donate text
global GuiColorLGrey        :=       "0x" . "D3D3D3" ; background color (ommit "c")
global GuiColorLLGreen      := "c" . "0x" . "00AA00" ; start button color
global GuiColorYellowOrange := "c" . "0x" . "FFAA00" ; pause button color
global GuiColorOrange       := "c" . "0x" . "FF2C00" ; stop  button color
global GuiColorDonatorBG    :=       "0x" . "2D2D2D" ; background color for donator text box (ommit "c")
global GuiDefaultColor      :=       "0x" . "1E1E1E" ; default gui color (ommit "c")
global GuiLinkColor         := "c" . "0x" . "0088FF" ; used for dev name and links
global GuiSCBRColor         :=       "0x" . "696868" ; used for border box aroun "Strange Controller" and "Biome Randomizer" (ommit "c")
global GuiColorGlitch       := "c" . "0x" . "65FF65" ; Glitched text
global GuiColorDreamscape   := "c" . "0x" . "FF7DFF" ; Dreamspace text
global GuiColorCyberspace   := "c" . "0x" . "00DDFF" ; Cyberspace text
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
iniFilePath := A_ScriptDir "\settings.ini"
iconFilePath := A_ScriptDir "\img\icon.ico"
if (FileExist(iconFilePath)) {
    Menu, Tray, Icon, %iconFilePath%
}

global version := "1.9.4" ;EASIER VERSION MANAGEMENT
IniRead, lastVersion, %iniFilePath%, % "Macro", % "LastVersion" ;check if version number is saved to ini
if lastVersion != %version%
    IniWrite, version, %iniFilePath%, % "Macro", % "LastVersion" ;write version to file for plugins to pull

INI_LOAD()

res := "1080p"
maxLoopCount := 15
fishingLoopCount := 15
sellAllToggle := false
advancedFishingDetection := false
pathingMode := "Vip Pathing"
azertyPathing := false
autoUnequip := false
autoCloseChat := false
strangeController := false
biomeRandomizer := false
failsafeWebhook := false
pathingWebhook := false
itemWebhook := false
crafterToggle := false
autoCrafterDetection := false
autoCrafterLastCheck := 0
autoCrafterCheckInterval := 2000
snowmanPathing := false
snowmanPathingWebhook := false
autoCrafter := false
autoCrafterWebhook := false

if (FileExist(iniFilePath)) {
    ReadSetting(snowmanPathing, "Macro", "snowmanPathing", true)
    ReadSetting(snowmanPathingWebhook, "Macro", "snowmanPathingWebhook")
    ReadSetting(autoCrafter, "Macro", "autoCrafter", true)
    ReadSetting(autoCrafterWebhook, "Macro", "autoCrafterWebhook")
}

strangeControllerTime := 0
biomeRandomizerTime := 360000
snowmanPathingTime := 7500000
autoCrafterTime := 300000 ; defined but never used
strangeControllerInterval := 1260000
biomeRandomizerInterval := 1260000
snowmanPathingInterval := 7500000
autoCrafterInterval := 300000
elapsed := 0
strangeControllerLastRun := 0
biomeRandomizerLastRun := 0
snowmanPathingLastRun := 0
autoCrafterLastRun := 0  ; defined but never used
privateServerLink := ""
globalFailsafeTimer := 0
fishingFailsafeTime := 31
pathingFailsafeTime := 61
autoRejoinFailsafeTime := 320
advancedFishingThreshold := 25
webhookURL := ""
biomesPrivateServerLink := ""
biomeDetectionRunning := false
auroraDetection := false ; defined but never used
;hasCrafterPlugin := FileExist(A_ScriptDir "\plugins\auto crafter.ahk") ; already defined below look for [REDFINED=hasCrafterPlugin]

ReadSetting(byref var, catagory, name, isBoolOrMin:=false, max:="")
{
    global
    val := INI_FILE[sec[catagory]][name]
    if val
    {
        if max is Number
            var := max(min(val, max), isBoolOrMin)
        else if isBoolOrMin
            var := (val = "true" || val = "1")
        else
            var := val
    }
    else
    {
        IniRead, temp_var, %iniFilePath%, % catagory, % name
        if (temp_var != "ERROR")
        {
            if max is Number
                var := max(min(temp_var, max), isBoolOrMin)
            else if isBoolOrMin
                var := (temp_var = "true" || temp_var = "1")
            else
                var := temp_var
        }
    }
}

if (FileExist(iniFilePath)) {
    ReadSetting(res, "Macro", "resolution")
    ReadSetting(maxLoopCount, "Macro", "maxLoopCount", 1, 10000) ; adjust if needed
    ReadSetting(fishingLoopCount, "Macro", "fishingLoopCount", 1, 10000) ; adjust if needed
    ReadSetting(sellAllToggle, "Macro", "sellAllToggle", true)
    ReadSetting(pathingMode, "Macro", "pathingMode")
    ; [REDFINED=azertyPathing]
    ReadSetting(azertyPathing, "Macro", "azertyPathing", true)
    ReadSetting(privateServerLink, "Macro", "privateServerLink")
    ReadSetting(advancedFishingDetection, "Macro", "advancedFishingDetection", true)
    ReadSetting(fishingFailsafeTime, "Macro", "fishingFailsafeTime", 1, 3600000000) ; adjust if needed
    ReadSetting(pathingFailsafeTime, "Macro", "pathingFailsafeTime", 1, 3600000000) ; adjust if needed
    ReadSetting(autoRejoinFailsafeTime, "Macro", "autoRejoinFailsafeTime", 1, 3600000000) ; adjust if needed
    ReadSetting(autoUnequip, "Macro", "autoUnequip", true)
    ; on here twice check [REDFINED=azertyPathing]
    ; IniRead, tempAzerty, %iniFilePath%, "Macro", "azertyPathing"
    ; if (tempAzerty != "ERROR")
    ; {
    ;     azertyPathing := (tempAzerty = "true" || tempAzerty = "1")
    ; }
    ReadSetting(advancedFishingThreshold, "Macro", "advancedFishingThreshold", 0, 40) ; adjust if needed
    ReadSetting(strangeController, "Macro", "strangeController", true)
    ReadSetting(biomeRandomizer, "Macro", "biomeRandomizer", true)
    ReadSetting(autoCloseChat, "Macro", "autoCloseChat", true)
    ReadSetting(webhookURL, "Macro", "webhookURL")
    ReadSetting(biomesPrivateServerLink, "Biomes", "privateServerLink")
    ReadSetting(failsafeWebhook, "Macro", "failsafeWebhook", true)
    ReadSetting(pathingWebhook, "Macro", "pathingWebhook", true)
    ReadSetting(itemWebhook, "Macro", "itemWebhook", true)
    ; [REDEFINED=crafterToggle]
    ReadSetting(crafterToggle, "Macro", "crafterToggle", true)
    ; [REDEFINED=autoCrafterDetection]
    ReadSetting(autoCrafterDetection, "Macro", "autoCrafterDetection", true)
}

; checks plugin folder
hasBiomesPlugin := FileExist(A_ScriptDir "\plugins\biomes.ahk")
hasCrafterPlugin := FileExist(A_ScriptDir "\plugins\auto crafter.ahk") ; [REDFINED=hasCrafterPlugin]
hasSnowmanPlugin := FileExist(A_ScriptDir "\plugins\snowman.pathing.ahk")

; already been checked look for [REDEFINED=crafterToggle] and [REDEFINED=autoCrafterDetection] comment above
; if (FileExist(iniFilePath)) {
; .....
; }

code := ""
if RegExMatch(privateServerLink, "code=([^&]+)", m)
{
    code := m1
}

Random,, A_TickCount
randomMessages := ["Go catch some fish IRL sometime!"
                    , "Also try FishScope!"
                    , "Also try maxstellar's Biome Macro!"
                    , "Also try MultiScope!"
                    , "Patch notes: Fixed a Geneva Convention violation"
                    , "Patch notes: Removed Herobrine"
                    , "oof"
                    , "Now with 100% more fishing!"
                    , "Gone fishing"
                    , "No fish were harmed in the making of this macro"]

Random, messageRand, 1, randomMessages.Length()

randomMessage := randomMessages[messageRand]

Devs := [{dev_name:"maxstellar"
         , dev_role:"Twitch"
         , dev_discord:"Lead Developer"
         , dev_img: "dev_maxstellar_img"
         , dev_link:"https://www.twitch.tv/maxstellar"}
        ,{dev_name:"ivelchampion249"
         , dev_role:"YouTube"
         , dev_discord:"Original Creator"
         , dev_img: "dev_ivelchampion249_img"
         , dev_link:"https://www.youtube.com/@ivelchampion"}
       ,{dev_name:"cresqnt"
         , dev_role:"Scope Development (other macros)"
         , dev_discord:"Frontend Developer"
         , dev_img: "dev_cresqnt_img"
         , dev_link:"https://scopedevelopment.tech"
         , dev_website:"https://cresqnt.com"}]

       


;unrolled loop
; Randomised_DevOrder := "1|2|3"
; Sort, Randomised_DevOrder, Random D|
; Randomised_DevOrder := StrSplit(Randomised_DevOrder, "|")
; dev1_name       := Devs[Randomised_DevOrder[1]].dev_name
; dev1_role       := Devs[Randomised_DevOrder[1]].dev_role
; dev1_discord    := Devs[Randomised_DevOrder[1]].dev_discord
; dev1_img        := Devs[Randomised_DevOrder[1]].dev_img
; dev1_link       := Devs[Randomised_DevOrder[1]].dev_link
; dev1_website    := Devs[Randomised_DevOrder[1]].dev_website

; dev2_name       := Devs[Randomised_DevOrder[2]].dev_name
; dev2_role       := Devs[Randomised_DevOrder[2]].dev_role
; dev2_discord    := Devs[Randomised_DevOrder[2]].dev_discord
; dev2_img        := Devs[Randomised_DevOrder[2]].dev_img
; dev2_link       := Devs[Randomised_DevOrder[2]].dev_link
; dev2_website    := Devs[Randomised_DevOrder[2]].dev_website

; dev3_name       := Devs[Randomised_DevOrder[3]].dev_name
; dev3_role       := Devs[Randomised_DevOrder[3]].dev_role
; dev3_discord    := Devs[Randomised_DevOrder[3]].dev_discord
; dev3_img        := Devs[Randomised_DevOrder[3]].dev_img
; dev3_link       := Devs[Randomised_DevOrder[3]].dev_link
; dev3_website    := Devs[Randomised_DevOrder[3]].dev_website

; loop
loop % Devs.Length()
{
    Randomised_DevOrder .= A_Index
    if (A_Index) < (Devs.Length())
        Randomised_DevOrder .= "|"
} 
Sort, Randomised_DevOrder, Random D|
Randomised_DevOrder := StrSplit(Randomised_DevOrder, "|")
loop % Devs.Length()
{
    dev%A_Index%_name       := Devs[Randomised_DevOrder[A_INDEX]].dev_name
    dev%A_Index%_role       := Devs[Randomised_DevOrder[A_INDEX]].dev_role
    dev%A_Index%_discord    := Devs[Randomised_DevOrder[A_INDEX]].dev_discord
    dev%A_Index%_img        := Devs[Randomised_DevOrder[A_INDEX]].dev_img
    dev%A_Index%_link       := Devs[Randomised_DevOrder[A_INDEX]].dev_link
    dev%A_Index%_website    := Devs[Randomised_DevOrder[A_INDEX]].dev_website
}

Gui, Color, %GuiDefaultColor%
Gui, Font, s17 %GuiColorText% Bold, Segoe UI
Gui, Add, Text, x0 y10 w600 h45 Center BackgroundTrans %GuiColorLBlue%, fishSol v%version%

Gui, Font, s9 %GuiColorText% Normal, Segoe UI
; Gui, show
stopBench("INITIAL",1)
global pushDrawHelpDonate_index := 0
DrawHelpDonate(X:=0) ; define DrawHelpDonate() function to reuse same code elsewhere
{
    global
    local xOFF1, xOFF2, xOFF3, xOFF4
    
    Gui, Font, s10 %GuiColorText% Normal Bold
    
    Gui, Color, %GuiDefaultColor%
    pushDrawHelpDonate_index++
    xOFF1 := 445 + X
    Gui, Add, Picture, x%xOFF1% y600 w27 h19 vIMAGE_HANDLE_PNG_DISCORD_%pushDrawHelpDonate_index% ;, %PNG_DISCORD_%
    xOFF2 := 538 + X
    Gui, Add, Picture, x%xOFF2% y601 w18 h19 vIMAGE_HANDLE_PNG_ROBLOX__%pushDrawHelpDonate_index% ;, %PNG_ROBLOX__%

    Gui, Font, s11 %GuiColorText% Bold Underline, Segoe UI
    
    xOFF3 := 430 + X
    Gui, Add, Text, x%xOFF3% y600 w150 h38 Center BackgroundTrans %GuiColorGreen% gDonateClick, Donate!
    xOFF4 := 330 + X
    Gui, Add, Text, x%xOFF4% y600 w138 h38 Center BackgroundTrans %GuiColorLBlue% gNeedHelpClick, Need Help?

    Gui, Font, s10 %GuiColorText% Bold, Segoe UI
}

DrawHelpDonate(-5)

Gui, Font, s10 %GuiColorText% Normal Bold

; adds plugin to tab list
tabList := "Main|Misc|Failsafes|Webhook"
if (hasBiomesPlugin)
    tabList .= "|Biomes"
if (hasCrafterPlugin)
    tabList .= "|Crafter"
if (hasSnowmanPlugin)
    tabList .= "|Snowman"
tabList .= "|Credits"

Gui, Add, Tab3, x15 y55 w570 h600 vMainTabs gTabChange cWhite, %tabList%

Gui, Tab, Main

Gui, Add, Picture, x14 y60 w574 h590 vIMAGE_HANDLE_PNG_MAIN_TAB

DrawHelpDonate(-5)

Gui, Font, s11 %GuiColorText% Normal Bold
Gui, Add, Text, x45 y110 w60 h25 BackgroundTrans, Status:
Gui, Add, Text, x98 y110 w150 h25 vStatusText BackgroundTrans %GuiColorRed%, Stopped

Gui, Font, s10 %GuiColorText% Bold, Segoe UI
Gui, Add, Button, x45 y140 w70 h35 gStartScript vStartBtn %GuiColorLLGreen% +0x8000 , Start
Gui, Add, Button, x125 y140 w70 h35 gPauseScript vPauseBtn %GuiColorYellowOrange% +0x8000 , Pause
Gui, Add, Button, x205 y140 w70 h35 gCloseScript vStopBtn %GuiColorRed% +0x8000 , Stop

Gui, Font, s8 %GuiColorDefault%
Gui, Add, Text, x45 y185 w240 h15 BackgroundTrans, Hotkeys: F1=Start - F2=Pause - F3=Stop


Gui, Font, s10 %GuiColorText% Bold, Segoe UI
Gui, Font, s10 %GuiColorText% Bold
Gui, Add, Text, x320 y110 w80 h25 BackgroundTrans, Resolution:
Gui, Add, DropDownList, x320 y135 w120 h200 vResolution gSelectRes, 1080p|1440p|1366x768

Gui, Font, s9 %GuiColorText% Bold, Segoe UI
Gui, Add, Text, x320 y165 w220 h25 vResStatusText BackgroundTrans, Ready

Gui, Font, s10 %GuiColorText% Bold
Gui, Add, Button, x450 y135 w100 h25 gToggleSellAll vSellAllBtn, Toggle Sell All
Gui, Font, s8 %GuiColorDefault%
Gui, Add, Text, x450 y165 w100 h25 vSellAllStatus BackgroundTrans +%GuiColorRed%, OFF

Gui, Font, s10 %GuiColorText% Bold, Segoe UI
Gui, Font, s10 %GuiColorText% Bold
Gui, Add, Text, x45 y240 w180 h25 BackgroundTrans, Fishing Loop Count:
Gui, Add, Edit, x220 y238 w60 h25 vMaxLoopInput gUpdateLoopCount Number Background%GuiColorLGrey% cBlack, %maxLoopCount%
Gui, Font, s8 %GuiColorDefault%
Gui, Add, Text, x285 y242 w270 h15 BackgroundTrans, (Fishing Cycles Before Reset - default: 15)
Gui, Font, s10 %GuiColorText% Bold
Gui, Add, Text, x45 y270 w180 h25 BackgroundTrans, Sell Loop Count:
Gui, Add, Edit, x220 y268 w60 h25 vFishingLoopInput gUpdateLoopCount Number Background%GuiColorLGrey% cBlack, %fishingLoopCount%
Gui, Font, s8 %GuiColorDefault%
Gui, Add, Text, x285 y272 w270 h15 BackgroundTrans, (Sell Cycles  -  If Sell All: 22)
Gui, Font, s10 %GuiColorText% Bold
Gui, Add, Text, x45 y301 w120 h25 BackgroundTrans, Pathing Mode:
Gui, Add, DropDownList, x145 y298 w135 h200 vPathingMode gSelectPathing, Vip Pathing|Non Vip Pathing|Abyssal Pathing

Gui, Add, Text, x295 y301 w120 h25 BackgroundTrans, AZERTY Pathing:
Gui, Add, Button, x415 y298 w80 h25 gToggleAzertyPathing vAzertyPathingBtn, Toggle
Gui, Font, s10 %GuiColorDefault% Bold, Segoe UI
Gui, Add, Text, x510 y303 w60 h25 vAzertyPathingStatus BackgroundTrans +%GuiColorRed%, OFF

Gui, Font, s10 %GuiColorText% Bold

Gui, Color, %GuiDefaultColor%
Gui, Font, s10 %GuiColorText% Bold, Segoe UI

Gui, Font, s11 %GuiColorOrange% Bold
Gui, Font, s10 %GuiColorText% Bold
Gui, Add, Button, x270 y380 w80 h25 gToggleAdvancedFishingDetection vAdvancedFishingDetectionBtn, Toggle
Gui, Font, s10 %GuiColorDefault% Bold, Segoe UI
Gui, Add, Text, x360 y384 w60 h25 vAdvancedFishingDetectionStatus BackgroundTrans +%GuiColorRed%, OFF

Gui, Font, s9 %GuiColorText% Bold, Segoe UI
Gui, Add, Text, x270 y415 w260 cWhite BackgroundTrans, Advanced Detection Threshold -
Gui, Font, s9 %GuiColorText% Normal
Gui, Add, Text, x270 y435 w270 h40 BackgroundTrans %GuiColorDefault%, Customize how many pixels are left in the fishing range before clicking.
Gui, Font, s10 %GuiColorText% Bold
Gui, Add, Text, x400 y384 w80 h25 BackgroundTrans, Pixels:
Gui, Font, s9 %GuiColorText% Bold
Gui, Add, Text, x453 y416 w120 BackgroundTrans %GuiColorRed%, Max : 40 Pixels
Gui, Font, s10 %GuiColorText% Bold
Gui, Add, Edit, x455 y380 w75 h25 vAdvancedThresholdInput gUpdateAdvancedThreshold Number Background%GuiColorLGrey% cBlack, %advancedFishingThreshold%

Gui, Font, s9 %GuiColorDefault% Normal
Gui, Add, Text, x50 y470 w515 h30 BackgroundTrans, Advanced Fishing Detection uses a system that clicks slightly before the bar exits the fish range, making the catch rate higher than ever.

Gui, Font, s9 %GuiColorLBlue% Bold
Gui, Add, Text, x307 y485 w515 h30 BackgroundTrans %GuiColorLBlue%, [ Recommended For Lower End Devices ]

Gui, Font, s11 %GuiColorText% Bold, Segoe UI
Gui, Add, Text, x50 y375 w100 h30 BackgroundTrans, Runtime:
Gui, Add, Text, x120 y375 w120 h30 vRuntimeText BackgroundTrans %GuiColorLGreen%, 00:00:00

Gui, Add, Text, x50 y405 w100 h30 BackgroundTrans, Cycles:
Gui, Add, Text, x102 y405 w120 h30 vCyclesText BackgroundTrans %GuiColorLGreen%, 0

Gui, Font, s9 %GuiColorDefault% Normal
Gui, Add, Text, x50 y545 w500 h20 BackgroundTrans, Requirements: 100`% Windows scaling - Roblox in fullscreen mode
Gui, Add, Text, x50 y563 w500 h20 BackgroundTrans, For best results, make sure you have good internet and avoid screen overlays

stopBench("MAIN",2)

Gui, Tab, Misc

Gui, Add, Picture, x14 y80 w574 h590 vIMAGE_HANDLE_PNG_MISC_TAB ;, %PNG_MISC_TAB%

Gui, Font, s10 %GuiColorText% Bold, Segoe UI
Gui, Font, s9 %GuiColorText% Normal
Gui, Add, Text, x45 y135 h45 w250 BackgroundTrans %GuiColorDefault%, Automatically unequips rolled auras every pathing cycle, preventing lag and pathing issues.
Gui, Font, s10 %GuiColorText% Bold
Gui, Add, Button, x45 y188 w80 h25 gToggleAutoUnequip vAutoUnequipBtn, Toggle
Gui, Font, s10 %GuiColorDefault% Bold, Segoe UI
Gui, Add, Text, x140 y192 w60 h25 vAutoUnequipStatus BackgroundTrans +%GuiColorRed%, OFF
Gui, Font, s10 %GuiColorText% Bold, Segoe UI

Gui, Font, s11 %GuiColorText% Bold
Gui, Add, Text, x45 y260 w150 h25 BackgroundTrans, Strange Controller:
Gui, Add, Text, x45 y303 w190 h25 BackgroundTrans, Biome Randomizer:
Gui, Font, s10 %GuiColorText% Bold
Gui, Add, Button, x200 y270 w80 h25 gToggleStrangeController vStrangeControllerBtn, Toggle
Gui, Add, Button, x200 y314 w80 h25 gToggleBiomeRandomizer vBiomeRandomizerBtn, Toggle
Gui, Font, s10 %GuiColorDefault% Bold, Segoe UI
Gui, Add, Text, x290 y275 w60 h25 vStrangeControllerStatus BackgroundTrans +%GuiColorRed%, OFF
Gui, Add, Text, x290 y319 w60 h25 vBiomeRandomizerStatus BackgroundTrans +%GuiColorRed%, OFF

Gui, Add, Progress, x41 y270 w1 h27 Background%GuiSCBRColor%
Gui, Add, Progress, x190 y270 w1 h27 Background%GuiSCBRColor%
Gui, Add, Progress, x41 y296 w149 h1 Background%GuiSCBRColor%
Gui, Add, Progress, x184 y269 w7 h1 Background%GuiSCBRColor%
Gui, Font, s10 %GuiColorText% Normal
Gui, Add, Text, x47 y278 w500 h40 BackgroundTrans %GuiColorDefault%, Uses every 21 minutes.

Gui, Font, s10 %GuiColorText% Normal
Gui, Add, Text, x327 y275 w500 h15 BackgroundTrans, Automatically uses Strange Controller.

Gui, Add, Progress, x41 y313 w1 h27 Background%GuiSCBRColor%
Gui, Add, Progress, x190 y313 w1 h27 Background%GuiSCBRColor%
Gui, Add, Progress, x41 y339 w149 h1 Background%GuiSCBRColor%
Gui, Add, Progress, x184 y313 w7 h1 Background%GuiSCBRColor%
Gui, Font, s10 %GuiColorText% Normal
Gui, Add, Text, x47 y321 w500 h40 BackgroundTrans %GuiColorDefault%, Uses every 36 minutes.

Gui, Font, s10 %GuiColorText% Normal
Gui, Add, Text, x327 y319 w500 h15 BackgroundTrans, Automatically uses Biome Randomizer.

Gui, Font, s10 %GuiColorText% Bold, Segoe UI
Gui, Font, s9 %GuiColorText% Normal
Gui, Add, Text, x320 y135 w230 h60 BackgroundTrans %GuiColorDefault%, Automatically closes chat every pathing cycle to ensure you don't get stuck in collection.
Gui, Font, s10 %GuiColorText% Bold
Gui, Add, Button, x320 y188 w80 h25 gToggleAutoCloseChat vAutoCloseChatBtn, Toggle
Gui, Font, s10 %GuiColorDefault% Bold, Segoe UI
Gui, Add, Text, x415 y192 w60 h25 vAutoCloseChatStatus BackgroundTrans +%GuiColorRed%, OFF

DrawHelpDonate()

stopBench("MISC",3)

Gui, Tab, Failsafes

Gui, Add, Picture, x14 y80 w574 h590 vIMAGE_HANDLE_PNG_FAIL_TAB ;, %PNG_FAIL_TAB%

Gui, Font, s10 %GuiColorText% Normal
Gui, Add, Text, x50 y140 w500 h40 BackgroundTrans %GuiColorDefault%, If the fishing minigame is not detected for the specified time, the macro will`nautomatically rejoin using the private server link below.

Gui, Font, s10 %GuiColorText% Bold
Gui, Add, Text, x50 y190 w150 h25 BackgroundTrans, Private Server Link:
Gui, Add, Edit, x50 y215 w500 h25 vPrivateServerInput gUpdatePrivateServer Background%GuiColorLGrey% cBlack, %privateServerLink%

Gui, Font, s8 %GuiColorDefault% Normal
Gui, Add, Text, x50 y245 w500 h15 BackgroundTrans, Paste your Roblox private server link here (leave empty to disable)

Gui, Font, s10 %GuiColorText% Normal
Gui, Add, Text, x79 y306 w450 h40 BackgroundTrans %GuiColorDefault%, Customize how long until the Auto-Rejoin Failsafe triggers. (Default : 320)

Gui, Font, s11 %GuiColorText% Bold
Gui, Add, Text, x145 y275 w150 h25 BackgroundTrans, Seconds:
Gui, Add, Edit, x218 y272 w150 h25 vAutoRejoinFailsafeInput gUpdateAutoRejoinFailsafe Number Background%GuiColorLGrey% cBlack, %autoRejoinFailsafeTime%

Gui, Font, s10 %GuiColorText% Bold, Segoe UI

Gui, Font, s9 %GuiColorText% Normal
Gui, Add, Text, x45 y370 w230 h40 BackgroundTrans %GuiColorDefault%, Customize how long until the Fishing Failsafe triggers. (Default : 31)

Gui, Font, s11 %GuiColorText% Bold
Gui, Add, Text, x45 y413 w150 h35 BackgroundTrans, Seconds:
Gui, Add, Edit, x125 y411 w150 h25 vFishingFailsafeInput gUpdateFishingFailsafe Number Background%GuiColorLGrey% cBlack, %fishingFailsafeTime%

Gui, Font, s10 %GuiColorText% Bold, Segoe UI

Gui, Font, s9 %GuiColorText% Normal
Gui, Add, Text, x320 y370 w230 h45 BackgroundTrans %GuiColorDefault%, Customize how long until the Pathing Failsafe triggers. (Default : 61)

Gui, Font, s11 %GuiColorText% Bold
Gui, Add, Text, x320 y413 w150 h35 BackgroundTrans, Seconds:
Gui, Add, Edit, x400 y411 w150 h25 vPathingFailsafeInput gUpdatePathingFailsafe Number Background%GuiColorLGrey% cBlack, %pathingFailsafeTime%

DrawHelpDonate()

stopBench("Failsafes",4)

if (hasBiomesPlugin) {
    Gui, Tab, Biomes

    Gui, Add, Picture, x14 y80 w574 h590 vIMAGE_HANDLE_PNG_BIOM_TAB ;, %PNG_BIOM_TAB%

    Gui, Font, s9 %GuiColorText% Normal, Segoe UI
    Gui, Add, Text, x50 y299 w500 h20 BackgroundTrans %GuiColorDefault%, Choose which biomes are sent to Discord:

    Gui, Font, s11 %GuiColorText% Bold, Segoe UI
    Gui, Add, CheckBox, x50 y320 w140 h25 vBiomeWindy gSaveBiomeToggles Checked1 %GuiColorText%, Windy
    Gui, Add, CheckBox, x50 y350 w140 h25 vBiomeSnowy gSaveBiomeToggles Checked1 %GuiColorText%, Snowy
    Gui, Add, CheckBox, x50 y380 w140 h25 vBiomeRainy gSaveBiomeToggles Checked1 %GuiColorText%, Rainy
    Gui, Add, CheckBox, x50 y410 w140 h25 vBiomeHeaven gSaveBiomeToggles Checked1 %GuiColorText%, Heaven

    Gui, Add, CheckBox, x250 y320 w140 h25 vBiomeHell gSaveBiomeToggles Checked1 %GuiColorText%, Hell
    Gui, Add, CheckBox, x250 y350 w140 h25 vBiomeStarfall gSaveBiomeToggles Checked1 %GuiColorText%, Starfall
    Gui, Add, CheckBox, x250 y380 w140 h25 vBiomeCorruption gSaveBiomeToggles Checked1 %GuiColorText%, Corruption
    Gui, Add, CheckBox, x250 y410 w140 h25 vBiomeAurora gSaveBiomeToggles Checked1 %GuiColorText%, Aurora

    Gui, Add, CheckBox, x420 y380 w140 h25 vBiomeNormal gSaveBiomeToggles Checked1 %GuiColorText%, Normal
    Gui, Add, CheckBox, x420 y320 w140 h25 vBiomeSandStorm gSaveBiomeToggles Checked1 %GuiColorText%, Sand Storm
    Gui, Add, CheckBox, x420 y350 w140 h25 vBiomeNull gSaveBiomeToggles Checked1 %GuiColorText%, Null

    Gui, Font, s14 %GuiColorText% Bold
    Gui, Add, Text, x45 y445 %GuiColorGlitch%, Glitched
    Gui, Add, Text, x+2 y445, ,
    Gui, Add, Text, x+8 y445 %GuiColorDreamscape%, Dreamspace
    Gui, Add, Text, x+8 y445, and
    Gui, Add, Text, x+8 y445 %GuiColorCyberspace%, Cyberspace
    Gui, Add, Text, x+8 y445, are always on.

    Gui, Font, s10 %GuiColorText% Bold
    Gui, Add, Text, x50 y155 w200 h25 BackgroundTrans, Private Server Link:
    Gui, Add, Edit, x50 y185 w500 h25 vBiomesPrivateServerInput gUpdateBiomesPrivateServer Background%GuiColorLGrey% cBlack, %biomesPrivateServerLink%
    Gui, Font, s8 %GuiColorDefault% Normal
    Gui, Add, Text, x50 y215 w500 h15 BackgroundTrans, Paste your Roblox private server link here for biome notifications.

    Gui, Font, s10 %GuiColorText% Bold
    Gui, Add, Button, x425 y490 w115 h40 gOpenPluginsFolder, Open Plugins Folder

    DrawHelpDonate()
}
stopBench("Biomes",5)

if (hasCrafterPlugin) {
    Gui, Tab, Crafter

    Gui, Add, Picture, x14 y80 w574 h590 vIMAGE_HANDLE_PNG_CRAF_TAB ;, %PNG_CRAF_TAB%

    Gui, Font, s11 %GuiColorText% Bold, Segoe UI
    Gui, Add, Text, x45 y135 w200 h25 BackgroundTrans, example text:
    Gui, Font, s10 %GuiColorText% Bold
    Gui, Add, Button, x250 y135 w80 h25 gToggleCrafter vCrafterBtn, Toggle
    Gui, Font, s10 %GuiColorDefault% Bold, Segoe UI
    Gui, Add, Text, x340 y140 w60 h25 vCrafterStatus BackgroundTrans +%GuiColorRed%, OFF

    Gui, Font, s9 %GuiColorText% Normal, Segoe UI
    Gui, Add, Text, x45 y185 w500 h60 BackgroundTrans %GuiColorDefault%, example text

    Gui, Font, s10 %GuiColorText% Bold
    Gui, Add, Button, x425 y505 w115 h40 gOpenPluginsFolder, Open Plugins Folder

    DrawHelpDonate()
}
stopBench("Crafter",6)

Gui, Tab, Webhook

Gui, Add, Picture, x14 y80 w574 h590 vIMAGE_HANDLE_PNG_WEBH_TAB ;, %PNG_WEBH_TAB%

Gui, Font, s10 %GuiColorText% Normal Bold
Gui, Add, Text, x50 y125 w200 h25 BackgroundTrans, Discord Webhook URL:
Gui, Add, Edit, x50 y150 w500 h25 vWebhookInput gUpdateWebhook Background%GuiColorLGrey% cBlack, %webhookURL%
Gui, Font, s8 %GuiColorDefault% Normal
Gui, Add, Text, x50 y180 w500 h15 BackgroundTrans, Paste your Discord webhook URL here to be notified of actions happening in real time.

Gui, Font, s10 %GuiColorText% Normal
Gui, Add, Text, x60 y246 w500 h40 BackgroundTrans %GuiColorDefault%, When toggled, this sends a message when a failsafe triggers.
Gui, Add, Text, x60 y316 w500 h40 BackgroundTrans %GuiColorDefault%, When toggled, this sends a message when the macro paths to auto-sell.
Gui, Add, Text, x60 y386 w500 h40 BackgroundTrans %GuiColorDefault%, When toggled, this sends a message when items are used (eg. Strange Controller, Biome Randomizer).

Gui, Font, s10 %GuiColorText% Bold
Gui, Add, Button, x60 y216 w80 h25 gToggleFailsafeWebhook vFailsafeWebhookBtn, Toggle
Gui, Add, Text, x150 y220 w60 h25 vfailsafeWebhookStatus BackgroundTrans +%GuiColorRed%, OFF
Gui, Add, Button, x60 y286 w80 h25 gTogglePathingWebhook vPathingWebhookBtn, Toggle
Gui, Add, Text, x150 y290 w60 h25 vpathingWebhookStatus BackgroundTrans +%GuiColorRed%, OFF
Gui, Add, Button, x60 y356 w80 h25 gToggleItemWebhook vItemWebhookBtn, Toggle
Gui, Add, Text, x150 y360 w60 h25 vitemWebhookStatus BackgroundTrans +%GuiColorRed%, OFF

DrawHelpDonate()

stopBench("Webhook",7)

if (hasSnowmanPlugin) {
    Gui, Tab, Snowman
    Gui, Add, Picture, x14 y80 w574 h590 vIMAGE_HANDLE_PNG_SNOW_TAB ;, %PNG_SNOW_TAB%

    Gui, Font, s10 %GuiColorDefault% Normal
    Gui, Add, Text, x60 y190 w500 h50 BackgroundTrans, When toggled, The macro will automatically collect snowflakes every 2 hours and 5 minutes from the snowman located near Lime.
    Gui, Add, Text, x45 y340 w520 h50 BackgroundTrans, Pathing modes and Resolutions are automatically detected. And will work as normal for this plugin depending on what you have selected.
    Gui, Add, Text, x60 y270 w520 h50 BackgroundTrans, When toggled, you will recieve a webhook message every Snowman Pathing Loop.

    Gui, Font, s11 %GuiColorDefault% Normal
    Gui, Add, Text, x72 y385 w520 h30 BackgroundTrans, Make sure you have claimed your Snowflakes before running this script.

    Gui, Font, s10 %GuiColorText% Bold
    Gui, Add, Button, x60 y160 w80 h25 gToggleSnowmanPathing vSnowmanPathingBtn, Toggle

    Gui, Add, Button, x60 y240 w80 h25 gToggleSnowmanPathingWebhook vSnowmanPathingWebhookBtn, Toggle

    Gui, Font, s10 %GuiColorText% Normal Bold
    if (snowmanPathing) {
        Gui, Add, Text, x150 y165 w40 h25 vSnowmanPathingStatus BackgroundTrans %GuiColorLGreen%, ON
    } else {
        Gui, Add, Text, x150 y165 w40 h25 vSnowmanPathingStatus BackgroundTrans %GuiColorRed%, OFF
    }

    if (snowmanPathingWebhook) {
        Gui, Add, Text, x150 y245 w40 h25 vSnowmanPathingWebhookStatus BackgroundTrans %GuiColorLGreen%, ON
    } else {
        Gui, Add, Text, x150 y245 w40 h25 vSnowmanPathingWebhookStatus BackgroundTrans %GuiColorRed%, OFF
    }
    DrawHelpDonate()
}

stopBench("Snowman",8)

Gui, Tab, Credits
Gui, Add, Picture, x14 y80 w574 h590 vIMAGE_HANDLE_PNG_CRED_TAB ;, %PNG_CRED_TAB%
Gui, Font, s10 %GuiColorText% Normal
loop % Devs.Count()
{
    yFULL_OFFSET := 65 * (A_INDEX - 1)
    yoff1 := 130 + yFULL_OFFSET
    yoff2 := 135 + yFULL_OFFSET
    yoff3 := 155 + yFULL_OFFSET
    yoff4 := 170 + yFULL_OFFSET
    dev_img     := dev%A_INDEX%_img
    dev_name    := dev%A_INDEX%_name
    dev_role    := dev%A_INDEX%_role
    dev_discord := dev%A_INDEX%_discord
    Gui, Font, s11 %GuiColorText% Normal Bold
    Gui, Add, Picture, x50 y%yoff1% w50 h50 vIMAGE_HANDLE_DEV_IMG_%A_Index% ;, %dev_img%

    Gui, Add, Text, x110 y%yoff2% w200 h20 BackgroundTrans %GuiLinkColor% gDev%A_Index%NameClick, %dev_name%

    Gui, Font, s9 %GuiColorDefault% Normal
    Gui, Add, Text, x110 y%yoff3% w300 h15 BackgroundTrans, %dev_role%
    Gui, Font, s9 %GuiColorDefault% Normal Underline
    Gui, Add, Text, x110 y%yoff4% w300 h15 BackgroundTrans %GuiLinkColor% gDev%A_Index%LinkClick, %dev_discord%
}

Gui, Font, s10 %GuiColorText% Normal Bold
Gui, Add, Text, x50 y345 w200 h20 BackgroundTrans, Thank you to our donators!
Gui, Font, s9 %GuiColorDefault% Normal
Gui, Add, Edit, x50 y370 w480 h125 vDonatorsList -Wrap +ReadOnly +VScroll -WantReturn -E0x200 Background%GuiColorDonatorBG% %GuiColorDefault%, LOADING....

Gui, Font, s8 %GuiColorDefault% Normal
Gui, Add, Text, x50 y518 w500 h15 BackgroundTrans, fishSol v%version% - %randomMessage%

DrawHelpDonate()

Gui, Show, w600 h670, fishSol v%version%

stopBench("Credits", 9)

LoadBiomeToggles()

DllCall("QueryPerformanceCounter", "Int64*", TIMER_DONE)

switch res
{
    case "1080p" :
        GuiControl, Choose, Resolution, 1
    case "1440p" : 
        GuiControl, Choose, Resolution, 2
    case "1366x768" : 
        GuiControl, Choose, Resolution, 3
    default :
        GuiControl, Choose, Resolution, 1
        res := "1080p"
}

checkToggle(byref toggle, byref status)
{
    global
    if (toggle) {
        GuiControl,, %status%, ON
        GuiControl, +%GuiColorLGreen%, %status%
    } else {
        GuiControl,, %status%, OFF
        GuiControl, +%GuiColorRed%, %status%
    }
}

checkToggle(sellAllToggle, "SellAllStatus")
checkToggle(advancedFishingDetection, "AdvancedFishingDetectionStatus")

switch pathingMode
{
    case "Vip Pathing" : 
        GuiControl, Choose, PathingMode, 1
    case "Non Vip Pathing" : 
        GuiControl, Choose, PathingMode, 2
    case "Abyssal Pathing" : 
        GuiControl, Choose, PathingMode, 3
    default :
        GuiControl, Choose, PathingMode, 1
        pathingMode := "Vip Pathing"
}

checkToggle(azertyPathing, "AzertyPathingStatus")
checkToggle(autoUnequip, "AutoUnequipStatus")
checkToggle(autoCloseChat, "AutoCloseChatStatus")
checkToggle(strangeController, "StrangeControllerStatus")
checkToggle(biomeRandomizer, "BiomeRandomizerStatus")
checkToggle(failsafeWebhook, "failsafeWebhookStatus")
checkToggle(pathingWebhook, "pathingWebhookStatus")
checkToggle(itemWebhook, "itemWebhookStatus")

if (hasCrafterPlugin) {
    checkToggle(crafterToggle, "CrafterStatus")
    autoCrafterDetection := crafterToggle
    if (crafterToggle) {
        autoCrafterLastCheck := A_TickCount
    }
}

if (hasSnowmanPlugin) {
    checkToggle(snowmanPathing, "SnowmanPathingStatus")
    GuiControl,, SnowmanIntervalInput, % (snowmanInterval / 60000)
}

stopBench("TOGGLE CHECKS",10)
SetTimer, KILL_TOOLTIP, -30000

;load donations list from http link asnyc
SetTimer, donoList, -0

;load images from file asnyc
IMAGE_LOAD := Func("IMAGE_LOAD")
SetTimer, %IMAGE_LOAD%, -0

;print timer stuff to screen
calc_time := Func("calc_time")
SetTimer, %calc_time%, -350

SetBatchLines, %STANDARD_SPEED% ;set speed back to normal shouldn't be needed
return                          ;as ahk resets line speed for each thread

GuiClose:
    SetTimer, %INI_WRITE_FILE_FUNC%, Off
    INI_WRITE_FILE()
    if (biomeDetectionRunning) {
        DetectHiddenWindows, On
        SetTitleMatchMode, 2

        target := "biomes.ahk"
        WinGet, id, ID, %target% ahk_class AutoHotkey
        if (id) {
            WinClose, ahk_id %id%
        }
        biomeDetectionRunning := false
    }
    try SendWebhook(":red_circle: Macro Stopped.", "14495300")
ExitApp

toggle := false
firstLoop := true
startTick := 0
cycleCount := 0

TabChange:
return

UpdateLoopCount:
    Gui, Submit, nohide
    maxLoopCount := max(MaxLoopInput, 1)
    INI_WRITE( maxLoopCount, "Macro", "maxLoopCount")
    fishingLoopCount := max(FishingLoopInput, 1)
    INI_WRITE( fishingLoopCount, "Macro", "fishingLoopCount")
return

ToggleSellAll:
    sellAllToggle := !sellAllToggle
    checkToggle(sellAllToggle, "SellAllStatus")
    INI_WRITE( (sellAllToggle ? "true" : "false" ), "Macro", "sellAllToggle")
return

ToggleAdvancedFishingDetection:
    advancedFishingDetection := !advancedFishingDetection
    checkToggle(advancedFishingDetection, "AdvancedFishingDetectionStatus")
    INI_WRITE( (advancedFishingDetection ? "true" : "false" ), "Macro", "advancedFishingDetection")
return

ToggleAzertyPathing:
    azertyPathing := !azertyPathing
    checkToggle(azertyPathing, "AzertyPathingStatus")
    INI_WRITE( (azertyPathing ? "true" : "false" ), "Macro", "azertyPathing")
return

ToggleAutoUnequip:
    autoUnequip := !autoUnequip
    checkToggle(autoUnequip, "AutoUnequipStatus")
    INI_WRITE( (autoUnequip ? "true" : "false" ), "Macro", "autoUnequip")
return

ToggleAutoCloseChat:
    autoCloseChat := !autoCloseChat
    checkToggle(autoCloseChat, "AutoCloseChatStatus")
    INI_WRITE( (autoCloseChat ? "true" : "false" ), "Macro", "autoCloseChat")
return

ToggleStrangeController:
    strangeController := !strangeController
    checkToggle(strangeController, "StrangeControllerStatus")
    INI_WRITE( (strangeController ? "true" : "false" ), "Macro", "strangeController")
return

ToggleBiomeRandomizer:
    biomeRandomizer := !biomeRandomizer
    checkToggle(biomeRandomizer, "BiomeRandomizerStatus")
    INI_WRITE( (biomeRandomizer ? "true" : "false" ), "Macro", "biomeRandomizer")
return

ToggleFailsafeWebhook:
    failsafeWebhook := !failsafeWebhook
    checkToggle(failsafeWebhook, "failsafeWebhookStatus")
    INI_WRITE( (failsafeWebhook ? "true" : "false" ), "Macro", "failsafeWebhook")
return

TogglePathingWebhook:
    pathingWebhook := !pathingWebhook
    checkToggle(pathingWebhook, "pathingWebhookStatus")
    INI_WRITE( (pathingWebhook ? "true" : "false" ), "Macro", "pathingWebhook")
return

ToggleItemWebhook:
    itemWebhook := !itemWebhook
    checkToggle(itemWebhook, "itemWebhookStatus")
    INI_WRITE( (itemWebhook ? "true" : "false" ), "Macro", "itemWebhook")
return

ToggleCrafter:
    crafterToggle := !crafterToggle
    checkToggle(crafterToggle, "CrafterStatus")
    INI_WRITE( (crafterToggle ? "true" : "false" ), "Macro", "crafterToggle")
    INI_WRITE( (crafterToggle ? "true" : "false" ), "Macro", "autoCrafterDetection")
    if (crafterToggle)
    {
        autoCrafterDetection := true
        autoCrafterLastCheck := A_TickCount
    }
return

ToggleSnowmanPathing:
    snowmanPathing := !snowmanPathing
    checkToggle(snowmanPathing, "SnowmanPathingStatus")
    INI_WRITE( (snowmanPathing ? "true" : "false" ), "Macro", "snowmanPathing")

    checkToggle(autoCrafter, "AutoCrafterStatus")
    INI_WRITE( (autoCrafter ? "true" : "false" ), "Macro", "autoCrafter")

    checkToggle(autoCrafterWebhook, "AutoCrafterWebhookStatus")
    INI_WRITE( (autoCrafterWebhook ? "true" : "false" ), "Macro", "autoCrafterWebhook")
return

ToggleSnowmanPathingWebhook:
    snowmanPathingWebhook := !snowmanPathingWebhook
    checkToggle(snowmanPathingWebhook, "SnowmanPathingWebhookStatus")
    INI_WRITE( (snowmanPathingWebhook ? "true" : "false" ), "Macro", "snowmanPathingWebhook")
return

ToggleAutoCrafter:
    autoCrafter := !autoCrafter
    checkToggle(autoCrafter, "AutoCrafterStatus")
    INI_WRITE( (autoCrafter ? "true" : "false" ), "Macro", "autoCrafter")
return

UpdateAutoCrafterInterval:
    Gui, Submit, NoHide
    newInterval := AutoCrafterInterval * 60000
    autoCrafterInterval := max(newInterval, 1)
    INI_WRITE( autoCrafterInterval, "Macro", "autoCrafterInterval")
return

ToggleAutoCrafterWebhook:
    autoCrafterWebhook := !autoCrafterWebhook
    checkToggle(autoCrafterWebhook, "AutoCrafterWebhookStatus")
    INI_WRITE( (autoCrafterWebhook ? "true" : "false" ), "Macro", "autoCrafterWebhook")
return

RunAutoCrafter() {
    MouseGetPos, originalX, originalY
    global res
    switch res
    {
        case "1080p" :
            RunAutoCrafter1080p()
        case "1440p" :
            RunAutoCrafter1440p()
        case "1366x768" :
            RunAutoCrafter768p()
        default:
            RunAutoCrafter1080p()
    }

    MouseMove, %originalX%, %originalY%, 0
}

return_to_spawn()
{
    Send, {Esc}
    Sleep, 650
    Send, R
    Sleep, 650
    Send, {Enter}
    Sleep, 2600
}

release_held_keys()
{
    Send, {space Up}
    Send, {w Up}
    Send, {a Up}
    Send, {s Up}
    Send, {d Up}
    Send, {e Up}
}

; 1080p Auto Crafter
RunAutoCrafter1080p() {
    return_to_spawn()

    MouseMove, 100, 400, 3
    Sleep, 200
    Click, Left
    Sleep, 200

    MouseMove, 500, 300, 3
    Sleep, 200
    Click, Left
    Sleep, 500

    Click, WheelUp 80
    Sleep, 500
    Click, WheelDown 35
    Sleep, 300

    Send, {s Down}
    Send, {a Down}
    Sleep, 2000
    Send, {a Up}
    Sleep, 1500
    Send, {d Down}
    Sleep, 1000
    Send, {d Up}
    Sleep, 500

    Send, {a Down}
    Send, {w Down}
    Sleep, 500
    Send, {a Up}
    Send, {w Up}
    Sleep, 100
    Send, {Space Down}
    Send, {s Down}
    Sleep, 100
    Send, {Space Up}
    Sleep, 500
    Send, {s Up}
    Sleep, 100
}

; 1440p Auto Crafter
RunAutoCrafter1440p() {
    release_held_keys()
    reset := false
    Sleep 300

    return_to_spawn()
    MouseMove, 52, 621, 3
    sleep 300
    Click, Left
    sleep 300
    MouseMove, 525, 158, 3
    sleep 300
    Click, Left
    sleep 300
    Click, WheelUp 80
    sleep 500
    Click, WheelDown 90
    sleep 300

    ; start pathing to stella
    Send, {s down}
    Send, {a down}
    sleep 2660
    Send, {a up}
    Sleep, 2500
    Send, {d down}
    Sleep, 1100
    Send, {d up}
    Send, {s up}
    sleep 10
    Send, {a down}
    Send, {w down}
    Sleep, 300
    Send, {a up}
    Send, {w up}
    sleep 100
    Send, {Space down}
    Send, {s down}
    Sleep, 100
    Send, {Space up}
    Sleep, 500
    Send, {s up}
    sleep 10
    Send, {a down}
    Send, {s down}
    Sleep, 400
    Send, {a up}
    Sleep, 6000
    Send, {s up}
    Send, {a down}
    Sleep, 1500
    Send, {a up}
    Send, {s down}
    Sleep, 1250
    Send, {a down}
    Sleep, 200
    Send, {a up}
    Sleep, 1000
    Send, {a down}
    Send, {Space down}
    Sleep, 100
    Send, {Space up}
    Sleep, 750
    Send, {Space down}
    Sleep, 100
    Send, {Space up}
    Sleep, 700
    Send, {s up}
    Sleep, 2500
    Send, {a up}
    Send, {s down}
    Sleep, 1300
    Send, {s up}
    sleep 500

    ; portal detection
    screenColor := 0
    success := false
    loopCount := 0
    Loop {
        sleep 100
        if (loopCount > 40) {
            break
        }
        PixelGetColor, screenColor, 2509, 1389, RGB
        if (screenColor = 0x000000) {
            success := true
        }
        loopCount++
    }
    if (success) {
        sleep, 500
    } else {
        reset := true
    }

    ; potion crafting
    sleep 750
    Send, {a down}
    Sleep, 1000
    Send, {a up}
    Sleep, 300
    Send, {f down}
    Sleep, 300
    Send, {f up}
    Sleep, 125
    Clipboard := "Heavenly Potion"
    sleep 125
    MouseMove, 1271, 448, 3
    Sleep, 250
    MouseClick, Left
    Sleep, 250
    Send, ^v
    Sleep, 250
    MouseMove, 1530, 552, 3
    Sleep, 250
    Click, WheelUp 80
    sleep 250
    MouseClick, Left
    Sleep, 250
    MouseMove, 769, 769, 3
    Sleep, 250
    MouseClick, Left
    Sleep, 300
    MouseMove, 954, 840, 3
    Sleep, 250
    MouseClick, Left
    Sleep, 200
    MouseClick, Left
    sleep 125
    Clipboard := "250"
    sleep 125
    Send, ^v
    Sleep, 250
    MouseMove, 1064, 839, 3
    Sleep, 250
    MouseClick, Left
    Sleep, 200
    MouseClick, Left
    Sleep, 250
    MouseMove, 1064, 910, 3
    sleep 250
    Mouseclick, Left
    sleep 250
    Mouseclick, Left
    sleep 250
    MouseMove, 1064, 984, 3
    sleep 250
    MouseClick, Left
    sleep 250
    MouseMove, 1885, 396, 3
    Sleep, 250
    MouseClick, Left
    Sleep, 300
}

; 768p Auto Crafter
RunAutoCrafter768p() {
    return_to_spawn()

    MouseMove, 80, 300, 3
    Sleep, 200
    Click, Left
    Sleep, 200

    MouseMove, 400, 250, 3
    Sleep, 200
    Click, Left
    Sleep, 500

    Click, WheelUp 80
    Sleep, 500
    Click, WheelDown 20
    Sleep, 300

    Send, {s Down}
    Send, {a Down}
    Sleep, 1800
    Send, {a Up}
    Sleep, 2000
    Send, {d Down}
    Sleep, 800
    Send, {d Up}
    Sleep, 400

    Send, {a Down}
    Send, {w Down}
    Sleep, 200
    Send, {a Up}
    Send, {w Up}
    Sleep, 100
    Send, {Space Down}
    Send, {s Down}
    Sleep, 100
    Send, {Space Up}
    Sleep, 400
    Send, {s Up}
    Sleep, 100
}

RunSnowmanPathing() {
    if (pathingMode = "Non Vip Pathing") {
        RunSnowmanPathingNonVip()
    } else if (pathingMode = "Abyssal Pathing") {
        RunSnowmanPathingAbyssal()
    } else {
        RunSnowmanPathingVip()
    }
}

; VIP Snowman Pathing
RunSnowmanPathingVip() {
    MouseGetPos, originalX, originalY
    global res

    if (res = "1080p") {
        MouseMove, 47, 467, 3
        sleep 220
        Click, Left
        sleep 220
        MouseMove, 382, 126, 3
        sleep 220
        Click, Left
        sleep 220
        Click, WheelUp 80
        sleep 500
        Click, WheelDown 45
        sleep 300
    }
    else if (res = "1440p") {
        MouseMove, 52, 621, 3
        sleep 220
        Click, Left
        sleep 220
        MouseMove, 525, 158, 3
        sleep 220
        Click, Left
        sleep 220
		Click, WheelUp 80
		sleep 500
		Click, WheelDown 35
		sleep 300
    }
    else if (res = "1366x768") {
        MouseMove, 26, 325, 3
        sleep 220
        Click, Left
        sleep 220
        MouseMove, 273, 106, 3
        sleep 220
        Click, Left
        sleep 220
		Click, WheelUp 80
		sleep 500
		Click, WheelDown 90
		sleep 300
    }

    Send, {a Down}
    sleep 1000
    Send, {s Down}
    sleep 2700
    Send, {a Up}
    sleep 2800
    Send, {s Up}
    sleep 300
    Send, {a Down}
    sleep 800
    Send, {a Up}
    sleep 300
    Send, {d Down}
    sleep 200
    Send, {d Up}
    sleep 200
    Send, {w Down}
    sleep 200
    Send, {w Up}
    sleep 300
    Send, {space Down}
    sleep 50
    Send, {a Down}
    sleep 50
    Send, {space Up}
    sleep 2200
    Send, {a Up}
    sleep 300
    Send, {e Down}
    sleep 50
    Send, {e Up}
    sleep 200
    Send, {e Down}
    sleep 50
    Send, {e Up}

    release_held_keys()

    MouseMove, %originalX%, %originalY%, 0
}

; Non-VIP Snowman Pathing
RunSnowmanPathingNonVip() {
    MouseGetPos, originalX, originalY
    global res

    if (res = "1080p") {
        MouseMove, 47, 467, 3
        sleep 220
        Click, Left
        sleep 220
        MouseMove, 382, 126, 3
        sleep 220
        Click, Left
        sleep 220
        Click, WheelUp 80
        sleep 500
        Click, WheelDown 45
        sleep 300
    }
    else if (res = "1440p") {
        MouseMove, 52, 621, 3
        sleep 220
        Click, Left
        sleep 220
        MouseMove, 525, 158, 3
        sleep 220
        Click, Left
        sleep 220
		Click, WheelUp 80
		sleep 500
		Click, WheelDown 35
		sleep 300
    }
    else if (res = "1366x768") {
        MouseMove, 26, 325, 3
        sleep 220
        Click, Left
        sleep 220
        MouseMove, 273, 106, 3
        sleep 220
        Click, Left
        sleep 220
		Click, WheelUp 80
		sleep 500
		Click, WheelDown 90
		sleep 300
    }

    Send, {a Down}
    sleep 1500
    Send, {s Down}
    sleep 3400
    Send, {a Up}
    sleep 3400
    Send, {s Up}
    sleep 300
    Send, {a Down}
    sleep 800
    Send, {a Up}
    sleep 300
    Send, {d Down}
    sleep 300
    Send, {d Up}
    sleep 200
    Send, {w Down}
    sleep 200
    Send, {w Up}
    sleep 300
    Send, {a Down}
    sleep 50
    Send, {space Down}
    sleep 50
    Send, {space Up}
    sleep 2600
    Send, {a Up}
    sleep 300
    Send, {e Down}
    sleep 50
    Send, {e Up}
    sleep 200
    Send, {e Down}
    sleep 50
    Send, {e Up}

    release_held_keys()

    MouseMove, %originalX%, %originalY%, 0
}

; Abyssal Snowman Pathing
RunSnowmanPathingAbyssal() {
    MouseGetPos, originalX, originalY
    global res

    if (res = "1080p") {
        MouseMove, 47, 467, 3
        sleep 220
        Click, Left
        sleep 220
        MouseMove, 382, 126, 3
        sleep 220
        Click, Left
        sleep 220
        Click, WheelUp 80
        sleep 500
        Click, WheelDown 45
        sleep 300
        MouseMove, 30, 406, 3
        sleep 200
        MouseClick, Left
        sleep 200
        MouseMove, 947, 335, 3
        sleep 200
        MouseClick, Left
        sleep 100
        MouseMove, 1102, 367, 3
        sleep 100
        MouseClick, Left
        sleep 100
        Clipboard := "Abyssal Hunter"
        sleep 100
        Send, ^v
        sleep 200
        MouseMove, 819, 434, 3
        sleep 200
        Click, WheelUp 100
        sleep 200
        MouseClick, Left
        sleep 200

        ErrorLevel := 0
        PixelSearch, px, py, 576, 626, 666, 645, 0xfc7f98, 3, Fast RGB
        if (ErrorLevel != 0) {
            MouseMove, 623, 634, 3
            sleep 200
            MouseClick, Left
        }

        sleep 200
        MouseMove, 1412, 296, 3
        sleep 200
        MouseClick, Left
        sleep 200
    }
    else if (res = "1440p") {
        MouseMove, 52, 621, 3
        sleep 220
        Click, Left
        sleep 220
        MouseMove, 525, 158, 3
        sleep 220
        Click, Left
        sleep 220
		Click, WheelUp 80
		sleep 500
		Click, WheelDown 35
		sleep 300
        MouseMove, 40, 541, 3
        sleep 200
        MouseClick, Left
        sleep 200
        MouseMove, 1262, 447, 3
        sleep 200
        MouseClick, Left
        sleep 100
        MouseMove, 1469, 489, 3
        sleep 100
        MouseClick, Left
        sleep 100
        ClipBoard := "Abyssal Hunter"
        sleep 100
        Send, ^v
        sleep 200
        MouseMove, 1092, 579, 3
        sleep 200
        Click, WheelUp 100
        sleep 200
        MouseClick, Left
        sleep 200

        ErrorLevel := 0
        PixelSearch, px, py, 768, 835, 888, 860, 0xfc7f98, 3, Fast RGB
        if (ErrorLevel != 0) {
            MouseMove, 830, 845, 3
            sleep 200
            MouseClick, Left
        }

        sleep 200
        MouseMove, 1883, 395, 3
        sleep 200
        MouseClick, Left
        sleep 200
    }
    else if (res = "1366x768") {
        MouseMove, 26, 325, 3
        sleep 220
        Click, Left
        sleep 220
        MouseMove, 273, 106, 3
        sleep 220
        Click, Left
        sleep 220
		Click, WheelUp 80
		sleep 500
		Click, WheelDown 90
		sleep 300
        MouseMove, 21, 289, 3
        sleep 200
        MouseClick, Left
        sleep 200
        MouseMove, 675, 239, 3
        sleep 200
        MouseClick, Left
        sleep 100
        MouseMove, 786, 261, 3
        sleep 100
        MouseClick, Left
        sleep 100
        Clipboard := "Abyssal Hunter"
        sleep 100
        Send, ^v
        sleep 200
        MouseMove, 584, 310, 3
        sleep 200
        Click, WheelUp 100
        sleep 200
        MouseClick, Left
        sleep 200

        ErrorLevel := 0
        PixelSearch, px, py, 411, 446, 475, 460, 0xed7389, 3, Fast RGB
        if (ErrorLevel != 0) {
            MouseMove, 444, 452, 3
            sleep 200
            MouseClick, Left
        }

        sleep 200
        MouseMove, 1007, 211, 3
        sleep 200
        MouseClick, Left
        sleep 200
    }

    Send, {a Down}
    sleep 1000
    Send, {s Down}
    sleep 1400
    Send, {a Up}
    sleep 2100
    Send, {s Up}
    sleep 300
    Send, {a Down}
    sleep 600
    Send, {a Up}
    sleep 300
    Send, {d Down}
    sleep 150
    Send, {d Up}
    sleep 200
    Send, {w Down}
    sleep 150
    Send, {w Up}
    sleep 300
    Send, {space Down}
    sleep 50
    Send, {a Down}
    sleep 50
    Send, {space Up}
    sleep 1500
    Send, {a Up}
    sleep 300
    Send, {e Down}
    sleep 50
    Send, {e Up}
    sleep 200
    Send, {e Down}
    sleep 50
    Send, {e Up}

    release_held_keys()

    MouseMove, %originalX%, %originalY%, 0
}

RunSnowmanPathingNow:
    global toggle, restartPathing, firstLoop, snowmanPathingLastRun, snowmanPathingInterval, snowmanPathingWebhook, res, pathingMode

    return_to_spawn()

    release_held_keys()

    Suspend, Off

    if (snowmanPathingWebhook) {
        try SendWebhook(":snowman: Starting snowman pathing (" . pathingMode . " at " . res . ")", "16636040")
    }

    RunSnowmanPathing()

    snowmanPathingLastRun := A_TickCount - snowmanPathingInterval + 60000

    toggle := true
    restartPathing := true
    firstLoop := true

    switch res
    {
        case "1080p" : 
            Gosub, DoMouseMove
        case "1080p" : 
            Gosub, DoMouseMove2
        case "1080p" : 
            Gosub, DoMouseMove3
        default :
            Gosub, DoMouseMove
    }

    if (savedPathingState) {
        Suspend, On
    }
return

UpdatePrivateServer:
    Gui, Submit, nohide
    privateServerLink := PrivateServerInput
    INI_WRITE( privateServerLink, "Macro", "privateServerLink")
return

UpdateFishingFailsafe:
    Gui, Submit, nohide
    fishingFailsafeTime := max(FishingFailsafeInput, 1)
    INI_WRITE( fishingFailsafeTime, "Macro", "fishingFailsafeTime")
return

UpdatePathingFailsafe:
    Gui, Submit, nohide
    pathingFailsafeTime := max(PathingFailsafeInput, 1)
    INI_WRITE( pathingFailsafeTime, "Macro", "pathingFailsafeTime")
return

UpdateAutoRejoinFailsafe:
    Gui, Submit, nohide
    autoRejoinFailsafeTime := max(AutoRejoinFailsafeInput, 1)
    INI_WRITE( autoRejoinFailsafeTime, "Macro", "autoRejoinFailsafeTime")
return

UpdateAdvancedThreshold:
    Gui, Submit, nohide
    advancedFishingThreshold := max(min(AdvancedThresholdInput, 40), 0)
    INI_WRITE( advancedFishingThreshold, "Macro", "advancedFishingThreshold")
return

UpdateWebhook:
    Gui, Submit, nohide
    webhookURL := WebhookInput
    INI_WRITE( webhookURL, "Macro", "webhookURL")
return

UpdateBiomesPrivateServer:
    Gui, Submit, nohide
    biomesPrivateServerLink := BiomesPrivateServerInput
    INI_WRITE( biomesPrivateServerLink, "Biomes", "privateServerLink")
return

LoadBiomeToggles() {
    global
    Ini_Read(temp_BiomeNormal,      "Biomes", "BiomeNormal",      "true")
    Ini_Read(temp_BiomeSandStorm,   "Biomes", "BiomeSandStorm",   "true")
    Ini_Read(temp_BiomeHell,        "Biomes", "BiomeHell",        "true")
    Ini_Read(temp_BiomeStarfall,    "Biomes", "BiomeStarfall",    "true")
    Ini_Read(temp_BiomeCorruption,  "Biomes", "BiomeCorruption",  "true")
    Ini_Read(temp_BiomeWindy,       "Biomes", "BiomeWindy",       "true")
    Ini_Read(temp_BiomeSnowy,       "Biomes", "BiomeSnowy",       "true")
    Ini_Read(temp_BiomeRainy,       "Biomes", "BiomeRainy",       "true")
    Ini_Read(temp_BiomeHeaven,      "Biomes", "BiomeHeaven",      "true")
    Ini_Read(temp_BiomeAurora,      "Biomes", "BiomeAurora",      "true")
    Ini_Read(temp_BiomePumpkinMoon, "Biomes", "BiomePumpkinMoon", "true")
    Ini_Read(temp_BiomeGraveyard,   "Biomes", "BiomeGraveyard",   "true")
    Ini_Read(temp_BiomeBloodRain,   "Biomes", "BiomeBloodRain",   "true")
    Ini_Read(temp_BiomeNull,        "Biomes", "BiomeNull",        "true")

    GuiControl,, BiomeNormal,      % (temp_BiomeNormal      = 1 || temp_BiomeNormal      = "true" ? true : false)
    GuiControl,, BiomeSandStorm,   % (temp_BiomeSandStorm   = 1 || temp_BiomeSandStorm   = "true" ? true : false)
    GuiControl,, BiomeHell,        % (temp_BiomeHell        = 1 || temp_BiomeHell        = "true" ? true : false)
    GuiControl,, BiomeStarfall,    % (temp_BiomeStarfall    = 1 || temp_BiomeStarfall    = "true" ? true : false)
    GuiControl,, BiomeCorruption,  % (temp_BiomeCorruption  = 1 || temp_BiomeCorruption  = "true" ? true : false)
    GuiControl,, BiomeWindy,       % (temp_BiomeWindy       = 1 || temp_BiomeWindy       = "true" ? true : false)
    GuiControl,, BiomeSnowy,       % (temp_BiomeSnowy       = 1 || temp_BiomeSnowy       = "true" ? true : false)
    GuiControl,, BiomeRainy,       % (temp_BiomeRainy       = 1 || temp_BiomeRainy       = "true" ? true : false)
    GuiControl,, BiomeHeaven,      % (temp_BiomeHeaven      = 1 || temp_BiomeHeaven      = "true" ? true : false)
    GuiControl,, BiomeAurora,      % (temp_BiomeAurora      = 1 || temp_BiomeAurora      = "true" ? true : false)
    GuiControl,, BiomePumpkinMoon, % (temp_BiomePumpkinMoon = 1 || temp_BiomePumpkinMoon = "true" ? true : false)
    GuiControl,, BiomeGraveyard,   % (temp_BiomeGraveyard   = 1 || temp_BiomeGraveyard   = "true" ? true : false)
    GuiControl,, BiomeBloodRain,   % (temp_BiomeBloodRain   = 1 || temp_BiomeBloodRain   = "true" ? true : false)
    GuiControl,, BiomeNull,        % (temp_BiomeNull        = 1 || temp_BiomeNull        = "true" ? true : false)
}

SaveBiomeToggles:
    Gui, Submit, NoHide
    Ini_Write(BiomeNormal      = 1 ? "true" : "false", "Biomes", "BiomeNormal"      )
    Ini_Write(BiomeSandStorm   = 1 ? "true" : "false", "Biomes", "BiomeSandStorm"   )
    Ini_Write(BiomeHell        = 1 ? "true" : "false", "Biomes", "BiomeHell"        )
    Ini_Write(BiomeStarfall    = 1 ? "true" : "false", "Biomes", "BiomeStarfall"    )
    Ini_Write(BiomeCorruption  = 1 ? "true" : "false", "Biomes", "BiomeCorruption"  )
    Ini_Write(BiomeWindy       = 1 ? "true" : "false", "Biomes", "BiomeWindy"       )
    Ini_Write(BiomeSnowy       = 1 ? "true" : "false", "Biomes", "BiomeSnowy"       )
    Ini_Write(BiomeRainy       = 1 ? "true" : "false", "Biomes", "BiomeRainy"       )
    Ini_Write(BiomeHeaven      = 1 ? "true" : "false", "Biomes", "BiomeHeaven"      )
    Ini_Write(BiomeAurora      = 1 ? "true" : "false", "Biomes", "BiomeAurora"      )
    Ini_Write(BiomePumpkinMoon = 1 ? "true" : "false", "Biomes", "BiomePumpkinMoon" )
    Ini_Write(BiomeGraveyard   = 1 ? "true" : "false", "Biomes", "BiomeGraveyard"   )
    Ini_Write(BiomeBloodRain   = 1 ? "true" : "false", "Biomes", "BiomeBloodRain"   )
    Ini_Write(BiomeNull        = 1 ? "true" : "false", "Biomes", "BiomeNull"        )
return

; LoadBiomeToggles() {
;     global
;     IniRead, temp_BiomeNormal,      %iniFilePath%, % "Biomes", BiomeNormal,      "true"
;     IniRead, temp_BiomeSandStorm,   %iniFilePath%, % "Biomes", BiomeSandStorm,   "true"
;     IniRead, temp_BiomeHell,        %iniFilePath%, % "Biomes", BiomeHell,        "true"
;     IniRead, temp_BiomeStarfall,    %iniFilePath%, % "Biomes", BiomeStarfall,    "true"
;     IniRead, temp_BiomeCorruption,  %iniFilePath%, % "Biomes", BiomeCorruption,  "true"
;     IniRead, temp_BiomeWindy,       %iniFilePath%, % "Biomes", BiomeWindy,       "true"
;     IniRead, temp_BiomeSnowy,       %iniFilePath%, % "Biomes", BiomeSnowy,       "true"
;     IniRead, temp_BiomeRainy,       %iniFilePath%, % "Biomes", BiomeRainy,       "true"
;     IniRead, temp_BiomeHeaven,      %iniFilePath%, % "Biomes", BiomeHeaven,      "true"
;     IniRead, temp_BiomeAurora,      %iniFilePath%, % "Biomes", BiomeAurora,      "true"
;     IniRead, temp_BiomePumpkinMoon, %iniFilePath%, % "Biomes", BiomePumpkinMoon, "true"
;     IniRead, temp_BiomeGraveyard,   %iniFilePath%, % "Biomes", BiomeGraveyard,   "true"
;     IniRead, temp_BiomeBloodRain,   %iniFilePath%, % "Biomes", BiomeBloodRain,   "true"
;     IniRead, temp_BiomeNull,        %iniFilePath%, % "Biomes", BiomeNull,        "true"

;     GuiControl,, BiomeNormal,      % (temp_BiomeNormal      = 1 || temp_BiomeNormal      = "true" ? true : false)
;     GuiControl,, BiomeSandStorm,   % (temp_BiomeSandStorm   = 1 || temp_BiomeSandStorm   = "true" ? true : false)
;     GuiControl,, BiomeHell,        % (temp_BiomeHell        = 1 || temp_BiomeHell        = "true" ? true : false)
;     GuiControl,, BiomeStarfall,    % (temp_BiomeStarfall    = 1 || temp_BiomeStarfall    = "true" ? true : false)
;     GuiControl,, BiomeCorruption,  % (temp_BiomeCorruption  = 1 || temp_BiomeCorruption  = "true" ? true : false)
;     GuiControl,, BiomeWindy,       % (temp_BiomeWindy       = 1 || temp_BiomeWindy       = "true" ? true : false)
;     GuiControl,, BiomeSnowy,       % (temp_BiomeSnowy       = 1 || temp_BiomeSnowy       = "true" ? true : false)
;     GuiControl,, BiomeRainy,       % (temp_BiomeRainy       = 1 || temp_BiomeRainy       = "true" ? true : false)
;     GuiControl,, BiomeHeaven,      % (temp_BiomeHeaven      = 1 || temp_BiomeHeaven      = "true" ? true : false)
;     GuiControl,, BiomeAurora,      % (temp_BiomeAurora      = 1 || temp_BiomeAurora      = "true" ? true : false)
;     GuiControl,, BiomePumpkinMoon, % (temp_BiomePumpkinMoon = 1 || temp_BiomePumpkinMoon = "true" ? true : false)
;     GuiControl,, BiomeGraveyard,   % (temp_BiomeGraveyard   = 1 || temp_BiomeGraveyard   = "true" ? true : false)
;     GuiControl,, BiomeBloodRain,   % (temp_BiomeBloodRain   = 1 || temp_BiomeBloodRain   = "true" ? true : false)
;     GuiControl,, BiomeNull,        % (temp_BiomeNull        = 1 || temp_BiomeNull        = "true" ? true : false)
; }

; SaveBiomeToggles:
;     Gui, Submit, NoHide
;     IniWrite, % (BiomeNormal      = 1 ? "true" : "false"), %iniFilePath%, % "Biomes", BiomeNormal
;     IniWrite, % (BiomeSandStorm   = 1 ? "true" : "false"), %iniFilePath%, % "Biomes", BiomeSandStorm
;     IniWrite, % (BiomeHell        = 1 ? "true" : "false"), %iniFilePath%, % "Biomes", BiomeHell
;     IniWrite, % (BiomeStarfall    = 1 ? "true" : "false"), %iniFilePath%, % "Biomes", BiomeStarfall
;     IniWrite, % (BiomeCorruption  = 1 ? "true" : "false"), %iniFilePath%, % "Biomes", BiomeCorruption
;     IniWrite, % (BiomeWindy       = 1 ? "true" : "false"), %iniFilePath%, % "Biomes", BiomeWindy
;     IniWrite, % (BiomeSnowy       = 1 ? "true" : "false"), %iniFilePath%, % "Biomes", BiomeSnowy
;     IniWrite, % (BiomeRainy       = 1 ? "true" : "false"), %iniFilePath%, % "Biomes", BiomeRainy
;     IniWrite, % (BiomeHeaven      = 1 ? "true" : "false"), %iniFilePath%, % "Biomes", BiomeHeaven
;     IniWrite, % (BiomeAurora      = 1 ? "true" : "false"), %iniFilePath%, % "Biomes", BiomeAurora
;     IniWrite, % (BiomePumpkinMoon = 1 ? "true" : "false"), %iniFilePath%, % "Biomes", BiomePumpkinMoon
;     IniWrite, % (BiomeGraveyard   = 1 ? "true" : "false"), %iniFilePath%, % "Biomes", BiomeGraveyard
;     IniWrite, % (BiomeBloodRain   = 1 ? "true" : "false"), %iniFilePath%, % "Biomes", BiomeBloodRain
;     IniWrite, % (BiomeNull        = 1 ? "true" : "false"), %iniFilePath%, % "Biomes", BiomeNull
; return

; webhooks!
SendWebhook(title, color := "16777215") {
    global webhookURL
    if (!InStr(webhookURL, "discord")) {
        return
    }
    time := A_NowUTC
    timestamp := SubStr(time,1,4) "-" SubStr(time,5,2) "-" SubStr(time,7,2) "T" SubStr(time,9,2) ":" SubStr(time,11,2) ":" SubStr(time,13,2) ".000Z"

    json := "{"
    . """embeds"": ["
    . "{"
    . "    ""title"": """ title ""","
    . "    ""color"": " color ","
    . "    ""footer"": {""text"": ""fishSol v" . version . """, ""icon_url"": ""https://maxstellar.github.io/fishSol%20icon.png""},"
    . "    ""timestamp"": """ timestamp """"    ; ^ defined above
    . "  }"
    . "],"
    . """content"": """""
    . "}"

    http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    http.Open("POST", webhookURL, false)
    http.SetRequestHeader("Content-Type", "application/json")
    http.Send(json)
}


; SC toggle
RunStrangeController() {
    global res
    global itemWebhook
    ; 1080p
    if (res = "1080p") {
        sleep 300
        MouseMove, 46, 520, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 1279, 342, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 1104, 368, 3
        sleep 300
        MouseClick, Left
        Clipboard := "Strange Controller"
        sleep 300
        Send, ^v
        sleep 300
        MouseMove, 848, 479, 3
        sleep 300
        MouseClick, Left
        sleep 300

        Loop {
            PixelSearch, Px, Py, 491, 711, 749, 723, 0x457dff, 3, Fast RGB
            if (!ErrorLevel) {
                break
            } else {
                MouseMove, 1279, 342, 3
                sleep 300
                MouseClick, Left
                sleep 300
                MouseMove, 848, 479, 3
                sleep 300
                MouseClick, Left
                sleep 300
            }
        }
        MouseMove, 682, 578, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 1413, 297, 3
        sleep 300
        MouseClick, Left
        sleep 300
    }
    ; 1440p
    else if (res = "1440p") {
        sleep 300
        MouseMove, 52, 693, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 1704, 452, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 1473, 489, 3
        sleep 300
        MouseClick, Left
        Clipboard := "Strange Controller"
        sleep 300
        Send, ^v
        sleep 300
        MouseMove, 1144, 643, 3
        sleep 300
        MouseClick, Left
        sleep 300

        Loop {
            PixelSearch, Px, Py, 655, 916, 914, 929, 0x457dff, 3, Fast RGB
            if (!ErrorLevel) {
                break
            } else {
                MouseMove, 1704, 452, 3
                sleep 300
                MouseClick, Left
                sleep 300
                MouseMove, 1144, 643, 3
                sleep 300
                MouseClick, Left
                sleep 300
            }
        }
        MouseMove, 920, 774, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 1896, 403, 3
        sleep 300
        MouseClick, Left
        sleep 300
    }
    ; 1366x768
    else if (res = "1366x768") {
        sleep 300
        MouseMove, 42, 376, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 911, 242, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 785, 262, 3
        sleep 300
        MouseClick, Left
        Clipboard := "Strange Controller"
        sleep 300
        Send, ^v
        sleep 300
        MouseMove, 616, 347, 3
        sleep 300
        MouseClick, Left
        sleep 300

        Loop {
            PixelSearch, Px, Py, 427, 518, 474, 530, 0x457dff, 3, Fast RGB
            if (!ErrorLevel) {
                break
            } else {
                MouseMove, 911, 242, 3
                sleep 300
                MouseClick, Left
                sleep 300
                MouseMove, 616, 347, 3
                sleep 300
                MouseClick, Left
                sleep 300
            }
        }
        MouseMove, 486, 413, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 1017, 214, 3
        sleep 300
        MouseClick, Left
        sleep 300
    }
    if (itemWebhook) {
        try SendWebhook(":joystick: Strange Controller was used.", "3225405")
    }
}

; BR Toggle
RunBiomeRandomizer() {
    global res
    global itemWebhook
    ; 1080p
    if (res = "1080p") {
        sleep 300
        MouseMove, 46, 520, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 1279, 342, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 1104, 368, 3
        sleep 300
        MouseClick, Left
        Clipboard := "Biome Randomizer"
        sleep 300
        Send, ^v
        sleep 300
        MouseMove, 848, 479, 3
        sleep 300
        MouseClick, Left
        sleep 300

        Loop {
            PixelSearch, Px, Py, 491, 727, 748, 739, 0x457dff, 3, Fast RGB
            if (!ErrorLevel) {
                break
            } else {
                MouseMove, 1279, 342, 3
                sleep 300
                MouseClick, Left
                sleep 300
                MouseMove, 848, 479, 3
                sleep 300
                MouseClick, Left
                sleep 300
            }
        }
        MouseMove, 682, 578, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 1413, 297, 3
        sleep 300
        MouseClick, Left
        sleep 300
    }
    ; 1440p
    else if (res = "1440p") {
        sleep 300
        MouseMove, 52, 693, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 1704, 452, 3
        sleep 300
        MouseClick, Left
		sleep 300
        MouseMove, 1473, 489, 3
        sleep 300
        MouseClick, Left
        Clipboard := "Biome Randomizer"
        sleep 300
        Send, ^v
        sleep 300
        MouseMove, 1144, 643, 3
        sleep 300
        MouseClick, Left
        sleep 300

        Loop {
            PixelSearch, Px, Py, 755, 916, 913, 928, 0x457dff, 3, Fast RGB
            if (!ErrorLevel) {
                break
            } else {
                MouseMove, 1704, 452, 3
                sleep 300
                MouseClick, Left
                sleep 300
                MouseMove, 1144, 643, 3
                sleep 300
                MouseClick, Left
                sleep 300
            }
        }
        MouseMove, 920, 774, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 1896, 403, 3
        sleep 300
        MouseClick, Left
        sleep 300
    }
    ; 1366x768
    else if (res = "1366x768") {
        sleep 300
        MouseMove, 42, 376, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 911, 242, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 785, 262, 3
        sleep 300
        MouseClick, Left
        Clipboard := "Biome Randomizer"
        sleep 300
        Send, ^v
        sleep 300
        MouseMove, 616, 347, 3
        sleep 300
        MouseClick, Left
        sleep 300

        Loop {
            PixelSearch, Px, Py, 433, 518, 480, 530, 0x8b8b8b, 3, Fast RGB
            if (!ErrorLevel) {
                break
            } else {
                MouseMove, 911, 242, 3
                sleep 300
                MouseClick, Left
                sleep 300
                MouseMove, 616, 347, 3
                sleep 300
                MouseClick, Left
                sleep 300
            }
        }
        MouseMove, 486, 413, 3
        sleep 300
        MouseClick, Left
        sleep 300
        MouseMove, 1017, 214, 3
        sleep 300
        MouseClick, Left
        sleep 300
    }
    if (itemWebhook) {
        try SendWebhook(":joystick: Biome Randomizer was used.", "3225405")
    }
}

UpdateGUI:
    if (toggle) {
        GuiControl,, StatusText, Running
        GuiControl, +%GuiColorLGreen%, StatusText
        GuiControl,, ResStatusText, Active - %res%

        elapsed := A_TickCount - startTick
        hours := elapsed // 3600000
        minutes := (elapsed - hours * 3600000) // 60000
        seconds := (elapsed - hours * 3600000 - minutes * 60000) // 1000
        timeStr := Format("{:02d}:{:02d}:{:02d}", hours, minutes, seconds)
        GuiControl,, RuntimeText, %timeStr%
        GuiControl, +%GuiColorLGreen%, RuntimeText
        GuiControl,, CyclesText, %cycleCount%
        GuiControl, +%GuiColorLGreen%, CyclesText


    } else {
        GuiControl,, StatusText, Stopped
        GuiControl, +%GuiColorRed%, StatusText
        GuiControl,, ResStatusText, Ready
    }
return

ManualGUIUpdate() {
    if (toggle) {
        GuiControl,, StatusText, Running
        GuiControl, +%GuiColorLGreen%, StatusText
        GuiControl,, ResStatusText, Active - %res%

        elapsed := A_TickCount - startTick
        hours := elapsed // 3600000
        minutes := (elapsed - hours * 3600000) // 60000
        seconds := (elapsed - hours * 3600000 - minutes * 60000) // 1000
        timeStr := Format("{:02d}:{:02d}:{:02d}", hours, minutes, seconds)
        GuiControl,, RuntimeText, %timeStr%
        GuiControl, +%GuiColorLGreen%, RuntimeText
        GuiControl,, CyclesText, %cycleCount%
        GuiControl, +%GuiColorLGreen%, CyclesText


    } else {
        GuiControl,, StatusText, Stopped
        GuiControl, +%GuiColorRed%, StatusText
        GuiControl,, ResStatusText, Ready
    }
}

F1::
    if (!res) {
        res := "1080p"
    }
    if (!toggle) {
        Gui, Submit, nohide
        
        maxLoopCount := max(MaxLoopInput, 1)
        fishingLoopCount := max(FishingLoopInput, 1)

        toggle := true
        if (hasBiomesPlugin) {
            Run, "%A_ScriptDir%\plugins\biomes.ahk"
            biomeDetectionRunning := true
        }

        strangeControllerLastRun := 0
        biomeRandomizerLastRun := 0
        snowmanPathingLastRun := 0
        if (startTick = "") {
            startTick := A_TickCount
        }

        if (cycleCount = "") {
            cycleCount := 0
        }

        strangeControllerLastRun := 0
        biomeRandomizerLastRun := 0
        snowmanPathingLastRun := 0
        INI_WRITE( res, "Macro", "resolution")
        INI_WRITE( maxLoopCount, "Macro", "maxLoopCount")
        INI_WRITE( fishingLoopCount, "Macro", "fishingLoopCount")

        WinActivate, ahk_exe RobloxPlayerBeta.exe
        ManualGUIUpdate()
        SetTimer, UpdateGUI, 1000
        switch res
        {
            case "1080p" :
                SetTimer, DoMouseMove, 100
            case "1440p" :
                SetTimer, DoMouseMove2, 100
            case "1366x768" :
                SetTimer, DoMouseMove3, 100
            default :
                SetTimer, DoMouseMove, 100
        }
        try SendWebhook(":green_circle: Macro Started!", "7909721")
    }
Return

F2::
    if (toggle) {
        if (biomeDetectionRunning) {
            DetectHiddenWindows, On
            SetTitleMatchMode, 2

            target := "biomes.ahk"
            WinGet, id, ID, %target% ahk_class AutoHotkey
            if (id) {
                WinClose, ahk_id %id%
            }
            biomeDetectionRunning := false
        }
        toggle := false
        firstLoop := true
        SetTimer, DoMouseMove, Off
        SetTimer, DoMouseMove2, Off
        SetTimer, DoMouseMove3, Off
        SetTimer, UpdateGUI, Off
        ManualGUIUpdate()
        ToolTip
        try SendWebhook(":yellow_circle: Macro Paused", "16632664")
    }
Return

F3::
    if (biomeDetectionRunning) {
        DetectHiddenWindows, On
        SetTitleMatchMode, 2

        target := "biomes.ahk"
        WinGet, id, ID, %target% ahk_class AutoHotkey
        if (id) {
            WinClose, ahk_id %id%
        }
        biomeDetectionRunning := false
    }
    try SendWebhook(":red_circle: Macro Stopped.", "14495300")
ExitApp

;1080p
DoMouseMove:
    if (toggle) {
        global pathingMode
        global privateServerLink
        global globalFailsafeTimer
        global azertyPathing
        global autoUnequip
        global autoCloseChat
        global code
        global strangeController
        global biomeRandomizer
        global strangeControllerTime
        global biomeRandomizerTime
        global strangeControllerInterval
        global biomeRandomizerInterval
        global strangeControllerLastRun
        global biomeRandomizerLastRun
        global snowmanPathingLastRun
        global startTick
        global failsafeWebhook
        global pathingWebhook
        global hasCrafterPlugin
        global crafterToggle
        global autoCrafterDetection
        global autoCrafterLastCheck
        global autoCrafterCheckInterval
        loopCount := 0
        keyW := azertyPathing ? "z" : "w"
        keyA := azertyPathing ? "q" : "a"
        restartPathing := false
        Loop {
            if (!toggle) {
                break
            }

            ; SC Toggle
            if (strangeController) {
                elapsed := A_TickCount - startTick
                if (strangeControllerLastRun = 0 && elapsed >= strangeControllerTime) {
                    RunStrangeController()
                    strangeControllerLastRun := elapsed
                } else if (strangeControllerLastRun > 0 && (elapsed - strangeControllerLastRun) >= strangeControllerInterval) {
                    RunStrangeController()
                    strangeControllerLastRun := elapsed
                }
            }

            ; Snowman Pathing Toggle
            if (snowmanPathing) {
                elapsed := A_TickCount - startTick
                if ((snowmanPathingLastRun = 0 && elapsed >= snowmanPathingTime) || (snowmanPathingLastRun > 0 && (elapsed - snowmanPathingLastRun) >= snowmanPathingInterval)) {
                    return_to_spawn()

                    if (snowmanPathingWebhook) {
                        try SendWebhook(":snowman: Starting snowman pathing...", "16636040")
                    }
                    RunSnowmanPathing()
                    snowmanPathingLastRun := elapsed

                    restartPathing := true
                    continue
                }
            }

            ; BR Toggle
            if (biomeRandomizer) {
                elapsed := A_TickCount - startTick
                if (biomeRandomizerLastRun = 0 && elapsed >= biomeRandomizerTime) {
                    RunBiomeRandomizer()
                    biomeRandomizerLastRun := elapsed
                } else if (biomeRandomizerLastRun > 0 && (elapsed - biomeRandomizerLastRun) >= biomeRandomizerInterval) {
                    RunBiomeRandomizer()
                    biomeRandomizerLastRun := elapsed
                }
            }

            ; Auto Crafter Detection (copy and pasted, need to change the coords)
            if (hasCrafterPlugin && crafterToggle && autoCrafterDetection) {
                currentTime := A_TickCount
                if (currentTime - autoCrafterLastCheck >= autoCrafterCheckInterval) {
                    autoCrafterLastCheck := currentTime
                    PixelSearch, Px, Py, 2203, 959, 2203, 959, 0x6eb4ff, 3, RGB
                    if (!ErrorLevel) {
                        RunAutoCrafter()
                    }
                }
            }

            ; More snowman pathing
            loopCount++
            if (loopCount > (sellAllToggle ? min(maxLoopCount, 22) : maxLoopCount) || restartPathing) {
                restartPathing := false

                if (snowmanPathing) {
                    Sleep, 2000
                }

                if (pathingWebhook) {
                    try SendWebhook(":moneybag: Starting Auto-Sell Pathing...", "16636040")
                }

                if (autoUnequip) {
                    MouseMove, 45, 412, 3
                    sleep 300
                    Click, Left
                    sleep 300
                    MouseMove, 830, 441, 3
                    sleep 300
                    Click, Left
                    sleep 300
                    MouseMove, 634, 638, 3
                    sleep 300
                    Click, Left
                    sleep 1200
                    Click, Left
                    sleep 300
                    MouseMove, 1425, 303, 3
                    sleep 300
                    Click, Left
                    sleep 300
                }

                if (autoCloseChat) {
                    sleep 300
                    Send {/}
                    sleep 300
                    MouseMove, 149, 40, 3
                    sleep 300
                    MouseClick, Left
                    sleep 300
                }

                return_to_spawn()
                MouseMove, 47, 467, 3
                sleep 220
                Click, Left
                sleep 220
                MouseMove, 382, 126, 3
                sleep 220
                Click, Left
                sleep 220
                Click, WheelUp 80
                sleep 500
                Click, WheelDown 45
                sleep 300

                if (pathingMode = "Non Vip Pathing") {
                    ; Non VIP Pathing
                    Send, {%keyW% Down}
                    Send, {%keyA% Down}
                    sleep 5190
                    Send, {%keyW% Up}
                    sleep 800
                    Send {%keyA% Up}
                    sleep 200
                    Send {%keyW% Down}
                    sleep 550
                    Send {%keyW% Up}
                    sleep 300
                    Send {d Down}
                    sleep 240
                    Send {d Up}
                    sleep 150
                    Send {%keyW% Down}
                    sleep 1450
                    Send {%keyW% Up}
                    sleep 300
                    Send {s Down}
                    sleep 300
                    Send {s Up}
                    sleep 300
                    Send {Space Down}
                    sleep 25
                    Send {%keyW% Down}
                    sleep 1100
                    Send {Space Up}
                    sleep 520
                    Send {%keyW% Up}
                    sleep 300
                    Send {e Down}
                    sleep 300
                    Send {e Up}
                    sleep 300
                    MouseMove, 956, 803, 3
                    sleep 50
                    MouseClick, Left
                    sleep 50
                    MouseClick, Left
                    sleep 200
                    MouseMove, 956, 938, 3
                    sleep 200
                    MouseClick, Left
                    sleep 800
                    loopCount := 0

                    while (loopCount < fishingLoopCount) {
                        MouseMove, 828, 404, 3
                        sleep 200
                        MouseClick, Left
                        sleep 200
                        if (sellAllToggle) {
                            MouseMove, 680, 804, 3
                        } else {
                            MouseMove, 512, 804, 3
                        }
                        sleep 200
                        MouseClick, Left
                        sleep 300
                        MouseMove, 801, 626, 3
                        sleep 200
                        MouseClick, Left
                        sleep 1000
                        loopCount++
                    }

                    MouseMove, 1458, 266, 3
                    sleep 200
                    MouseClick, Left
                    sleep 200
                    Send, {%keyA% Down}
                    sleep 1400
                    Send, {%keyA% Up}
                    sleep 75
                    Send, {%keyW% Down}
                    sleep 3300
                    Send, {%keyW% Up}
                    loopCount := 0
                } else if (pathingMode = "Vip Pathing") {
                    ; VIP Pathing
                    Send, {%keyW% Down}
                    Send, {%keyA% Down}
                    sleep 4150
                    Send, {%keyW% Up}
                    sleep 600
                    Send {%keyA% Up}
                    sleep 200
                    Send {%keyW% Down}
                    sleep 400
                    Send {%keyW% Up}
                    sleep 300
                    Send {d Down}
                    sleep 180
                    Send {d Up}
                    sleep 150
                    Send {%keyW% Down}
                    sleep 1100
                    Send {%keyW% Up}
                    sleep 300
                    Send {s Down}
                    sleep 300
                    Send {s Up}
                    sleep 300
                    Send {Space Down}
                    sleep 25
                    Send {%keyW% Down}
                    sleep 1200
                    Send {Space Up}
                    sleep 200
                    Send {%keyW% Up}
                    sleep 300
                    Send {e Down}
                    sleep 300
                    Send {e Up}
                    sleep 300
                    MouseMove, 956, 803, 3
                    sleep 50
                    MouseClick, Left
                    sleep 50
                    MouseClick, Left
                    sleep 200
                    MouseMove, 956, 938, 3
                    sleep 200
                    MouseClick, Left
                    sleep 800
                    loopCount := 0

                    while (loopCount < fishingLoopCount) {
                        MouseMove, 828, 404, 3
                        sleep 200
                        MouseClick, Left
                        sleep 200
                        if (sellAllToggle) {
                            MouseMove, 680, 804, 3
                        } else {
                            MouseMove, 512, 804, 3
                        }
                        sleep 200
                        MouseClick, Left
                        sleep 300
                        MouseMove, 801, 626, 3
                        sleep 200
                        MouseClick, Left
                        sleep 1000
                        loopCount++
                    }

                    MouseMove, 1458, 266, 3
                    sleep 200
                    MouseClick, Left
                    sleep 200
                    Send, {%keyA% Down}
                    sleep 1400
                    Send, {%keyA% Up}
                    sleep 75
                    Send, {%keyW% Down}
                    sleep 2670
                    Send, {%keyW% Up}
                    loopCount := 0
                } else if (pathingMode = "Abyssal Pathing") {
                    ; Abyssal Pathing
                    MouseMove, 30, 406, 3
                    sleep 200
                    MouseClick, Left
                    sleep 200
                    MouseMove, 947, 335, 3
                    sleep 200
                    MouseClick, Left
                    sleep 100
                    MouseMove, 1102, 367, 3
                    sleep 100
                    MouseClick, Left
                    sleep 100
                    ClipBoard := "Abyssal Hunter"
                    sleep 100
                    Send, ^v
                    sleep 200
                    MouseMove, 819, 434, 3
                    sleep 200
                    Click, WheelUp 100
                    sleep 200
                    MouseClick, Left
                    sleep 200

                    ErrorLevel := 0
                    PixelSearch, px, py, 576, 626, 666, 645, 0xfc7f98, 3, Fast RGB
                    if (ErrorLevel != 0) {
                        MouseMove, 623, 634, 3
                        sleep 200
                        MouseClick, Left
                    }

                    sleep 200
                    MouseMove, 1412, 296, 3
                    sleep 200
                    MouseClick, Left
                    sleep 200

                    Send, {%keyW% Down}
                    sleep 500
                    Send, {%keyA% Down}
                    sleep 2650
                    Send, {%keyW% Up}
                    sleep 600
                    Send {%keyA% Up}
                    sleep 200
                    Send {%keyW% Down}
                    sleep 500
                    Send {%keyW% Up}
                    sleep 200
                    Send {s Down}
                    sleep 120
                    Send {s Up}
                    sleep 100
                    Send {d Down}
                    sleep 280
                    Send {d Up}
                    sleep 200
                    Send {%keyA% Down}
                    sleep 50
                    Send {Space Down}
                    sleep 730
                    Send {Space Up}
                    sleep 200
                    Send {%keyA% Up}
                    sleep 100
                    Send {%keyW% Down}
                    sleep 810
                    Send {%keyW% Up}
                    sleep 150
                    Send {space Down}
                    sleep 15
                    Send {d Down}
                    sleep 150
                    Send {space Up}
                    sleep 580
                    Send {d Up}
                    sleep 100
                    Send {e Down}
                    sleep 300
                    Send {e Up}
                    sleep 300

                    MouseMove, 981, 805, 3
                    sleep 50
                    MouseClick, Left
                    sleep 50
                    MouseClick, Left
                    sleep 200
                    MouseMove, 967, 948, 3
                    sleep 200
                    MouseClick, Left
                    sleep 800
                    loopCount := 0

                    while (loopCount < fishingLoopCount) {
                        MouseMove, 838, 413, 3
                        sleep 200
                        MouseClick, Left
                        sleep 200
                        if (sellAllToggle) {
                            MouseMove, 678, 810, 3
                        } else {
                            MouseMove, 525, 809, 3
                        }
                        sleep 200
                        MouseClick, Left
                        sleep 300
                        MouseMove, 801, 626, 3
                        sleep 200
                        MouseClick, Left
                        sleep 1000
                        loopCount++
                    }

                    MouseMove, 1469, 271, 3
                    sleep 200
                    MouseClick, Left
                    sleep 200
                    Send, {%keyA% Down}
                    sleep 800
                    Send, {%keyA% Up}
                    sleep 100
                    Send, {%keyW% Down}
                    sleep 1760
                    Send, {%keyW% Up}
                    loopCount := 0
                }
            }

            MouseMove, 862, 843, 3
            Sleep 300
            MouseClick, Left
            sleep 300
            barColor := 0
            otherBarColor := 0

            ; Check for white pixel
            startWhitePixelSearch := A_TickCount
            if (globalFailsafeTimer = 0) {
                globalFailsafeTimer := A_TickCount
            }
            fishingFailsafeRan := false
                Loop {
                PixelGetColor, color, 1176, 836, RGB
                if (color = 0xFFFFFF) {
                    MouseMove, 950, 880, 3
                    ; Get randomized bar color
                    Sleep 50
                    PixelGetColor, barColor, 955, 767, RGB
                    SetTimer, DoMouseMove, Off
                    globalFailsafeTimer := 0
                    break
                }

                ; Auto Rejoin Failsafe
                if (A_TickCount - globalFailsafeTimer > (autoRejoinFailsafeTime * 1000) && privateServerLink != "") {
                    PixelGetColor, checkColor, 1175, 837, RGB
                    if (checkColor != 0xFFFFFF) {
                        Process, Close, RobloxPlayerBeta.exe
                        sleep 500
                        Run, % "powershell -NoProfile -Command ""Start-Process 'roblox://navigation/share_links?code=" code "&type=Server'"""
                        sleep 5000
                        WinActivate, ahk_exe RobloxPlayerBeta.exe
                        sleep 7000
                        MouseMove, 960, 540, 3
                        sleep 200
                        MouseClick, Left
                        sleep 6000

                        ; Start button
                        sleep 1000
                        Loop {
                            ErrorLevel := 0
                            PixelSearch, px, py, 205, 1019, 325, 978, 0x82ff95, 5, Fast RGB
                            if (ErrorLevel = 0) {
                                sleep 1000
                                MouseMove, 267, 1000, 3
                                sleep 350
                                MouseClick, Left
                                break
                            }
                        }

                        sleep 3000
                        restartPathing := true
                        try SendWebhook(":repeat: Auto Rejoin failsafe was triggered.", "3426654")
                        break
                    }
                }

                ; Fishing Failsafe
                if (A_TickCount - startWhitePixelSearch > (fishingFailsafeTime * 1000) && !fishingFailsafeRan) {
                    MouseMove, 1268, 941, 3
                    sleep 300
                    MouseClick, Left
                    sleep 300
                    MouseMove, 1167, 476, 3
                    sleep 300
                    MouseClick, Left
                    sleep 300
                    MouseMove, 1113, 342, 3
                    sleep 300
                    MouseClick, left
                    sleep 300
                    MouseMove, 851, 832, 3
                    sleep 300
                    MouseClick, Left
                    fishingFailsafeRan := true
                    if (failsafeWebhook) {
                        try SendWebhook(":grey_question: Fishing failsafe was triggered.", "13424349")
                    }
                }
                ; Pathing Failsafe
                if (A_TickCount - startWhitePixelSearch > (pathingFailsafeTime * 1000)) {
                    restartPathing := true
                    if (failsafeWebhook) {
                        try SendWebhook(":feet: Pathing failsafe was triggered.", "6693139")
                    }
                    break
                }
                if (!toggle) {
                    Return
                }
            }

            if (restartPathing) {
            continue
            }

            ; PixelSearch loop
            startTime := A_TickCount
            Loop {
            if (!toggle)
            break
            if (A_TickCount - startTime > 9000)
            break

            ; Advanced detection
            if (advancedFishingDetection) {
                ErrorLevel := 0
                PixelSearch, leftX, leftY, 757, 767, 1161, 767, barColor, 5, Fast RGB
                if (ErrorLevel = 0) {
                    rightX := leftX
                    Loop {
                        testX := rightX + 1
                        if (testX > 1161)
                            break
                        PixelGetColor, testColor, %testX%, 767, RGB
                        if (Abs((testColor & 0xFF) - (barColor & 0xFF)) <= 10 && Abs(((testColor >> 8) & 0xFF) - ((barColor >> 8) & 0xFF)) <= 10 && Abs(((testColor >> 16) & 0xFF) - ((barColor >> 16) & 0xFF)) <= 10) {
                            rightX := testX
                        } else {
                            break
                        }
                    }
                    barWidth := rightX - leftX
                    if (barWidth < advancedFishingThreshold) {
                        MouseClick, left
                        sleep 25
                    }
                } else {
                    MouseClick, left
                }
                sleep 10
            } else {
                ; Normal detection
                ErrorLevel := 0
                PixelSearch, FoundX, FoundY, 757, 762, 1161, 782, barColor, 5, Fast RGB
                if (ErrorLevel = 0) {
                } else {
                    MouseClick, left
                }
            }
        }
        sleep 300
        MouseMove, 1113, 342, 3
        Sleep 700
        MouseClick, Left
        sleep 300
        cycleCount++
        }
    }
Return

;1440p
DoMouseMove2:
    if (toggle) {

        global pathingMode
        global privateServerLink
        global globalFailsafeTimer
        global azertyPathing
        global autoUnequip
        global autoCloseChat
        global code
        global strangeController
        global biomeRandomizer
        global strangeControllerTime
        global biomeRandomizerTime
        global strangeControllerInterval
        global biomeRandomizerInterval
        global strangeControllerLastRun
        global biomeRandomizerLastRun
        global snowmanPathingLastRun
        global startTick
        global failsafeWebhook
        global pathingWebhook
        global hasCrafterPlugin
        global crafterToggle
        global autoCrafterDetection
        global autoCrafterLastCheck
        global autoCrafterCheckInterval
        loopCount := 0
        keyW := azertyPathing ? "z" : "w"
        keyA := azertyPathing ? "q" : "a"
        restartPathing := false
        Loop {
            if (!toggle) {
                break
            }

            ; SC Toggle
            if (strangeController) {
                elapsed := A_TickCount - startTick
                if (strangeControllerLastRun = 0 && elapsed >= strangeControllerTime) {
                    RunStrangeController()
                    strangeControllerLastRun := elapsed
                } else if (strangeControllerLastRun > 0 && (elapsed - strangeControllerLastRun) >= strangeControllerInterval) {
                    RunStrangeController()
                    strangeControllerLastRun := elapsed
                }
            }

            ; Snowman Pathing Toggle
            if (snowmanPathing) {
                elapsed := A_TickCount - startTick
                if ((snowmanPathingLastRun = 0 && elapsed >= snowmanPathingTime) || (snowmanPathingLastRun > 0 && (elapsed - snowmanPathingLastRun) >= snowmanPathingInterval)) {
                    return_to_spawn()

                    if (snowmanPathingWebhook) {
                        try SendWebhook(":snowman: Starting snowman pathing...", "16636040")
                    }
                    RunSnowmanPathing()
                    snowmanPathingLastRun := elapsed

                    restartPathing := true
                    continue
                }
            }

            ; BR Toggle
            if (biomeRandomizer) {
                elapsed := A_TickCount - startTick
                if (biomeRandomizerLastRun = 0 && elapsed >= biomeRandomizerTime) {
                    RunBiomeRandomizer()
                    biomeRandomizerLastRun := elapsed
                } else if (biomeRandomizerLastRun > 0 && (elapsed - biomeRandomizerLastRun) >= biomeRandomizerInterval) {
                    RunBiomeRandomizer()
                    biomeRandomizerLastRun := elapsed
                }
            }

            ; Auto Crafter Detection
            if (hasCrafterPlugin && crafterToggle && autoCrafterDetection) {
                currentTime := A_TickCount
                if (currentTime - autoCrafterLastCheck >= autoCrafterCheckInterval) {
                    autoCrafterLastCheck := currentTime
                    PixelSearch, Px, Py, 2203, 959, 2203, 959, 0x6eb4ff, 3, RGB
                    if (!ErrorLevel) {
                        RunAutoCrafter()
                    }
                }
            }

            ; More snowman pathing
            loopCount++
            if (loopCount > (sellAllToggle ? min(maxLoopCount, 22) : maxLoopCount) || restartPathing) {
                restartPathing := false

                if (snowmanPathing) {
                    Sleep, 2000
                }

                if (pathingWebhook) {
                    try SendWebhook(":moneybag: Starting Auto-Sell Pathing...", "16636040")
                }

                if (autoUnequip) {
                    MouseMove, 41, 538, 3
                    sleep 300
                    Click, Left
                    sleep 300
                    MouseMove, 1089, 575, 3
                    sleep 300
                    Click, Left
                    sleep 300
                    MouseMove, 835, 845, 3
                    sleep 300
                    Click, Left
                    sleep 1200
                    Click, Left
                    sleep 300
                    MouseMove, 1882, 395, 3
                    sleep 300
                    Click, Left
                    sleep 300
                }

                if (autoCloseChat) {
                    sleep 300
                    Send {/}
                    sleep 300
                    MouseMove, 151, 38, 3
                    sleep 300
                    MouseClick, Left
                    sleep 300
                }
                
                return_to_spawn()
                MouseMove, 52, 621, 3
                sleep 220
                Click, Left
                sleep 220
                MouseMove, 525, 158, 3
                sleep 220
                Click, Left
                sleep 220
                Click, WheelUp 80
                sleep 500
                Click, WheelDown 35
                sleep 300

                ; Regular Pathing
                if (pathingMode = "Non Vip Pathing") {
                    ; Non VIP Pathing
                    Send, {%keyW% Down}
                    Send, {%keyA% Down}
                    sleep 5190
                    Send, {%keyW% Up}
                    sleep 800
                    Send {%keyA% Up}
                    sleep 200
                    Send {%keyW% Down}
                    sleep 550
                    Send {%keyW% Up}
                    sleep 300
                    Send {d Down}
                    sleep 240
                    Send {d Up}
                    sleep 150
                    Send {%keyW% Down}
                    sleep 1450
                    Send {%keyW% Up}
                    sleep 300
                    Send {s Down}
                    sleep 300
                    Send {s Up}
                    sleep 300
                    Send {Space Down}
                    sleep 25
                    Send {%keyW% Down}
                    sleep 1100
                    Send {Space Up}
                    sleep 520
                    Send {%keyW% Up}
                    sleep 300
                    Send {e Down}
                    sleep 300
                    Send {e Up}
                    sleep 300
                    MouseMove, 1308, 1073, 3
                    sleep 50
                    MouseClick, Left
                    sleep 50
                    MouseClick, Left
                    sleep 200
                    MouseMove, 1289, 1264, 3
                    sleep 200
                    MouseClick, Left
                    sleep 800
                    loopCount := 0

                    while (loopCount < fishingLoopCount) {
                        MouseMove, 1117, 550, 3
                        sleep 200
                        MouseClick, Left
                        sleep 200
                        if (sellAllToggle) {
                            MouseMove, 904, 1080, 3
                        } else {
                            MouseMove, 700, 1078, 3
                        }
                        sleep 200
                        MouseClick, Left
                        sleep 300
                        MouseMove, 1002, 831, 3
                        sleep 200
                        MouseClick, Left
                        sleep 1000
                        loopCount++
                    }

                    MouseMove, 1958, 361, 3
                    sleep 200
                    MouseClick, Left
                    sleep 200
                    Send, {%keyA% Down}
                    sleep 1400
                    Send, {%keyA% Up}
                    sleep 75
                    Send, {%keyW% Down}
                    sleep 3300
                    Send, {%keyW% Up}
                    loopCount := 0
                } else if (pathingMode = "Vip Pathing") {
                    ; VIP Pathing
                    Send, {%keyW% Down}
                    Send, {%keyA% Down}
                    sleep 4150
                    Send, {%keyW% Up}
                    sleep 600
                    Send {%keyA% Up}
                    sleep 200
                    Send {%keyW% Down}
                    sleep 400
                    Send {%keyW% Up}
                    sleep 300
                    Send {d Down}
                    sleep 180
                    Send {d Up}
                    sleep 150
                    Send {%keyW% Down}
                    sleep 1100
                    Send {%keyW% Up}
                    sleep 300
                    Send {s Down}
                    sleep 300
                    Send {s Up}
                    sleep 300
                    Send {Space Down}
                    sleep 25
                    Send {%keyW% Down}
                    sleep 1200
                    Send {Space Up}
                    sleep 200
                    Send {%keyW% Up}
                    sleep 300
                    Send {e Down}
                    sleep 300
                    Send {e Up}
                    sleep 300
                    MouseMove, 1308, 1073, 3
                    sleep 50
                    MouseClick, Left
                    sleep 50
                    MouseClick, Left
                    sleep 200
                    MouseMove, 1289, 1264, 3
                    sleep 200
                    MouseClick, Left
                    sleep 800
                    loopCount := 0

                    while (loopCount < fishingLoopCount) {
                        MouseMove, 1117, 550, 3
                        sleep 200
                        MouseClick, Left
                        sleep 200
                        if (sellAllToggle) {
                            MouseMove, 904, 1080, 3
                        } else {
                            MouseMove, 700, 1078, 3
                        }
                        sleep 200
                        MouseClick, Left
                        sleep 300
                        MouseMove, 1002, 831, 3
                        sleep 200
                        MouseClick, Left
                        sleep 1000
                        loopCount++
                    }

                    MouseMove, 1958, 361, 3
                    sleep 200
                    MouseClick, Left
                    sleep 200
                    Send, {%keyA% Down}
                    sleep 1400
                    Send, {%keyA% Up}
                    sleep 75
                    Send, {%keyW% Down}
                    sleep 2670
                    Send, {%keyW% Up}
                    loopCount := 0
                } else if (pathingMode = "Abyssal Pathing") {
                    ; Abyssal Pathing
                    MouseMove, 40, 541, 3
                    sleep 200
                    MouseClick, Left
                    sleep 200
                    MouseMove, 1262, 447, 3
                    sleep 200
                    MouseClick, Left
                    sleep 100
                    MouseMove, 1469, 489, 3
                    sleep 100
                    MouseClick, Left
                    sleep 100
                    ClipBoard := "Abyssal Hunter"
                    sleep 100
                    Send, ^v
                    sleep 200
                    MouseMove, 1092, 579, 3
                    sleep 200
                    Click, WheelUp 100
                    sleep 200
                    MouseClick, Left
                    sleep 200

                    ErrorLevel := 0
                    PixelSearch, px, py, 768, 835, 888, 860, 0xfc7f98, 3, Fast RGB
                    if (ErrorLevel != 0) {
                        MouseMove, 830, 845, 3
                        sleep 200
                        MouseClick, Left
                    }

                    sleep 200
                    MouseMove, 1883, 395, 3
                    sleep 200
                    MouseClick, Left
                    sleep 200

                    Send, {%keyW% Down}
                    sleep 500
                    Send, {%keyA% Down}
                    sleep 2650
                    Send, {%keyW% Up}
                    sleep 600
                    Send {%keyA% Up}
                    sleep 200
                    Send {%keyW% Down}
                    sleep 500
                    Send {%keyW% Up}
                    sleep 200
                    Send {s Down}
                    sleep 120
                    Send {s Up}
                    sleep 100
                    Send {d Down}
                    sleep 280
                    Send {d Up}
                    sleep 200
                    Send {%keyA% Down}
                    sleep 50
                    Send {Space Down}
                    sleep 730
                    Send {Space Up}
                    sleep 200
                    Send {%keyA% Up}
                    sleep 100
                    Send {%keyW% Down}
                    sleep 810
                    Send {%keyW% Up}
                    sleep 150
                    Send {space Down}
                    sleep 15
                    Send {d Down}
                    sleep 150
                    Send {space Up}
                    sleep 580
                    Send {d Up}
                    sleep 100
                    Send {e Down}
                    sleep 300
                    Send {e Up}
                    sleep 300

                    MouseMove, 1308, 1073, 3
                    sleep 50
                    MouseClick, Left
                    sleep 50
                    MouseClick, Left
                    sleep 200
                    MouseMove, 1289, 1264, 3
                    sleep 200
                    MouseClick, Left
                    sleep 800
                    loopCount := 0

                    while (loopCount < fishingLoopCount) {
                        MouseMove, 1117, 550, 3
                        sleep 200
                        MouseClick, Left
                        sleep 200
                        if (sellAllToggle) {
                            MouseMove, 904, 1080, 3
                        } else {
                            MouseMove, 700, 1078, 3
                        }
                        sleep 200
                        MouseClick, Left
                        sleep 300
                        MouseMove, 1002, 831, 3
                        sleep 200
                        MouseClick, Left
                        sleep 1000
                        loopCount++
                    }

                    MouseMove, 1958, 361, 3
                    sleep 200
                    MouseClick, Left
                    sleep 200
                    Send, {%keyA% Down}
                    sleep 800
                    Send, {%keyA% Up}
                    sleep 100
                    Send, {%keyW% Down}
                    sleep 1760
                    Send, {%keyW% Up}
                    loopCount := 0
                }
            }
            ; Fishing Minigame
            MouseMove, 1161, 1124, 3
            Sleep 30
            MouseClick, Left
            sleep 300
            barColor := 0
            otherBarColor := 0

            ; Check for white pixel
            startWhitePixelSearch := A_TickCount
            if (globalFailsafeTimer = 0) {
                globalFailsafeTimer := A_TickCount
            }
            fishingFailsafeRan := false
            Loop {
                PixelGetColor, color, 1536, 1119, RGB
                if (color = 0xFFFFFF) {
                    MouseMove, 1263, 1177, 3
                    ; Get randomized bar color
                    Sleep 50
                    PixelGetColor, barColor, 1261, 1033, RGB
                    SetTimer, DoMouseMove2, Off
                    globalFailsafeTimer := 0
                    break
                }

                ; Auto Rejoin Failsafe
                if (A_TickCount - globalFailsafeTimer > (autoRejoinFailsafeTime * 1000) && privateServerLink != "") {
                    PixelGetColor, checkColor, 1535, 1120, RGB
                    if (checkColor != 0xFFFFFF) {
                        Process, Close, RobloxPlayerBeta.exe
                        sleep 500
                        Run, % "powershell -NoProfile -Command ""Start-Process 'roblox://navigation/share_links?code=" code "&type=Server'"""
                        sleep 5000
                        WinActivate, ahk_exe RobloxPlayerBeta.exe
                        sleep 6000

                        ; Skip button
                        sleep 1000
                        MouseMove, 1280, 720, 3
                        sleep 200
                        MouseClick, Left
                        sleep 6000

                        ; Start button
                        sleep 1000
                        Loop {
                            ErrorLevel := 0
                            PixelSearch, px, py, 295, 1364, 445, 1311, 0x82ff95, 5, Fast RGB
                            if (ErrorLevel = 0) {
                                sleep 1000
                                MouseMove, 347, 1329, 3
                                sleep 350
                                MouseClick, Left
                                break
                            }
                            sleep 100
                        }

                        sleep 3000
                        restartPathing := true
                        try SendWebhook(":repeat: Auto Rejoin failsafe was triggered.", "3426654")
                        break
                    }
                }

                ; Fishing Failsafe
                if (A_TickCount - startWhitePixelSearch > (fishingFailsafeTime * 1000) && !fishingFailsafeRan) {
                    MouseMove, 1690, 1224, 3
                    sleep 300
                    MouseClick, Left
                    sleep 300
                    MouseMove, 1523, 649, 3
                    sleep 300
                    MouseClick, Left
                    sleep 300
                    MouseMove, 1457, 491, 3
                    sleep 300
                    MouseClick, left
                    sleep 300
                    MouseMove, 1163, 1126, 3
                    sleep 300
                    MouseClick, Left
                    fishingFailsafeRan := true
                    if (failsafeWebhook) {
                        try SendWebhook(":grey_question: Fishing failsafe was triggered.", "13424349")
                    }
                }

                ; Pathing Failsafe
                if (A_TickCount - startWhitePixelSearch > (pathingFailsafeTime * 1000)) {
                    restartPathing := true
                    if (failsafeWebhook) {
                        try SendWebhook(":feet: Pathing failsafe was triggered.", "6693139")
                    }
                    break
                }

                if (!toggle) {
                    Return
                }
            }

            if (restartPathing) {
                continue
            }

            ; PixelSearch loop
            startTime := A_TickCount
            Loop {
                if (!toggle)
                    break
                if (A_TickCount - startTime > 9000)
                    break

                ; Advanced detection
                if (advancedFishingDetection) {
                    ErrorLevel := 0
                    PixelSearch, leftX, leftY, 1043, 1033, 1519, 1033, barColor, 5, Fast RGB
                    if (ErrorLevel = 0) {
                        rightX := leftX
                        Loop {
                            testX := rightX + 1
                            if (testX > 1519)
                                break
                            PixelGetColor, testColor, %testX%, 1033, RGB
                            if (Abs((testColor & 0xFF) - (barColor & 0xFF)) <= 10 && Abs(((testColor >> 8) & 0xFF) - ((barColor >> 8) & 0xFF)) <= 10 && Abs(((testColor >> 16) & 0xFF) - ((barColor >> 16) & 0xFF)) <= 10) {
                                rightX := testX
                            } else {
                                break
                            }
                        }
                        barWidth := rightX - leftX
                        if (barWidth < advancedFishingThreshold) {
                            MouseClick, left
                            sleep 25
                        }
                    } else {
                        MouseClick, left
                    }
                } else {
                    ; Normal detection
                    ErrorLevel := 0
                    PixelSearch, FoundX, FoundY, 1043, 1033, 1519, 1058, barColor, 5, Fast RGB
                    if (ErrorLevel = 0) {
                    } else {
                        MouseClick, left
                    }
                }
            }
            sleep 300
            MouseMove, 1457, 491, 3
            sleep 700
            MouseClick, Left
            sleep 300
            cycleCount++
        }
    }
Return

;786p
DoMouseMove3:
    if (toggle) {

        global pathingMode
        global privateServerLink
        global globalFailsafeTimer
        global azertyPathing
        global autoUnequip
        global autoCloseChat
        global code
        global strangeController
        global biomeRandomizer
        global strangeControllerTime
        global biomeRandomizerTime
        global strangeControllerInterval
        global biomeRandomizerInterval
        global strangeControllerLastRun
        global biomeRandomizerLastRun
        global snowmanPathingLastRun
        global startTick
        global failsafeWebhook
        global pathingWebhook
        global hasCrafterPlugin
        global crafterToggle
        global autoCrafterDetection
        global autoCrafterLastCheck
        global autoCrafterCheckInterval
        loopCount := 0
        keyW := azertyPathing ? "z" : "w"
        keyA := azertyPathing ? "q" : "a"
        restartPathing := false
        Loop {
            if (!toggle) {
                break
            }

            ; SC Toggle
            if (strangeController) {
                elapsed := A_TickCount - startTick
                if (strangeControllerLastRun = 0 && elapsed >= strangeControllerTime) {
                    RunStrangeController()
                    strangeControllerLastRun := elapsed
                } else if (strangeControllerLastRun > 0 && (elapsed - strangeControllerLastRun) >= strangeControllerInterval) {
                    RunStrangeController()
                    strangeControllerLastRun := elapsed
                }
            }

            ; Snowman Pathing
            if (snowmanPathing) {
                elapsed := A_TickCount - startTick
                if ((snowmanPathingLastRun = 0 && elapsed >= snowmanPathingTime) || (snowmanPathingLastRun > 0 && (elapsed - snowmanPathingLastRun) >= snowmanPathingInterval)) {
                    if (snowmanPathingWebhook) {
                        try SendWebhook(":moneybag: Resetting character after snowman pathing...", "16636040")
                    }
                    return_to_spawn()

                    if (snowmanPathingWebhook) {
                        try SendWebhook(":snowman: Starting snowman pathing...", "16636040")
                    }
                    RunSnowmanPathing()
                    snowmanPathingLastRun := elapsed

                    restartPathing := true
                    continue
                }
            }

            ; BR Toggle
            if (biomeRandomizer) {
                elapsed := A_TickCount - startTick
                if (biomeRandomizerLastRun = 0 && elapsed >= biomeRandomizerTime) {
                    RunBiomeRandomizer()
                    biomeRandomizerLastRun := elapsed
                } else if (biomeRandomizerLastRun > 0 && (elapsed - biomeRandomizerLastRun) >= biomeRandomizerInterval) {
                    RunBiomeRandomizer()
                    biomeRandomizerLastRun := elapsed
                }
            }

            ; Auto Crafter Detection (copy and pasted, need to change the coords)
            if (hasCrafterPlugin && crafterToggle && autoCrafterDetection) {
                currentTime := A_TickCount
                if (currentTime - autoCrafterLastCheck >= autoCrafterCheckInterval) {
                    autoCrafterLastCheck := currentTime
                    PixelSearch, Px, Py, 2203, 959, 2203, 959, 0x6eb4ff, 3, RGB
                    if (!ErrorLevel) {
                        RunAutoCrafter()
                    }
                }
            }

            ; More snowman pathing
            loopCount++
            if (loopCount > (sellAllToggle ? min(maxLoopCount, 22) : maxLoopCount) || restartPathing) {
                restartPathing := false

                if (snowmanPathing) {
                    Sleep, 2000
                }

                if (pathingWebhook) {
                    try SendWebhook(":moneybag: Starting Auto-Sell Pathing...", "16636040")
                }

                if (autoUnequip) {
                    MouseMove, 38, 292, 3
                    sleep 300
                    Click, Left
                    sleep 300
                    MouseMove, 594, 314, 3
                    sleep 300
                    Click, Left
                    sleep 300
                    MouseMove, 458, 457, 3
                    sleep 300
                    Click, Left
                    sleep 1200
                    Click, Left
                    sleep 300
                    MouseMove, 1016, 218, 3
                    sleep 300
                    Click, Left
                    sleep 300
                }

                if (autoCloseChat) {
                    sleep 300
                    Send {/}
                    sleep 300
                    MouseMove, 151, 42, 3
                    sleep 300
                    MouseClick, Left
                    sleep 300
                }

                return_to_spawn()
                MouseMove, 26, 325, 3
                sleep 220
                Click, Left
                sleep 220
                MouseMove, 273, 106, 3
                sleep 220
                Click, Left
                sleep 220
                Click, WheelUp 80
                sleep 500
                Click, WheelDown 90
                sleep 300

                if (pathingMode = "Non Vip Pathing") {
                    ; Non VIP Pathing
                    Send, {%keyW% Down}
                    Send, {%keyA% Down}
                    sleep 5190
                    Send, {%keyW% Up}
                    sleep 800
                    Send {%keyA% Up}
                    sleep 200
                    Send {%keyW% Down}
                    sleep 550
                    Send {%keyW% Up}
                    sleep 300
                    Send {d Down}
                    sleep 240
                    Send {d Up}
                    sleep 150
                    Send {%keyW% Down}
                    sleep 1450
                    Send {%keyW% Up}
                    sleep 300
                    Send {s Down}
                    sleep 300
                    Send {s Up}
                    sleep 300
                    Send {Space Down}
                    sleep 25
                    Send {%keyW% Down}
                    sleep 1100
                    Send {Space Up}
                    sleep 520
                    Send {%keyW% Up}
                    sleep 300
                    Send {e Down}
                    sleep 300
                    Send {e Up}
                    sleep 300
                    MouseMove, 682, 563, 3
                    sleep 50
                    MouseClick, Left
                    sleep 50
                    MouseClick, Left
                    sleep 200
                    MouseMove, 682, 667, 3
                    sleep 200
                    MouseClick, Left
                    sleep 800
                    loopCount := 0

                    while (loopCount < fishingLoopCount) {
                        MouseMove, 586, 287, 3
                        sleep 200
                        MouseClick, Left
                        sleep 200
                        if (sellAllToggle) {
                            MouseMove, 486, 570, 3
                        } else {
                            MouseMove, 365, 570, 3
                        }
                        sleep 200
                        MouseClick, Left
                        sleep 300
                        MouseMove, 573, 447, 3
                        sleep 200
                        MouseClick, Left
                        sleep 1000
                        loopCount++
                    }

                    MouseMove, 1050, 197, 3
                    sleep 200
                    MouseClick, Left
                    sleep 200
                    Send, {%keyA% Down}
                    sleep 1400
                    Send, {%keyA% Up}
                    sleep 75
                    Send, {%keyW% Down}
                    sleep 3300
                    Send, {%keyW% Up}
                    loopCount := 0
                } else if (pathingMode = "Vip Pathing") {
                    ; VIP Pathing
                    Send, {%keyW% Down}
                    Send, {%keyA% Down}
                    sleep 4150
                    Send, {%keyW% Up}
                    sleep 600
                    Send {%keyA% Up}
                    sleep 200
                    Send {%keyW% Down}
                    sleep 400
                    Send {%keyW% Up}
                    sleep 300
                    Send {d Down}
                    sleep 180
                    Send {d Up}
                    sleep 150
                    Send {%keyW% Down}
                    sleep 1100
                    Send {%keyW% Up}
                    sleep 300
                    Send {s Down}
                    sleep 300
                    Send {s Up}
                    sleep 300
                    Send {Space Down}
                    sleep 25
                    Send {%keyW% Down}
                    sleep 1200
                    Send {Space Up}
                    sleep 200
                    Send {%keyW% Up}
                    sleep 300
                    Send {e Down}
                    sleep 300
                    Send {e Up}
                    sleep 300
                    MouseMove, 682, 563, 3
                    sleep 50
                    MouseClick, Left
                    sleep 50
                    MouseClick, Left
                    sleep 200
                    MouseMove, 682, 667, 3
                    sleep 200
                    MouseClick, Left
                    sleep 800
                    loopCount := 0

                    while (loopCount < fishingLoopCount) {
                        MouseMove, 586, 287, 3
                        sleep 200
                        MouseClick, Left
                        sleep 200
                        if (sellAllToggle) {
                            MouseMove, 486, 570, 3
                        } else {
                            MouseMove, 365, 570, 3
                        }
                        sleep 200
                        MouseClick, Left
                        sleep 300
                        MouseMove, 573, 447, 3
                        sleep 200
                        MouseClick, Left
                        sleep 1000
                        loopCount++
                    }

                    MouseMove, 1050, 197, 3
                    sleep 200
                    MouseClick, Left
                    sleep 200
                    Send, {%keyA% Down}
                    sleep 1400
                    Send, {%keyA% Up}
                    sleep 75
                    Send, {%keyW% Down}
                    sleep 2670
                    Send, {%keyW% Up}
                    loopCount := 0
                } else if (pathingMode = "Abyssal Pathing") {
                    ; Abyssal Pathing
                    MouseMove, 21, 289, 3
                    sleep 200
                    MouseClick, Left
                    sleep 200
                    MouseMove, 675, 239, 3
                    sleep 200
                    MouseClick, Left
                    sleep 100
                    MouseMove, 786, 261, 3
                    sleep 100
                    MouseClick, Left
                    sleep 100
                    ClipBoard := "Abyssal Hunter"
                    sleep 100
                    Send, ^v
                    sleep 200
                    MouseMove, 584, 310, 3
                    sleep 200
                    Click, WheelUp 100
                    sleep 200
                    MouseClick, Left
                    sleep 200

                    ErrorLevel := 0
                    PixelSearch, px, py, 411, 446, 475, 460, 0xed7389, 3, Fast RGB
                    if (ErrorLevel != 0) {
                        MouseMove, 444, 452, 3
                        sleep 200
                        MouseClick, Left
                    }

                    sleep 200
                    MouseMove, 1007, 211, 3
                    sleep 200
                    MouseClick, Left
                    sleep 200

                    Send, {%keyW% Down}
                    sleep 500
                    Send, {%keyA% Down}
                    sleep 2650
                    Send, {%keyW% Up}
                    sleep 600
                    Send {%keyA% Up}
                    sleep 200
                    Send {%keyW% Down}
                    sleep 500
                    Send {%keyW% Up}
                    sleep 200
                    Send {s Down}
                    sleep 120
                    Send {s Up}
                    sleep 100
                    Send {d Down}
                    sleep 280
                    Send {d Up}
                    sleep 200
                    Send {%keyA% Down}
                    sleep 50
                    Send {Space Down}
                    sleep 730
                    Send {Space Up}
                    sleep 200
                    Send {%keyA% Up}
                    sleep 100
                    Send {%keyW% Down}
                    sleep 810
                    Send {%keyW% Up}
                    sleep 150
                    Send {space Down}
                    sleep 15
                    Send {d Down}
                    sleep 150
                    Send {space Up}
                    sleep 580
                    Send {d Up}
                    sleep 100
                    Send {e Down}
                    sleep 300
                    Send {e Up}
                    sleep 300

                    MouseMove, 699, 574, 3
                    sleep 50
                    MouseClick, Left
                    sleep 50
                    MouseClick, Left
                    sleep 200
                    MouseMove, 689, 676, 3
                    sleep 200
                    MouseClick, Left
                    sleep 800
                    loopCount := 0

                    while (loopCount < fishingLoopCount) {
                        MouseMove, 597, 294, 3
                        sleep 200
                        MouseClick, Left
                        sleep 200
                        if (sellAllToggle) {
                            MouseMove, 484, 577, 3
                        } else {
                            MouseMove, 374, 576, 3
                        }
                        sleep 200
                        MouseClick, Left
                        sleep 300
                        MouseMove, 573, 447, 3
                        sleep 200
                        MouseClick, Left
                        sleep 1000
                        loopCount++
                    }

                    MouseMove, 1047, 193, 3
                    sleep 200
                    MouseClick, Left
                    sleep 200
                    Send, {%keyA% Down}
                    sleep 800
                    Send, {%keyA% Up}
                    sleep 100
                    Send, {%keyW% Down}
                    sleep 1760
                    Send, {%keyW% Up}
                    loopCount := 0
                }
            }

            MouseMove, 603, 597, 3
            Sleep 300
            MouseClick, Left
            sleep 300
            barColor := 0
            otherBarColor := 0

            ; Check for white pixel
            startWhitePixelSearch := A_TickCount
            if (globalFailsafeTimer = 0) {
                globalFailsafeTimer := A_TickCount
            }
            fishingFailsafeRan := false
            Loop {
                ErrorLevel := 0
                PixelSearch, px, py, 866, 593, 865, 593, 0xFFFFFF, 10, Fast RGB
                if (ErrorLevel = 0) {
                    MouseMove, 676, 638, 3
                    ; Determine randomized bar color
                    Sleep 50
                    PixelGetColor, barColor, 674, 533, RGB
                    SetTimer, DoMouseMove, Off
                    break
                }

                ; Auto Rejoin Failsafe
                if (A_TickCount - globalFailsafeTimer > (autoRejoinFailsafeTime * 1000) && privateServerLink != "") {
                    PixelGetColor, checkColor, 865, 593, RGB
                    if (checkColor != 0xFFFFFF) {
                        Process, Close, RobloxPlayerBeta.exe
                        sleep 500
                        Run, % "powershell -NoProfile -Command ""Start-Process 'roblox://navigation/share_links?code=" code "&type=Server'"""
                        sleep 5000
                        WinActivate, ahk_exe RobloxPlayerBeta.exe
                        sleep 7000
                        MouseMove, 683, 384, 3
                        sleep 200
                        MouseClick, Left
                        sleep 6000

                        ; Start button
                        sleep 1000
                        Loop {
                            ErrorLevel := 0
                            PixelSearch, px, py, 160, 734, 244, 708, 0x82ff95, 5, Fast RGB
                            if (ErrorLevel = 0) {
                                sleep 1000
                                MouseMove, 200, 715, 3
                                sleep 350
                                MouseClick, Left
                                break
                            }
                        }

                        sleep 3000
                        restartPathing := true
                        try SendWebhook(":repeat: Auto Rejoin failsafe was triggered.", "3426654")
                        break
                    }
                }

                ; Fishing Failsafe
                if (A_TickCount - startWhitePixelSearch > (fishingFailsafeTime * 1000) && !fishingFailsafeRan) {
                    MouseMove, 902, 668, 3
                    sleep 300
                    MouseClick, Left
                    sleep 300
                    MouseMove, 858, 331, 3
                    sleep 300
                    MouseClick, Left
                    sleep 300
                    MouseMove, 817, 210, 3
                    sleep 300
                    MouseClick, left
                    sleep 300
                    MouseMove, 588, 588, 3
                    sleep 300
                    MouseClick, Left
                    fishingFailsafeRan := true
                    if (failsafeWebhook) {
                        try SendWebhook(":grey_question: Fishing failsafe was triggered.", "13424349")
                    }
                }
                ; Pathing Failsafe
                if (A_TickCount - startWhitePixelSearch > (pathingFailsafeTime * 1000)) {
                    restartPathing := true
                    if (failsafeWebhook) {
                        try SendWebhook(":feet: Pathing failsafe was triggered.", "6693139")
                    }
                    break
                }
                if (!toggle) {
                    Return
                }
            }

            if (restartPathing) {
                continue
            }

            ; PixelSearch loop
            startTime := A_TickCount
            Loop {
                if (!toggle)
                    break
                if (A_TickCount - startTime > 9000)
                    break

                ; Advanced detection
                if (advancedFishingDetection) {
                    ErrorLevel := 0
                    PixelSearch, leftX, leftY, 513, 531, 856, 549, barColor, 5, Fast RGB
                    if (ErrorLevel = 0) {
                        rightX := leftX
                        Loop {
                            testX := rightX + 1
                            if (testX > 856)
                                break
                            PixelGetColor, testColor, %testX%, 531, RGB
                            if (Abs((testColor & 0xFF) - (barColor & 0xFF)) <= 10 && Abs(((testColor >> 8) & 0xFF) - ((barColor >> 8) & 0xFF)) <= 10 && Abs(((testColor >> 16) & 0xFF) - ((barColor >> 16) & 0xFF)) <= 10) {
                                rightX := testX
                            } else {
                                break
                            }
                        }
                        barWidth := rightX - leftX
                        if (barWidth < advancedFishingThreshold) {
                            MouseClick, left
                            sleep 25
                        }
                    } else {
                        MouseClick, left
                    }
                    sleep 10
                } else {
                    ; Normal detection
                    ErrorLevel := 0
                    PixelSearch, FoundX, FoundY, 513, 531, 856, 549, barColor, 5, Fast RGB
                    if (ErrorLevel = 0) {
                    } else {
                        MouseClick, left
                    }
                }
            }
            sleep 300
            MouseMove, 829, 218, 3
            Sleep 700
            MouseClick, Left
            sleep 300
            cycleCount++
        }
    }
Return

StartScript:
    if (!toggle) {
        Gui, Submit, nohide

        maxLoopCount := max(MaxLoopInput, 1)
        fishingLoopCount := max(FishingLoopInput, 1)

        toggle := true
        if (hasBiomesPlugin) {
            Run, "%A_ScriptDir%\plugins\biomes.ahk"
            biomeDetectionRunning := true
        }

        if (startTick = "") {
            startTick := A_TickCount
        }

        if (cycleCount = "") {
            cycleCount := 0
        }

        WinActivate, ahk_exe RobloxPlayerBeta.exe
        ManualGUIUpdate()
        SetTimer, UpdateGUI, 1000
        switch res
        {
            case "1080p" :
                SetTimer, DoMouseMove, 100
            case "1440p" :
                SetTimer, DoMouseMove2, 100
            case "1366x768" :
                SetTimer, DoMouseMove3, 100
            default :
                SetTimer, DoMouseMove, 100
        }
        try SendWebhook(":green_circle: Macro Started!", "7909721")
    }
return

StartScript(res) {
    if (!toggle) {
        Gui, Submit, nohide

        maxLoopCount := max(MaxLoopInput, 1)
        fishingLoopCount := max(FishingLoopInput, 1)

        toggle := true
        if (hasBiomesPlugin) {
            Run, "%A_ScriptDir%\plugins\biomes.ahk"
            biomeDetectionRunning := true
        }

        if (startTick = "") {
            startTick := A_TickCount
        }

        if (cycleCount = "") {
            cycleCount := 0
        }

        WinActivate, ahk_exe RobloxPlayerBeta.exe
        ManualGUIUpdate()
        SetTimer, UpdateGUI, 1000
        switch res
        {
            case "1080p" :
                SetTimer, DoMouseMove, 100
            case "1440p" :
                SetTimer, DoMouseMove2, 100
            case "1366x768" :
                SetTimer, DoMouseMove3, 100
            default :
                SetTimer, DoMouseMove, 100
        }
        try SendWebhook(":green_circle: Macro Started!", "7909721")
    }
    return
}

PauseScript:
    if (toggle) {
        if (biomeDetectionRunning) {
            DetectHiddenWindows, On
            SetTitleMatchMode, 2

            target := "biomes.ahk"
            WinGet, id, ID, %target% ahk_class AutoHotkey
            if (id) {
                WinClose, ahk_id %id%
            }
            biomeDetectionRunning := false
        }
        toggle := false
        firstLoop := true
        SetTimer, DoMouseMove, Off
        SetTimer, DoMouseMove2, Off
        SetTimer, DoMouseMove3, Off
        SetTimer, UpdateGUI, Off
        ManualGUIUpdate()
        ToolTip
        try SendWebhook(":yellow_circle: Macro Paused", "16632664")
    }
return

CloseScript:
    if (biomeDetectionRunning) {
        DetectHiddenWindows, On
        SetTitleMatchMode, 2

        target := "biomes.ahk"
        WinGet, id, ID, %target% ahk_class AutoHotkey
        if (id) {
            WinClose, ahk_id %id%
        }
        biomeDetectionRunning := false
    }
    try SendWebhook(":red_circle: Macro Stopped.", "14495300")
ExitApp

SelectRes:
    Gui, Submit, nohide
    res := Resolution
    INI_WRITE( res, "Macro", "resolution")
    ManualGUIUpdate()
return

SelectPathing:
    Gui, Submit, nohide
    INI_WRITE( PathingMode, "Macro", "pathingMode")
    pathingMode := PathingMode
return

Dev1NameClick:
    global ClickIndex := 1
    goto DoNameClick
Dev2NameClick:
    global ClickIndex := 2
    goto DoNameClick
Dev3NameClick:
    global ClickIndex := 3
    goto DoNameClick
DoNameClick:
    if strlen(dev%ClickIndex%_website) > 0
    {
        Run, % dev%ClickIndex%_website
    }
return

Dev1LinkClick:
    global ClickIndex := 1
    goto DoLinkClick
Dev2LinkClick:
    global ClickIndex := 2
    goto DoLinkClick
Dev3LinkClick:
    global ClickIndex := 3
    goto DoLinkClick
DoLinkClick:
    if strlen(dev%ClickIndex%_link) > 0
    {
        Run, % dev%ClickIndex%_link
    }
return

DonateClick:
    Run, https://www.roblox.com/games/106268429577845/fishSol-Donations#!/store
return

NeedHelpClick:
    Run, https://discord.gg/nPvA54ShTm
return

OpenPluginsFolder:
    Run, %A_ScriptDir%\plugins
return

donoList:
    url := "https://raw.githubusercontent.com/ivelchampion249/FishSol-Macro/refs/heads/main/DONATORS.txt"
    Http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    Http.Open("GET", url, false)
    Http.Send()
    content := RTrim(Http.ResponseText, " `t`n`r") ; remove trailing spaces, new lines and carriage returns
    GuiControl, , DonatorsList, %content%
    stopBench("HTTP",13)
return