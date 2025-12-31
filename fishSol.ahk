; #Requires AutoHotkey v1.1
#NoEnv
#SingleInstance Force

;[DEV COMMENT] not yet implmented this is just the plugin compatibilty test
;#include core\RobloxWindow.ahk

#include core\log.ahk
#include core\RectPlugin.ahk

Log.Info("[PLUGIN=>""CORE""]" . " Finished Loading!")

;Core of the Fish Sols macro
CORE_PLUGIN := new CorePlugin(0,0)

#include plugins\PluginManager.ahk

SetWorkingDir %A_ScriptDir%

CoordMode, Mouse, Screen
CoordMode, Pixel, Screen

iniFilePath := A_ScriptDir "\settings.ini"

iconFilePath := A_ScriptDir "\img\icon.ico"
if (FileExist(iconFilePath)) {
    Menu, Tray, Icon, %iconFilePath%
}

global version  := "fishSol v1.9.4.260101-AltA"
global icon_url := "https://maxstellar.github.io/fishSol%20icon.png"

global res := "1080p"
global maxLoopCount := 15
global fishingLoopCount := 15
global sellAllToggle := false
global advancedFishingDetection := false
global pathingMode := "Vip Pathing"
global azertyPathing := false
global autoUnequip := false
global autoCloseChat := false
global strangeController := false
global biomeRandomizer := false
global failsafeWebhook := false
global pathingWebhook := false
global itemWebhook := false

global strangeControllerTime := 0
global biomeRandomizerTime := 360000

global strangeControllerInterval := 1260000
global biomeRandomizerInterval := 1260000

global elapsed := 0
global strangeControllerLastRun := 0
global biomeRandomizerLastRun := 0

global privateServerLink := ""
global globalFailsafeTimer := 0
global fishingFailsafeTime := 31
global pathingFailsafeTime := 61
global autoRejoinFailsafeTime := 320
global advancedFishingThreshold := 25
global webhookURL := ""

;[DEV COMMENT] added hotkeys check misc - Nadir
global Start_hotkey := "F1"
global Pause_hotkey := "F2"
global Stop_hotkey  := "F3"
global temp_regex_keybind_base := "Escape|Button|Wheel|Space|Alt|Control|Shift|Win|Tab|Left|Right|Up|Down|Enter|Backspace|\b[\w\/]\b"

;[DEV COMMENT] unused - Nadir
; auroraDetection := false 

;internal RESOURCES
    global DiscordPNG        := A_ScriptDir . "\img\Discord.png"
    global RobloxPNG         := A_ScriptDir . "\img\Robux.png"
    global Gui_Main_Png      := A_ScriptDir . "\gui\Main.png"
    global Gui_Misc_Png      := A_ScriptDir . "\gui\Misc.png"
    global Gui_Failsafe_Png  := A_ScriptDir . "\gui\Failsafes.png"
    global Gui_Webhook_Png   := A_ScriptDir . "\gui\Webhook.png"
    global Gui_Credits_Png   := A_ScriptDir . "\gui\Credits.png"
;end

;INI READING
    ;[DEV COMMENT] Mostly moved into CorePlugin at bottom of script - Nadir
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; READ THE INI VARIABLES FOR THIS PLUGIN;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        for _, plugin_class in PLUGINS_LIST
        {
            plugin_class.IniRead()
        }
    ;
;

;Randimised the Devs
    Random,, A_TickCount
    Random, messageRand, 1, 10

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
    ;
    randomMessage := randomMessages[messageRand]

    ;[DEV COMMENT] Here to make adding and randomising devs easier
    class DeveloperDetails
    {
        dev_name    := "", dev_role    := "", dev_discord := ""
        dev_img     := "", dev_website := "", dev_link    := ""

        __New(Name, Role, Discord, Image, Link, NameLink:="")
        {
            this.dev_name    := Name
            this.dev_role    := Role
            this.dev_discord := Discord
            this.dev_img     := Image
            this.dev_link    := Link
            this.dev_website := NameLink
        }
        
        click_link(index)
        {
            if strlen(dev%index%_link) > 0
            {
                Run, % dev%index%_link
            }
        }

        click_website(index)
        {
            if strlen(dev%index%_website) > 0
            {
                Run, % dev%index%_website
            }
        }
    }
    
    Devs := []
    Devs.Push(new DeveloperDetails("maxstellar"
                                 , "Twitch"
                                 , "Lead Developer"
                                 , A_ScriptDir . "\img\maxstellar.png"
                                 , "https://www.twitch.tv/maxstellar"))

    Devs.Push(new DeveloperDetails("ivelchampion249"
                                 , "YouTube"
                                 , "Original Creator"
                                 , A_ScriptDir . "\img\Ivel.png"
                                 , "https://www.youtube.com/@ivelchampion"))

    Devs.Push(new DeveloperDetails("cresqnt"
                                 , "Scope Development (other macros)"
                                 , "Frontend Developer"
                                 , A_ScriptDir . "\img\cresqnt.png"
                                 , "https://scopedevelopment.tech"
                                 , "https://cresqnt.com"))


    Randomised_DevOrder := ""

    loop % Devs.Length()
    {
        Randomised_DevOrder .= A_Index
        if (A_Index) < (Devs.Length())
            Randomised_DevOrder .= "|"
    }

    Sort, Randomised_DevOrder, Random D|
    Randomised_DevOrder := StrSplit(Randomised_DevOrder, "|")
    
    ; or just set to 3 if the list never grows
    loop % Devs.Length()
    {
        dev%A_Index%_name       := Devs[Randomised_DevOrder[A_INDEX]].dev_name
        dev%A_Index%_role       := Devs[Randomised_DevOrder[A_INDEX]].dev_role
        dev%A_Index%_discord    := Devs[Randomised_DevOrder[A_INDEX]].dev_discord
        dev%A_Index%_img        := Devs[Randomised_DevOrder[A_INDEX]].dev_img
        dev%A_Index%_link       := Devs[Randomised_DevOrder[A_INDEX]].dev_link
        dev%A_Index%_website    := Devs[Randomised_DevOrder[A_INDEX]].dev_website
    }
;
;Start Gui Creation
    ;Make Window
        Gui, New, 
        Gui, Default
        Gui, Color, 0x1E1E1E
        Gui, Font, s17 cWhite Bold, Segoe UI
        Gui, Add, Text, x0 y10 w600 h45 Center BackgroundTrans c0x00D4FF, %version%

        Gui, Font, s9 cWhite Normal, Segoe UI

        Gui, Color, 0x1E1E1E
        Gui, Add, Picture, x440 y600 w27 h19, %DiscordPNG%
        Gui, Add, Picture, x533 y601 w18 h19, %RobloxPNG%


        Gui, Font, s11 cWhite Bold Underline, Segoe UI
        Gui, Add, Text, x425 y600 w150 h38 Center BackgroundTrans c0x00FF00 gDonateClick, Donate!
        Gui, Add, Text, x325 y600 w138 h38 Center BackgroundTrans c0x00D4FF gNeedHelpClick, Need Help?

        Gui, Font, s10 cWhite Normal Bold
    ;end

    ;Tabs Creation
        ;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; adds plugin to tab list;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;
            tabList := "Main|Misc|Failsafes|Webhook" ;[DEV COMMENT] Not moved into core to preserve the order - Nadir
            for _, plugin_class in PLUGINS_LIST
            {
                tabList .= plugin_class.SetupTabList()
            }
            tabList .= "|Credits"
        ;end

        Gui, Add, Tab3, x15 y55 w570 h600 vMainTabs gTabChange c0xFFFFFF, %tabList%
        
        ;[DEV COMMENT] Mostly moved into CorePlugin at bottom of script - Nadir
        
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Setup Gui for plugins that have them;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            for _, plugin_class in PLUGINS_LIST
            {
                plugin_class.SetupGui()
            }
        ;end
    ;end
;end



;GuiControl Changes ect
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

    ;[DEV COMMENT] Multipurpose guistate and ini updator - Nadir
    Toggle_GuiControl(the_control, active, Name:="", Catagory:="Macro")
    {
        global
        local color, state, name_fix, catagory_fix
        
        color        := (active ? "+c0x00DD00" : "+c0xFF4444")
        state        := (active ? "ON" : "OFF")
        
        name_fix     := """" Name """"
        catagory_fix := """" Catagory """"

        GuiControl,, %the_control%, %state%
        GuiControl, %color%, %the_control%
        
        ;if we are given a name we know we're meant to write to the ini file
        ;   we write it :P
        if strlen(Name) > 0
            IniWrite, % (active ? "true" : "false"), %iniFilePath%, %catagory_fix%, %name_fix%
    }

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; do GuiControl checks for plugins;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    for _, plugin_class in PLUGINS_LIST
    {
        plugin_class.GuiControlChecks()
    }
;end

;;;;;;;;;;;;;;;;;;;;;;;END OF STARTUP;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;END OF STARTUP;;;;;;;;;;;;;;;;;;;;;;;
return

TabChange:
return

UpdateLoopCount:
    Gui, Submit, nohide
    if (MaxLoopInput > 0) {
        maxLoopCount := MaxLoopInput
        IniWrite, %maxLoopCount%, %iniFilePath%, "Macro", "maxLoopCount"
    }
    if (FishingLoopInput > 0) {
        fishingLoopCount := FishingLoopInput
        IniWrite, %fishingLoopCount%, %iniFilePath%, "Macro", "fishingLoopCount"
    }
return

ToggleSellAll:
    sellAllToggle := !sellAllToggle
    Toggle_GuiControl("SellAllStatus", sellAllToggle, "sellAllToggle")
return

ToggleAdvancedFishingDetection:
    advancedFishingDetection := !advancedFishingDetection
    Toggle_GuiControl("AdvancedFishingDetectionStatus", advancedFishingDetection, "sellAllToggle")
return

ToggleAzertyPathing:
    azertyPathing := !azertyPathing
    Toggle_GuiControl("AzertyPathingStatus", azertyPathing, "azertyPathing")
return

ToggleAutoUnequip:
    autoUnequip := !autoUnequip
    Toggle_GuiControl("AutoUnequipStatus", autoUnequip, "autoUnequip")
return

ToggleAutoCloseChat:
    autoCloseChat := !autoCloseChat
    Toggle_GuiControl("AutoCloseChatStatus", autoCloseChat, "autoCloseChat")
return

ToggleStrangeController:
    strangeController := !strangeController
    Toggle_GuiControl("StrangeControllerStatus", strangeController, "strangeController")
return

ToggleBiomeRandomizer:
    biomeRandomizer := !biomeRandomizer
    Toggle_GuiControl("BiomeRandomizerStatus", biomeRandomizer, "biomeRandomizer")
return

ToggleFailsafeWebhook:
    failsafeWebhook := !failsafeWebhook
    Toggle_GuiControl("failsafeWebhookStatus", failsafeWebhook, "failsafeWebhook")
return

TogglePathingWebhook:
    pathingWebhook := !pathingWebhook
    Toggle_GuiControl("pathingWebhookStatus", pathingWebhook, "pathingWebhook")
return

ToggleItemWebhook:
    itemWebhook := !itemWebhook
    Toggle_GuiControl("itemWebhookStatus", itemWebhook, "itemWebhook")
return

UpdatePrivateServer:
    Gui, Submit, nohide
    privateServerLink := PrivateServerInput
    IniWrite, %privateServerLink%, %iniFilePath%, "Macro", "privateServerLink"
return

UpdateFishingFailsafe:
    Gui, Submit, nohide
    if (FishingFailsafeInput > 0) {
        fishingFailsafeTime := FishingFailsafeInput
        IniWrite, %fishingFailsafeTime%, %iniFilePath%, "Macro", "fishingFailsafeTime"
    }
return

UpdatePathingFailsafe:
    Gui, Submit, nohide
    if (PathingFailsafeInput > 0) {
        pathingFailsafeTime := PathingFailsafeInput
        IniWrite, %pathingFailsafeTime%, %iniFilePath%, "Macro", "pathingFailsafeTime"
    }
return

UpdateAutoRejoinFailsafe:
    Gui, Submit, nohide
    if (AutoRejoinFailsafeInput > 0) {
        autoRejoinFailsafeTime := AutoRejoinFailsafeInput
        IniWrite, %autoRejoinFailsafeTime%, %iniFilePath%, "Macro", "autoRejoinFailsafeTime"
    }
return

UpdateAdvancedThreshold:
    Gui, Submit, nohide
    if (AdvancedThresholdInput >= 0 && AdvancedThresholdInput <= 40) {
        advancedFishingThreshold := AdvancedThresholdInput
        IniWrite, %advancedFishingThreshold%, %iniFilePath%, "Macro", "advancedFishingThreshold"
    }
return

UpdateWebhook:
    Gui, Submit, nohide
    webhookURL := WebhookInput
    IniWrite, %webhookURL%, %iniFilePath%, "Macro", "webhookURL"
return

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
    . "    ""footer"": {""text"": """ version """, ""icon_url"": """ . icon_url . " ""},"
    . "    ""timestamp"": """ timestamp """"
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
            PixelSearch, Px, Py, 491, 711s, 749, 723, 0x457dff, 3, Fast RGB
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
        GuiControl, +c0x00DD00, StatusText
        GuiControl,, ResStatusText, Active - %res%

        elapsed := A_TickCount - startTick
        hours := elapsed // 3600000
        minutes := (elapsed - hours * 3600000) // 60000
        seconds := (elapsed - hours * 3600000 - minutes * 60000) // 1000
        timeStr := Format("{:02d}:{:02d}:{:02d}", hours, minutes, seconds)
        GuiControl,, RuntimeText, %timeStr%
        GuiControl, +c0x00DD00, RuntimeText
        GuiControl,, CyclesText, %cycleCount%
        GuiControl, +c0x00DD00, CyclesText


    } else {
        GuiControl,, StatusText, Stopped
        GuiControl, +c0xFF4444, StatusText
        GuiControl,, ResStatusText, Ready
    }
return

ManualGUIUpdate() {
    if (toggle) {
        GuiControl,, StatusText, Running
        GuiControl, +c0x00DD00, StatusText
        GuiControl,, ResStatusText, Active - %res%

        elapsed := A_TickCount - startTick
        hours := elapsed // 3600000
        minutes := (elapsed - hours * 3600000) // 60000
        seconds := (elapsed - hours * 3600000 - minutes * 60000) // 1000
        timeStr := Format("{:02d}:{:02d}:{:02d}", hours, minutes, seconds)
        GuiControl,, RuntimeText, %timeStr%
        GuiControl, +c0x00DD00, RuntimeText
        GuiControl,, CyclesText, %cycleCount%
        GuiControl, +c0x00DD00, CyclesText


    } else {
        GuiControl,, StatusText, Stopped
        GuiControl, +c0xFF4444, StatusText
        GuiControl,, ResStatusText, Ready
    }
}

START_SCRIPT:
    if (!res) {
        res := "1080p"
    }
    if (!toggle) {
        Gui, Submit, nohide
        GuiControl, Disable, AllowStartRebind_CHECKBOX
        GuiControl, Disable, AllowPauseRebind_CHECKBOX
        GuiControl, Disable, AllowStopRebind_CHECKBOX
        GuiControl, Hide, AllowStartRebind_CHECKBOX
        GuiControl, Hide, AllowPauseRebind_CHECKBOX
        GuiControl, Hide, AllowStopRebind_CHECKBOX
        if (MaxLoopInput > 0) {
            maxLoopCount := MaxLoopInput
        }
        if (FishingLoopInput > 0) {
            fishingLoopCount := FishingLoopInput
        }
        toggle := true
        Return
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
        IniWrite, %res%, %iniFilePath%, "Macro", "resolution"
        IniWrite, %maxLoopCount%, %iniFilePath%, "Macro", "maxLoopCount"
        IniWrite, %fishingLoopCount%, %iniFilePath%, "Macro", "fishingLoopCount"

        WinActivate, ahk_exe RobloxPlayerBeta.exe
        ManualGUIUpdate()
        SetTimer, UpdateGUI, 1000
        if (res = "1080p") {
            SetTimer, DoMouseMove, 100
        } else if (res = "1440p") {
            SetTimer, DoMouseMove2, 100
        } else if (res = "1366x768") {
            SetTimer, DoMouseMove3, 100
        }
        try SendWebhook(":green_circle: Macro Started!", "7909721")
    }
Return

PAUSE_SCRIPT:
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
        GuiControl, Enable, AllowStartRebind_CHECKBOX
        GuiControl, Enable, AllowPauseRebind_CHECKBOX
        GuiControl, Enable, AllowStopRebind_CHECKBOX
        GuiControl, Show, AllowStartRebind_CHECKBOX
        GuiControl, Show, AllowPauseRebind_CHECKBOX
        GuiControl, Show, AllowStopRebind_CHECKBOX
        ToolTip
        try SendWebhook(":yellow_circle: Macro Paused", "16632664")
    }
Return

STOP_SCRIPT:
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
                Send, {Esc}
                Sleep, 650
                Send, R
                Sleep, 650
                Send, {Enter}
                sleep 2600

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
        if (loopCount > maxLoopCount || restartPathing) {
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

        Send, {Esc}
        Sleep, 650
        Send, R
        Sleep, 650
        Send, {Enter}
        sleep 2600
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
        /*
        Loop {
        PixelGetColor, color, 1112, 342, RGB
        if (color = 0xFFFFFF) {
        break
        }
        if (!toggle) {
        Return
        }
        }
        */
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
                Send, {Esc}
                Sleep, 650
                Send, R
                Sleep, 650
                Send, {Enter}
                sleep 2600

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
        if (loopCount > maxLoopCount || restartPathing) {
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
        sleep 500
        Send, {Esc}
        sleep 650
        Send, {r}
        sleep 650
        Send, {Enter}
        sleep 2600
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
        /*
        Loop {
        PixelGetColor, color, 1455, 492, RGB
        if (color = 0xFFFFFF) {
        break
        }
        if (!toggle) {
        Return
        }
        }
        */
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
                Send, {Esc}
                Sleep, 650
                Send, R
                Sleep, 650
                Send, {Enter}
                sleep 2600

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
        if (loopCount > maxLoopCount || restartPathing) {
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
        Send, {Esc}
        Sleep, 650
        Send, R
        Sleep, 650
        Send, {Enter}
        sleep 2600
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
        /*
        Loop {
        ErrorLevel := 0
        PixelSearch, px, py, 816, 211, 8616, 211, 0xFEFEFE, 10, Fast RGB
        if (ErrorLevel = 0) {
        break
        }
        if (!toggle) {
        Return
        }
        }
        */
        MouseClick, Left
        sleep 300
        cycleCount++
    }
    }
Return

; StartScript(res) {
 ;    if (!toggle) {
 ;        Gui, Submit, nohide
 ;        if (MaxLoopInput > 0) {
 ;            maxLoopCount := MaxLoopInput
 ;        }
 ;        if (FishingLoopInput > 0) {
 ;            fishingLoopCount := FishingLoopInput
 ;        }
 ;        toggle := true
 ;        if (hasBiomesPlugin) {
 ;            Run, "%A_ScriptDir%\plugins\biomes.ahk"
 ;            biomeDetectionRunning := true
 ;        }
 ;        if (startTick = "") {
 ;            startTick := A_TickCount
 ;        }
 ;        if (cycleCount = "") {
 ;            cycleCount := 0
 ;        }
 ;        WinActivate, ahk_exe RobloxPlayerBeta.exe
 ;        ManualGUIUpdate()
 ;        GuiControl, Hide, AllowStartRebind_CHECKBOX
 ;        GuiControl, Hide, AllowPauseRebind_CHECKBOX
 ;        GuiControl, Hide, AllowStopRebind_CHECKBOX
 ;        SetTimer, UpdateGUI, 1000
 ;        if (res = "1080p") {
 ;            SetTimer, DoMouseMove, 100
 ;        } else if (res = "1440p") {
 ;            SetTimer, DoMouseMove2, 100
 ;        } else if (res = "1366x768") {
 ;            SetTimer, DoMouseMove3, 100
 ;        }
 ;        try SendWebhook(":green_circle: Macro Started!", "7909721")
 ;    }
 ;    return
; }

SelectRes:
    Gui, Submit, nohide
    res := Resolution
    IniWrite, %res%, %iniFilePath%, "Macro", "resolution"
    ManualGUIUpdate()
return

SelectPathing:
    Gui, Submit, nohide
    IniWrite, %PathingMode%, %iniFilePath%, "Macro", "pathingMode"
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
; ; Example Expansion
; Dev4NameClick:
;     global ClickIndex := 4
;     goto DoNameClick
DoNameClick:
    DeveloperDetails.click_website(ClickIndex)
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
; ; Example Expansion
; Dev4LinkClick:
;     global ClickIndex := 4
; goto DoLinkClick
DoLinkClick:
    DeveloperDetails.click_link(ClickIndex)
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

;HotKey Rebinding
    AllowStartRebind:
        Hotkey, %Start_hotkey%, Off
        GuiControl, Enable, Start_hotkey_REBIND
        GuiControl, Disable, StartBtn
        GuiControl, Disable, PauseBtn
        GuiControl, Disable, StopBtn
        GuiControl, Show, Start_hotkey_REBIND_BUTTON
        GuiControl, Hide, AllowStartRebind_CHECKBOX
    return

    RebindHotkeyStart:
        Gui, Submit, nohide
        REGEX_KEYS_CHECK := temp_regex_keybind_base . "|" . Pause_hotkey . "|" . Stop_hotkey

        if not (Start_hotkey_REBIND ~= REGEX_KEYS_CHECK or GetKeyName(Start_hotkey_REBIND) ~= REGEX_KEYS_CHECK)
        {
            Hotkey, %Start_hotkey_REBIND%, START_SCRIPT,  On
            Start_hotkey := Start_hotkey_REBIND
            GuiControl,, KeybindLabelMainTab, Hotkeys: %Start_hotkey%=Start - %Pause_hotkey%=Pause - %Stop_hotkey%=Stop
            IniWrite, %Start_hotkey%, %iniFilePath%, "Keybinds", "StartScript"
        }
        GuiControl, Disable, Start_hotkey_REBIND
        GuiControl, Enable, StartBtn
        GuiControl, Enable, PauseBtn
        GuiControl, Enable, StopBtn
        GuiControl, Hide, Start_hotkey_REBIND_BUTTON
        GuiControl, Show, AllowStartRebind_CHECKBOX
        GuiControl, , AllowStartRebind_CHECKBOX, 0
    return

    AllowPauseRebind:
        Hotkey, %Pause_hotkey%, Off
        GuiControl, Enable, Pause_hotkey_REBIND
        GuiControl, Disable, StartBtn
        GuiControl, Disable, PauseBtn
        GuiControl, Disable, StopBtn
        GuiControl, Show, Pause_hotkey_REBIND_BUTTON
        GuiControl, Hide, AllowPauseRebind_CHECKBOX
    return

    RebindHotkeyPause:
        Gui, Submit, nohide
        REGEX_KEYS_CHECK := temp_regex_keybind_base . "|" . Start_hotkey . "|" . Stop_hotkey
        
        if not (Pause_hotkey_REBIND ~= REGEX_KEYS_CHECK or GetKeyName(Pause_hotkey_REBIND) ~= REGEX_KEYS_CHECK)
        {
            Hotkey, %Pause_hotkey_REBIND%, PAUSE_SCRIPT, On
            Pause_hotkey := Pause_hotkey_REBIND
            GuiControl,, KeybindLabelMainTab, Hotkeys: %Start_hotkey%=Start - %Pause_hotkey%=Pause - %Stop_hotkey%=Stop
            IniWrite, %Pause_hotkey%, %iniFilePath%, "Keybinds", "PauseScript"
        }
        GuiControl, Disable, Pause_hotkey_REBIND
        GuiControl, Enable, StartBtn
        GuiControl, Enable, PauseBtn
        GuiControl, Enable, StopBtn
        GuiControl, Hide, Pause_hotkey_REBIND_BUTTON
        GuiControl, Show, AllowPauseRebind_CHECKBOX
        GuiControl, , AllowPauseRebind_CHECKBOX, 0
    return

    AllowStopRebind:
        Hotkey, %Stop_hotkey%, Off
        GuiControl, Enable, Stop_hotkey_REBIND
        GuiControl, Disable, StartBtn
        GuiControl, Disable, PauseBtn
        GuiControl, Disable, StopBtn
        GuiControl, Show, Stop_hotkey_REBIND_BUTTON
        GuiControl, Hide, AllowStopRebind_CHECKBOX
    return

    RebindHotkeyStop:
        Gui, Submit, nohide
        REGEX_KEYS_CHECK := temp_regex_keybind_base . "|" . Start_hotkey . "|" . Pause_hotkey

        if not (Stop_hotkey_REBIND ~= REGEX_KEYS_CHECK or GetKeyName(Stop_hotkey_REBIND) ~= REGEX_KEYS_CHECK)
        {
            Hotkey, %Stop_hotkey_REBIND%, STOP_SCRIPT, On
            Stop_hotkey := Stop_hotkey_REBIND
            GuiControl,, KeybindLabelMainTab, Hotkeys: %Start_hotkey%=Start - %Pause_hotkey%=Pause - %Stop_hotkey%=Stop
            IniWrite, %Stop_hotkey%, %iniFilePath%, "Keybinds", "StopScript"
        }
        GuiControl, Disable, Stop_hotkey_REBIND
        GuiControl, Enable, StartBtn
        GuiControl, Enable, PauseBtn
        GuiControl, Enable, StopBtn
        GuiControl, Hide, Stop_hotkey_REBIND_BUTTON
        GuiControl, Show, AllowStopRebind_CHECKBOX
        GuiControl, , AllowStopRebind_CHECKBOX, 0
    return
;

class CorePlugin extends Plugin
{

    ;OVERRIDE THIS FUNCTION AND CALL |PLUGIN_NAME|.RUN()
    PluginRun()
    {}

    ;OVERRIDE THIS FUNCTION TO ADD STUFF ON CREATION
    PluginSetup()
    {
        ; global
        ; local
    }

    ;OVERRIDE THIS FUNCTION TO ADD STUFF ON CREATION
    SetupTabList()
    {
        ret := "Main|Misc|Failsafes|Webhook"
        return "" ; i'm not sure this will ever be called first so for now im doing this manually
    }

    ;OVERRIDE THIS FUNCTION TO ADD STUFF TO CLASS ON CREATION
    SetupGui()
    {
        global
        local yFULL_OFFSET, yoff1, yoff2, yoff3, yoff4, dev_img, dev_name, dev_role, dev_discord 
        ;Main Tab
            Gui, Tab, Main

            Gui, Add, Picture, x14 y60 w574 h590, %Gui_Main_Png%

            Gui, Color, 0x1E1E1E
            Gui, Add, Picture, x440 y600 w27 h19, %DiscordPNG%
            Gui, Add, Picture, x533 y601 w18 h19, %RobloxPNG%

            Gui, Font, s11 cWhite Bold Underline, Segoe UI
            Gui, Add, Text, x425 y600 w150 h38 Center BackgroundTrans c0x00FF00 gDonateClick, Donate!
            Gui, Add, Text, x325 y600 w138 h38 Center BackgroundTrans c0x00D4FF gNeedHelpClick, Need Help?


            Gui, Font, s11 cWhite Normal Bold
            Gui, Add, Text, x45 y110 w60 h25 BackgroundTrans, Status:
            Gui, Add, Text, x98 y110 w150 h25 vStatusText BackgroundTrans c0xFF4444, Stopped

            Gui, Font, s10 cWhite Bold, Segoe UI
            Gui, Add, Button, x45 y140 w70 h35 gSTART_SCRIPT vStartBtn c0x00AA00 +0x8000, Start
            Gui, Add, Button, x125 y140 w70 h35 gPAUSE_SCRIPT vPauseBtn c0xFFAA00 +0x8000, Pause
            Gui, Add, Button, x205 y140 w70 h35 gSTOP_SCRIPT vStopBtn c0xFF4444 +0x8000, Stop

            Gui, Font, s8 c0xCCCCCC
            Gui, Add, Text, x45 y185 w240 h15 BackgroundTrans vKeybindLabelMainTab, Hotkeys: F1=Start - F2=Pause - F3=Stop



            Gui, Font, s10 cWhite Bold, Segoe UI
            Gui, Font, s10 cWhite Bold
            Gui, Add, Text, x320 y110 w80 h25 BackgroundTrans, Resolution:
            Gui, Add, DropDownList, x320 y135 w120 h200 vResolution gSelectRes, 1080p|1440p|1366x768

            Gui, Font, s9 cWhite Bold, Segoe UI
            Gui, Add, Text, x320 y165 w220 h25 vResStatusText BackgroundTrans, Ready

            Gui, Font, s10 cWhite Bold
            Gui, Add, Button, x450 y135 w100 h25 gToggleSellAll vSellAllBtn, Toggle Sell All
            Gui, Font, s8 c0xCCCCCC
            Gui, Add, Text, x450 y165 w100 h25 vSellAllStatus BackgroundTrans, OFF

            Gui, Font, s10 cWhite Bold, Segoe UI
            Gui, Font, s10 cWhite Bold
            Gui, Add, Text, x45 y240 w180 h25 BackgroundTrans, Fishing Loop Count:
            Gui, Add, Edit, x220 y238 w60 h25 vMaxLoopInput gUpdateLoopCount Number Background0xD3D3D3 cBlack, %maxLoopCount%
            Gui, Font, s8 c0xCCCCCC
            Gui, Add, Text, x285 y242 w270 h15 BackgroundTrans, (Fishing Cycles Before Reset - default: 15)
            Gui, Font, s10 cWhite Bold
            Gui, Add, Text, x45 y270 w180 h25 BackgroundTrans, Sell Loop Count:
            Gui, Add, Edit, x220 y268 w60 h25 vFishingLoopInput gUpdateLoopCount Number Background0xD3D3D3 cBlack, %fishingLoopCount%
            Gui, Font, s8 c0xCCCCCC
            Gui, Add, Text, x285 y272 w270 h15 BackgroundTrans, (Sell Cycles  -  If Sell All: 22)
            Gui, Font, s10 cWhite Bold
            Gui, Add, Text, x45 y301 w120 h25 BackgroundTrans, Pathing Mode:
            Gui, Add, DropDownList, x145 y298 w135 h200 vPathingMode gSelectPathing, Vip Pathing|Non Vip Pathing|Abyssal Pathing

            Gui, Add, Text, x295 y301 w120 h25 BackgroundTrans, AZERTY Pathing:
            Gui, Add, Button, x415 y298 w80 h25 gToggleAzertyPathing vAzertyPathingBtn, Toggle
            Gui, Font, s10 c0xCCCCCC Bold, Segoe UI
            Gui, Add, Text, x510 y303 w60 h25 vAzertyPathingStatus BackgroundTrans, OFF

            Gui, Font, s10 cWhite Bold

            Gui, Color, 0x1E1E1E
            Gui, Font, s10 cWhite Bold, Segoe UI

            Gui, Font, s11 c0xFF2C00 Bold
            Gui, Font, s10 cWhite Bold
            Gui, Add, Button, x270 y380 w80 h25 gToggleAdvancedFishingDetection vAdvancedFishingDetectionBtn, Toggle
            Gui, Font, s10 c0xCCCCCC Bold, Segoe UI
            Gui, Add, Text, x360 y384 w60 h25 vAdvancedFishingDetectionStatus BackgroundTrans, OFF

            Gui, Font, s9 cWhite Bold, Segoe UI
            Gui, Add, Text, x270 y415 w260 cWhite BackgroundTrans, Advanced Detection Threshold -
            Gui, Font, s9 cWhite Normal
            Gui, Add, Text, x270 y435 w270 h40 BackgroundTrans c0xCCCCCC, Customize how many pixels are left in the fishing range before clicking.
            Gui, Font, s10 cWhite Bold
            Gui, Add, Text, x400 y384 w80 h25 BackgroundTrans, Pixels:
            Gui, Font, s9 cWhite Bold
            Gui, Add, Text, x453 y416 w120 BackgroundTrans c0xFF4444, Max : 40 Pixels
            Gui, Font, s10 cWhite Bold
            Gui, Add, Edit, x455 y380 w75 h25 vAdvancedThresholdInput gUpdateAdvancedThreshold Number Background0xD3D3D3 cBlack, %advancedFishingThreshold%

            Gui, Font, s9 c0xCCCCCC Normal
            Gui, Add, Text, x50 y470 w515 h30 BackgroundTrans, Advanced Fishing Detection uses a system that clicks slightly before the bar exits the fish range, making the catch rate higher than ever.

            Gui, Font, s9 c0x00D4FF Bold
            Gui, Add, Text, x307 y485 w515 h30 BackgroundTrans c0x00D4FF, [ Recommended For Lower End Devices ]

            Gui, Font, s11 cWhite Bold, Segoe UI
            Gui, Add, Text, x50 y375 w100 h30 BackgroundTrans, Runtime:
            Gui, Add, Text, x120 y375 w120 h30 vRuntimeText BackgroundTrans c0x00DD00, 00:00:00

            Gui, Add, Text, x50 y405 w100 h30 BackgroundTrans, Cycles:
            Gui, Add, Text, x102 y405 w120 h30 vCyclesText BackgroundTrans c0x00DD00, 0

            Gui, Font, s9 c0xCCCCCC Normal
            Gui, Add, Text, x50 y545 w500 h20 BackgroundTrans, Requirements: 100`% Windows scaling - Roblox in fullscreen mode
            Gui, Add, Text, x50 y563 w500 h20 BackgroundTrans, For best results, make sure you have good internet and avoid screen overlays

        ;end

        ;Misc Tab
            Gui, Tab, Misc

            Gui, Add, Picture, x14 y80 w574 h590, %Gui_Misc_Png%

            Gui, Font, s10 cWhite Bold, Segoe UI
            Gui, Font, s9 cWhite Normal
            Gui, Add, Text, x45 y135 h45 w250 BackgroundTrans c0xCCCCCC, Automatically unequips rolled auras every pathing cycle, preventing lag and pathing issues.
            Gui, Font, s10 cWhite Bold
            Gui, Add, Button, x45 y188 w80 h25 gToggleAutoUnequip vAutoUnequipBtn, Toggle
            Gui, Font, s10 c0xCCCCCC Bold, Segoe UI
            Gui, Add, Text, x140 y192 w60 h25 vAutoUnequipStatus BackgroundTrans, OFF
            Gui, Font, s10 cWhite Bold, Segoe UI

            Gui, Font, s11 cWhite Bold
            Gui, Add, Text, x45 y260 w150 h25 BackgroundTrans, Strange Controller:
            Gui, Add, Text, x45 y303 w190 h25 BackgroundTrans, Biome Randomizer:
            Gui, Font, s10 cWhite Bold
            Gui, Add, Button, x200 y270 w80 h25 gToggleStrangeController vStrangeControllerBtn, Toggle
            Gui, Add, Button, x200 y314 w80 h25 gToggleBiomeRandomizer vBiomeRandomizerBtn, Toggle
            Gui, Font, s10 c0xCCCCCC Bold, Segoe UI
            Gui, Add, Text, x290 y275 w60 h25 vStrangeControllerStatus BackgroundTrans, OFF
            Gui, Add, Text, x290 y319 w60 h25 vBiomeRandomizerStatus BackgroundTrans, OFF

            Gui, Add, Progress, x41 y270 w1 h27 Background696868
            Gui, Add, Progress, x190 y270 w1 h27 Background696868
            Gui, Add, Progress, x41 y296 w149 h1 Background696868
            Gui, Add, Progress, x184 y269 w7 h1 Background696868
            Gui, Font, s10 cWhite Normal
            Gui, Add, Text, x47 y278 w500 h40 BackgroundTrans c0xCCCCCC, Uses every 21 minutes.

            Gui, Font, s10 cWhite Normal
            Gui, Add, Text, x327 y275 w500 h15 BackgroundTrans, Automatically uses Strange Controller.

            Gui, Add, Progress, x41 y313 w1 h27 Background696868
            Gui, Add, Progress, x190 y313 w1 h27 Background696868
            Gui, Add, Progress, x41 y339 w149 h1 Background696868
            Gui, Add, Progress, x184 y313 w7 h1 Background696868
            Gui, Font, s10 cWhite Normal
            Gui, Add, Text, x47 y321 w500 h40 BackgroundTrans c0xCCCCCC, Uses every 36 minutes.

            Gui, Font, s10 cWhite Normal
            Gui, Add, Text, x327 y319 w500 h15 BackgroundTrans, Automatically uses Biome Randomizer.

            Gui, Font, s10 cWhite Bold, Segoe UI
            Gui, Font, s9 cWhite Normal
            Gui, Add, Text, x320 y135 w230 h60 BackgroundTrans c0xCCCCCC, Automatically closes chat every pathing cycle to ensure you don't get stuck in collection.
            Gui, Font, s10 cWhite Bold
            Gui, Add, Button, x320 y188 w80 h25 gToggleAutoCloseChat vAutoCloseChatBtn, Toggle
            Gui, Font, s10 c0xCCCCCC Bold, Segoe UI
            Gui, Add, Text, x415 y192 w60 h25 vAutoCloseChatStatus BackgroundTrans, OFF

            Gui, Color, 0x1E1E1E
            Gui, Add, Picture, x445 y600 w27 h19, %DiscordPNG%
            Gui, Add, Picture, x538 y601 w18 h19, %RobloxPNG%

            Gui, Font, s11 cWhite Bold Underline, Segoe UI
            Gui, Add, Text, x430 y600 w150 h38 Center BackgroundTrans c0x00FF00 gDonateClick, Donate!
            Gui, Add, Text, x330 y600 w138 h38 Center BackgroundTrans c0x00D4FF gNeedHelpClick, Need Help?
            
            ;[DEV COMMENT] Please replace with better system if one comes along - Nadir
            ;Hotkey sub menu in misc
                Gui, Font, s11 cWhite Normal
                Gui, Font, s11 cWhite Bold
                Gui, Add, Text, x47 y383 w150 h25 BackgroundTrans, Start`tHotkey:
                Gui, Add, Text, x47 y427 w150 h25 BackgroundTrans, Pause`tHotkey:
                Gui, Add, Text, x47 y471 w150 h25 BackgroundTrans, Stop`tHotKey:
                
                Gui, Add, Progress, x41 y392 w1 h27 Background696868
                Gui, Add, Progress, x190 y392 w1 h27 Background696868
                Gui, Add, Progress, x41 y418 w149 h1 Background696868
                Gui, Add, Progress, x184 y392 w7 h1 Background696868
                Gui, Font, s10 cWhite Normal
                Gui, Add, Text, x47 y400 w500 h40 BackgroundTrans c0xCCCCCC, Rebind Start hotkey
                Gui, Add, Hotkey, Limit129 vStart_hotkey_REBIND x225 y392 w80 h25 Center, F1
                Gui, Add, Checkbox, x200 y392 w25 h25 gAllowStartRebind vAllowStartRebind_CHECKBOX
                Gui, Font, s10 cWhite Bold
                Gui, Add, Button, gRebindHotkeyStart x320 y392 h25 w80 vStart_hotkey_REBIND_BUTTON, Accept
                
                Gui, Add, Progress, x41 y436 w1 h27 Background696868
                Gui, Add, Progress, x190 y436 w1 h27 Background696868
                Gui, Add, Progress, x41 y462 w149 h1 Background696868
                Gui, Add, Progress, x184 y436 w7 h1 Background696868
                Gui, Font, s10 cWhite Normal
                Gui, Add, Text, x47 y444 w500 h40 BackgroundTrans c0xCCCCCC, Rebind Pause hotkey
                Gui, Add, Hotkey, Limit129 vPause_hotkey_REBIND x225 y436 w80 h25 Center, F2
                Gui, Add, Checkbox, x200 y436 w25 h25 gAllowPauseRebind vAllowPauseRebind_CHECKBOX 
                Gui, Font, s10 cWhite Bold
                Gui, Add, Button, gRebindHotkeyPause x320 y436 h25 w80 vPause_hotkey_REBIND_BUTTON, Accept
                
                Gui, Add, Progress, x41 y480 w1 h27 Background696868
                Gui, Add, Progress, x190 y480 w1 h27 Background696868
                Gui, Add, Progress, x41 y506 w149 h1 Background696868
                Gui, Add, Progress, x184 y480 w7 h1 Background696868
                Gui, Font, s10 cWhite Normal
                Gui, Add, Text, x47 y488 w500 h40 BackgroundTrans c0xCCCCCC , Rebind Pause hotkey
                Gui, Add, Hotkey, Limit129 vStop_hotkey_REBIND x225 y480 w80 h25 Center, F3
                Gui, Add, Checkbox, x200 y480 w25 h25 gAllowStopRebind vAllowStopRebind_CHECKBOX
                Gui, Font, s10 cWhite Bold
                Gui, Add, Button, gRebindHotkeyStop x320 y480 h25 w80 vStop_hotkey_REBIND_BUTTON, Accept

                ;[DEV COMMENT] read the keybinds from the ini into the boxes and label at start
                GuiControl,, Start_hotkey_REBIND, %Start_hotkey%
                GuiControl,, Pause_hotkey_REBIND, %Pause_hotkey%
                GuiControl,, Stop_hotkey_REBIND, %Stop_hotkey%

                GuiControl,, KeybindLabelMainTab, Hotkeys: %Start_hotkey%=Start - %Pause_hotkey%=Pause - %Stop_hotkey%=Stop
                
                ;disable the controls for when the binding checkbox is clicked
                GuiControl, Disable, Start_hotkey_REBIND
                GuiControl, Disable, Pause_hotkey_REBIND
                GuiControl, Disable, Stop_hotkey_REBIND
                
                GuiControl, Hide, Start_hotkey_REBIND_BUTTON
                GuiControl, Hide, Pause_hotkey_REBIND_BUTTON
                GuiControl, Hide, Stop_hotkey_REBIND_BUTTON
            ;end

            Gui, Font, s11 cWhite Bold Underline, Segoe UI
        ;end

        ;Failsafes
            Gui, Tab, Failsafes

            Gui, Add, Picture, x14 y80 w574 h590, %Gui_Failsafe_Png%

            Gui, Font, s10 cWhite Normal
            Gui, Add, Text, x50 y140 w500 h40 BackgroundTrans c0xCCCCCC, If the fishing minigame is not detected for the specified time, the macro will`nautomatically rejoin using the private server link below.

            Gui, Font, s10 cWhite Bold
            Gui, Add, Text, x50 y190 w150 h25 BackgroundTrans, Private Server Link:
            Gui, Add, Edit, x50 y215 w500 h25 vPrivateServerInput gUpdatePrivateServer Background0xD3D3D3 cBlack, %privateServerLink%

            Gui, Font, s8 c0xCCCCCC Normal
            Gui, Add, Text, x50 y245 w500 h15 BackgroundTrans, Paste your Roblox private server link here (leave empty to disable)

            Gui, Font, s10 cWhite Normal
            Gui, Add, Text, x79 y306 w450 h40 BackgroundTrans c0xCCCCCC, Customize how long until the Auto-Rejoin Failsafe triggers. (Default : 320)

            Gui, Font, s11 cWhite Bold
            Gui, Add, Text, x145 y275 w150 h25 BackgroundTrans, Seconds:
            Gui, Add, Edit, x218 y272 w150 h25 vAutoRejoinFailsafeInput gUpdateAutoRejoinFailsafe Number Background0xD3D3D3 cBlack, %autoRejoinFailsafeTime%

            Gui, Font, s10 cWhite Bold, Segoe UI

            Gui, Font, s9 cWhite Normal
            Gui, Add, Text, x45 y370 w230 h40 BackgroundTrans c0xCCCCCC, Customize how long until the Fishing Failsafe triggers. (Default : 31)

            Gui, Font, s11 cWhite Bold
            Gui, Add, Text, x45 y413 w150 h35 BackgroundTrans, Seconds:
            Gui, Add, Edit, x125 y411 w150 h25 vFishingFailsafeInput gUpdateFishingFailsafe Number Background0xD3D3D3 cBlack, %fishingFailsafeTime%

            Gui, Font, s10 cWhite Bold, Segoe UI

            Gui, Font, s9 cWhite Normal
            Gui, Add, Text, x320 y370 w230 h45 BackgroundTrans c0xCCCCCC, Customize how long until the Pathing Failsafe triggers. (Default : 61)

            Gui, Font, s11 cWhite Bold
            Gui, Add, Text, x320 y413 w150 h35 BackgroundTrans, Seconds:
            Gui, Add, Edit, x400 y411 w150 h25 vPathingFailsafeInput gUpdatePathingFailsafe Number Background0xD3D3D3 cBlack, %pathingFailsafeTime%

            Gui, Color, 0x1E1E1E
            Gui, Add, Picture, x445 y600 w27 h19, %DiscordPNG%
            Gui, Add, Picture, x538 y601 w18 h19, %RobloxPNG%

            Gui, Font, s11 cWhite Bold Underline, Segoe UI
            Gui, Add, Text, x430 y600 w150 h38 Center BackgroundTrans c0x00FF00 gDonateClick, Donate!
            Gui, Add, Text, x330 y600 w138 h38 Center BackgroundTrans c0x00D4FF gNeedHelpClick, Need Help?

        ;end

        ;Webhook Tab
            Gui, Tab, Webhook

            Gui, Add, Picture, x14 y80 w574 h590, %Gui_Webhook_Png%

            Gui, Font, s10 cWhite Normal Bold
            Gui, Add, Text, x50 y125 w200 h25 BackgroundTrans, Discord Webhook URL:
            Gui, Add, Edit, x50 y150 w500 h25 vWebhookInput gUpdateWebhook Background0xD3D3D3 cBlack, %webhookURL%
            Gui, Font, s8 c0xCCCCCC Normal
            Gui, Add, Text, x50 y180 w500 h15 BackgroundTrans, Paste your Discord webhook URL here to be notified of actions happening in real time.

            Gui, Font, s10 cWhite Normal
            Gui, Add, Text, x60 y246 w500 h40 BackgroundTrans c0xCCCCCC, When toggled, this sends a message when a failsafe triggers.
            Gui, Add, Text, x60 y316 w500 h40 BackgroundTrans c0xCCCCCC, When toggled, this sends a message when the macro paths to auto-sell.
            Gui, Add, Text, x60 y386 w500 h40 BackgroundTrans c0xCCCCCC, When toggled, this sends a message when items are used (eg. Strange Controller, Biome Randomizer).

            Gui, Font, s10 cWhite Bold
            Gui, Add, Button, x60 y216 w80 h25 gToggleFailsafeWebhook vFailsafeWebhookBtn, Toggle
            Gui, Add, Text, x150 y220 w60 h25 vfailsafeWebhookStatus BackgroundTrans, OFF
            Gui, Add, Button, x60 y286 w80 h25 gTogglePathingWebhook vPathingWebhookBtn, Toggle
            Gui, Add, Text, x150 y290 w60 h25 vpathingWebhookStatus BackgroundTrans, OFF
            Gui, Add, Button, x60 y356 w80 h25 gToggleItemWebhook vItemWebhookBtn, Toggle
            Gui, Add, Text, x150 y360 w60 h25 vitemWebhookStatus BackgroundTrans, OFF

            Gui, Color, 0x1E1E1E
            Gui, Add, Picture, x445 y600 w27 h19, %DiscordPNG%
            Gui, Add, Picture, x538 y601 w18 h19, %RobloxPNG%

            Gui, Font, s11 cWhite Bold Underline, Segoe UI
            Gui, Add, Text, x430 y600 w150 h38 Center BackgroundTrans c0x00FF00 gDonateClick, Donate!
            Gui, Add, Text, x330 y600 w138 h38 Center BackgroundTrans c0x00D4FF gNeedHelpClick, Need Help?
        ;end

        ;Credits Tab
            Gui, Tab, Credits
            Gui, Add, Picture, x14 y80 w574 h590, %Gui_Credits_Png%

            Gui, Font, s10 cWhite Normal
            loop % Devs.Count()
            {
                ;y offset 65
                yFULL_OFFSET := 65 * (A_INDEX - 1)
                yoff1 := 130 + yFULL_OFFSET
                yoff2 := 135 + yFULL_OFFSET
                yoff3 := 155 + yFULL_OFFSET
                yoff4 := 170 + yFULL_OFFSET
                dev_img     := "dev" A_INDEX "_img"
                dev_name    := "dev" A_INDEX "_name"
                dev_role    := "dev" A_INDEX "_role"
                dev_discord := "dev" A_INDEX "_discord"
                dev_img     := %dev_img%
                dev_name    := %dev_name%
                dev_role    := %dev_role%
                dev_discord := %dev_discord%
                Gui, Font, s11 cWhite Normal Bold
                Gui, Add, Picture, x50 y%yoff1% w50 h50, %dev_img%

                Gui, Add, Text, x110 y%yoff2% w200 h20 BackgroundTrans c0x0088FF gDev%A_Index%NameClick, %dev_name%

                Gui, Font, s9 c0xCCCCCC Normal
                Gui, Add, Text, x110 y%yoff3% w300 h15 BackgroundTrans, %dev_role%
                Gui, Font, s9 c0xCCCCCC Normal Underline
                Gui, Add, Text, x110 y%yoff4% w300 h15 BackgroundTrans c0x0088FF gDev%A_Index%LinkClick, %dev_discord%
            }

            url := "https://raw.githubusercontent.com/ivelchampion249/FishSol-Macro/refs/heads/main/DONATORS.txt"

            Http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            Http.Open("GET", url, false)
            Http.Send()

            content := RTrim(Http.ResponseText, "`r`n")

            Gui, Font, s10 cWhite Normal Bold
            Gui, Add, Text, x50 y345 w200 h20 BackgroundTrans, Thank you to our donators!
            Gui, Font, s9 c0xCCCCCC Normal
            Gui, Add, Edit, x50 y370 w480 h125 vDonatorsList -Wrap +ReadOnly +VScroll -WantReturn -E0x200 Background0x2D2D2D c0xCCCCCC, %content%

            Gui, Font, s8 c0xCCCCCC Normal
            Gui, Add, Text, x50 y518 w500 h15 BackgroundTrans, %version% - %randomMessage%

            Gui, Show, w600 h670, %version%

            Gui, Color, 0x1E1E1E
            Gui, Add, Picture, x445 y600 w27 h19, %DiscordPNG%
            Gui, Add, Picture, x538 y601 w18 h19, %RobloxPNG%

            Gui, Font, s11 cWhite Bold Underline, Segoe UI
            Gui, Add, Text, x430 y600 w150 h38 Center BackgroundTrans c0x00FF00 gDonateClick, Donate!
            Gui, Add, Text, x330 y600 w138 h38 Center BackgroundTrans c0x00D4FF gNeedHelpClick, Need Help?
        ;end
    }
    
    ;OVERRIDE THIS FUNCTION TO ADD STUFF ON CREATION
    IniRead()
    {
        global

        temp_regex_keybind_base := "Escape|Button|Wheel|Space|Alt|Control|Shift|Win|Tab|Left|Right|Up|Down|Enter|Backspace|\b[\w\/]\b"

        IniRead, temp_start_keybind, %iniFilePath%, "Keybinds", "StartScript"
        if (temp_start_keybind != "ERROR")
        {
            ;[DEV COMMENT] Do sanity check on keybind on load to prevent unwanted key combinations - Nadir
            REGEX_KEYS_CHECK := temp_regex_keybind_base . "|" . Pause_hotkey . "|" . Stop_hotkey
            if temp_start_keybind ~= REGEX_KEYS_CHECK or GetKeyName(temp_start_keybind) ~= REGEX_KEYS_CHECK 
                Start_hotkey := "F1"
            else
                Start_hotkey := temp_start_keybind
        }
        Else
            IniWrite, % "F1", %iniFilePath%, "Keybinds", "StartScript"
        Hotkey, %Start_hotkey%, START_SCRIPT
        IniRead, temp_pause_keybind, %iniFilePath%, "Keybinds", "PauseScript"
        if (temp_pause_keybind != "ERROR")
        {
            ;[DEV COMMENT] Do sanity check on keybind on load to prevent unwanted key combinations - Nadir
            REGEX_KEYS_CHECK := temp_regex_keybind_base . "|" . Start_hotkey . "|" . Stop_hotkey
            if temp_pause_keybind ~= REGEX_KEYS_CHECK or GetKeyName(temp_pause_keybind) ~= REGEX_KEYS_CHECK 
                Pause_hotkey := "F2"
            else
                Pause_hotkey := temp_pause_keybind
        }
        Else
            IniWrite, % "F2", %iniFilePath%, "Keybinds", "PauseScript"
        Hotkey, %Pause_hotkey%, PAUSE_SCRIPT
        
        IniRead, temp_stop_keybind, %iniFilePath%, "Keybinds", "StopScript"
        if (temp_stop_keybind != "ERROR")
        {
            ;[DEV COMMENT] Do sanity check on keybind on load to prevent unwanted key combinations - Nadir
            REGEX_KEYS_CHECK := temp_regex_keybind_base . "|" . Start_hotkey . "|" . Pause_hotkey
            if temp_stop_keybind ~= REGEX_KEYS_CHECK or GetKeyName(temp_stop_keybind) ~= REGEX_KEYS_CHECK 
                Stop_hotkey := "F3"
            else
                Stop_hotkey := temp_stop_keybind
        }
        Else
            IniWrite, % "F3", %iniFilePath%, "Keybinds", "StopScript"
        Hotkey, %Stop_hotkey%, STOP_SCRIPT
        
        IniRead, tempRes, %iniFilePath%, "Macro", "resolution"
        if (tempRes != "ERROR")
        {
            res := tempRes
        }
        Else
            IniWrite, %res%, %iniFilePath%, "Macro", "resolution"

        IniRead, tempMaxLoop, %iniFilePath%, "Macro", "maxLoopCount"
        if (tempMaxLoop != "ERROR" && tempMaxLoop > 0)
        {
            maxLoopCount := tempMaxLoop
        }
        Else
            IniWrite, %maxLoopCount%, %iniFilePath%, "Macro", "maxLoopCount"

        IniRead, tempFishingLoop, %iniFilePath%, "Macro", "fishingLoopCount"
        if (tempFishingLoop != "ERROR" && tempFishingLoop > 0)
        {
            fishingLoopCount := tempFishingLoop
        }
        Else
            IniWrite, %fishingLoopCount%, %iniFilePath%, "Macro", "fishingLoopCount"

        IniRead, tempSellAll, %iniFilePath%, "Macro", "sellAllToggle"
        if (tempSellAll != "ERROR")
        {
            sellAllToggle := (tempSellAll = "true" || tempSellAll = "1")
        }
        Else
            IniWrite, false, %iniFilePath%, "Macro", "sellAllToggle"

        IniRead, tempPathing, %iniFilePath%, "Macro", "pathingMode"
        if (tempPathing != "ERROR")
        {
            pathingMode := tempPathing
        }
        Else
            IniWrite, %pathingMode%, %iniFilePath%, "Macro", "pathingMode"

        IniRead, tempAzerty, %iniFilePath%, "Macro", "azertyPathing"
        if (tempAzerty != "ERROR")
        {
            azertyPathing := (tempAzerty = "true" || tempAzerty = "1")
        }
        Else
            IniWrite, false, %iniFilePath%, "Macro", "azertyPathing"

        IniRead, tempPrivateServer, %iniFilePath%, "Macro", "privateServerLink"
        if (tempPrivateServer != "ERROR")
        {
            privateServerLink := tempPrivateServer
            code := ""
            if RegExMatch(privateServerLink, "code=([^&]+)", m)
            {
                code := m1
            }
        }
        Else
            IniWrite, % "", %iniFilePath%, "Macro", "privateServerLink"

        IniRead, tempAdvancedDetection, %iniFilePath%, "Macro", "advancedFishingDetection"
        if (tempAdvancedDetection != "ERROR")
        {
            advancedFishingDetection := (tempAdvancedDetection = "true" || tempAdvancedDetection = "1")
        }
        Else
            IniWrite, false, %iniFilePath%, "Macro", "advancedFishingDetection"

        IniRead, tempFishingFailsafe, %iniFilePath%, "Macro", "fishingFailsafeTime"
        if (tempFishingFailsafe != "ERROR" && tempFishingFailsafe > 0)
        {
            fishingFailsafeTime := tempFishingFailsafe
        }
        Else
            IniWrite, %fishingFailsafeTime%, %iniFilePath%, "Macro", "fishingFailsafeTime"

        IniRead, tempPathingFailsafe, %iniFilePath%, "Macro", "pathingFailsafeTime"
        if (tempPathingFailsafe != "ERROR" && tempPathingFailsafe > 0)
        {
            pathingFailsafeTime := tempPathingFailsafe
        }
        Else
            IniWrite, %pathingFailsafeTime%, %iniFilePath%, "Macro", "pathingFailsafeTime"

        IniRead, tempAutoRejoinFailsafe, %iniFilePath%, "Macro", "autoRejoinFailsafeTime"
        if (tempAutoRejoinFailsafe != "ERROR" && tempAutoRejoinFailsafe > 0)
        {
            autoRejoinFailsafeTime := tempAutoRejoinFailsafe
        }
        Else
            IniWrite, %autoRejoinFailsafeTime%, %iniFilePath%, "Macro", "autoRejoinFailsafeTime"

        IniRead, tempAutoUnequip, %iniFilePath%, "Macro", "autoUnequip"
        if (tempAutoUnequip != "ERROR")
        {
            autoUnequip := (tempAutoUnequip = "true" || tempAutoUnequip = "1")
        }
        Else
            IniWrite, false, %iniFilePath%, "Macro", "autoUnequip"

        IniRead, tempAzerty, %iniFilePath%, "Macro", "azertyPathing"
        if (tempAzerty != "ERROR")
        {
            azertyPathing := (tempAzerty = "true" || tempAzerty = "1")
        }
        Else
            IniWrite, false, %iniFilePath%, "Macro", "azertyPathing"

        IniRead, tempAdvancedThreshold, %iniFilePath%, "Macro", "advancedFishingThreshold"
        if (tempAdvancedThreshold != "ERROR" && tempAdvancedThreshold >= 0 && tempAdvancedThreshold <= 40)
        {
            advancedFishingThreshold := tempAdvancedThreshold
        }
        Else
            IniWrite, false, %iniFilePath%, "Macro", "advancedFishingThreshold"

        IniRead, tempStrangeController, %iniFilePath%, "Macro", "strangeController"
        if (tempStrangeController != "ERROR")
        {
            strangeController := (tempStrangeController = "true" || tempStrangeController = "1")
        }
        Else
            IniWrite, false, %iniFilePath%, "Macro", "strangeController"

        IniRead, tempBiomeRandomizer, %iniFilePath%, "Macro", "biomeRandomizer"
        if (tempBiomeRandomizer != "ERROR")
        {
            biomeRandomizer := (tempBiomeRandomizer = "true" || tempBiomeRandomizer = "1")
        }
        Else
            IniWrite, false, %iniFilePath%, "Macro", "biomeRandomizer"

        IniRead, tempAutoCloseChat, %iniFilePath%, "Macro", "autoCloseChat"
        if (tempAutoCloseChat != "ERROR")
        {
            autoCloseChat := (tempAutoCloseChat = "true" || tempAutoCloseChat = "1")
        }
        Else
            IniWrite, false, %iniFilePath%, "Macro", "autoCloseChat"

        IniRead, tempWebhook, %iniFilePath%, "Macro", "webhookURL"
        if (tempWebhook != "ERROR")
        {
            webhookURL := tempWebhook
        }
        Else
            IniWrite, % "", %iniFilePath%, "Macro", "webhookURL"

        IniRead, tempFsWebhook, %iniFilePath%, "Macro", "failsafeWebhook"
        if (tempFsWebhook != "ERROR")
        {
            failsafeWebhook := (tempFsWebhook = "true" || tempFsWebhook = "1")
        }
        Else
            IniWrite, false, %iniFilePath%, "Macro", "failsafeWebhook"

        IniRead, tempPathingWebhook, %iniFilePath%, "Macro", "pathingWebhook"
        if (tempPathingWebhook != "ERROR")
        {
            pathingWebhook := (tempPathingWebhook = "true" || tempPathingWebhook = "1")
        }
        Else
            IniWrite, false, %iniFilePath%, "Macro", "pathingWebhook"

        IniRead, tempItemWebhook, %iniFilePath%, "Macro", "itemWebhook"
        if (tempItemWebhook != "ERROR")
        {
            itemWebhook := (tempItemWebhook = "true" || tempItemWebhook = "1")
        }
        Else
            IniWrite, false, %iniFilePath%, "Macro", "itemWebhook"
    }
    
    ;OVERRIDE THIS FUNCTION TO DO GUICONTROL CHECKS
    GuiControlChecks()
    {        
        Toggle_GuiControl("SellAllStatus", sellAllToggle)
        Toggle_GuiControl("AdvancedFishingDetectionStatus", advancedFishingDetection)
        Toggle_GuiControl("azertyPathing", AzertyPathingStatus)
        Toggle_GuiControl("autoUnequip", AutoUnequipStatus)
        Toggle_GuiControl("autoCloseChat", AutoCloseChatStatus)
        Toggle_GuiControl("strangeController", StrangeControllerStatus)
        Toggle_GuiControl("biomeRandomizer", BiomeRandomizerStatus)
        Toggle_GuiControl("failsafeWebhook", failsafeWebhookStatus)
        Toggle_GuiControl("pathingWebhook", pathingWebhookStatus)
        Toggle_GuiControl("itemWebhook", itemWebhookStatus)
        
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
    }
}