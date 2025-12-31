/*
{
ClassName: AutoCrafterPlugin,
Width: 123,
Height: 123
}
*/
class AutoCrafterPlugin extends Plugin
{
    ;[DEV COMMENT] the above metadata isn't really needed for the plugin but is requried to have it even be
    ;               added to the list when the loader is called

    ;OVERRIDE THIS FUNCTION AND CALL |PLUGIN_NAME|.RUN()
    PluginRun()
    {}

    ;OVERRIDE THIS FUNCTION TO ADD STUFF ON CREATION
    PluginSetup()
    {}

    
    ;OVERRIDE THIS FUNCTION TO ADD STUFF ON CREATION
    IniRead()
    {
        global
        local tempAutoCrafter, tempAutoCrafterWebhook, tempCrafter, tempAutoCrafterDetection, CATAGORY_INI
        CATAGORY_INI := "Macro"
        IniRead, tempAutoCrafter, %iniFilePath%, %CATAGORY_INI%, "autoCrafter", 0
        autoCrafter := (tempAutoCrafter = "1" || tempAutoCrafter = "true")

        IniRead, tempAutoCrafterWebhook, %iniFilePath%, %CATAGORY_INI%, "autoCrafterWebhook", 0
        autoCrafterWebhook := (tempAutoCrafterWebhook = "1" || tempAutoCrafterWebhook = "true")

        IniRead, tempCrafter, %iniFilePath%, %CATAGORY_INI%, "crafterToggle"
        if (tempCrafter != "ERROR")
        {
            crafterToggle := (tempCrafter = "true" || tempCrafter = "1")
        }

        IniRead, tempAutoCrafterDetection, %iniFilePath%, %CATAGORY_INI%, "autoCrafterDetection"
        if (tempAutoCrafterDetection != "ERROR")
        {
            autoCrafterDetection := (tempAutoCrafterDetection = "true" || tempAutoCrafterDetection = "1")
        }
    }
    ;OVERRIDE THIS FUNCTION TO ADD STUFF ON CREATION
    SetupTabList()
    {
        return "|Crafter"
    }

    ;OVERRIDE THIS FUNCTION TO ADD STUFF TO CLASS ON CREATION
    SetupGui()
    {
        global
        Gui, Tab, Crafter

        Gui, Add, Picture, x14 y80 w574 h590, %Gui_Crafter_Png%

        Gui, Font, s11 cWhite Bold, Segoe UI
        Gui, Add, Text, x45 y135 w200 h25 BackgroundTrans, example text:
        Gui, Font, s10 cWhite Bold
        Gui, Add, Button, x250 y135 w80 h25 gToggleCrafter vCrafterBtn, Toggle
        Gui, Font, s10 c0xCCCCCC Bold, Segoe UI
        Gui, Add, Text, x340 y140 w60 h25 vCrafterStatus BackgroundTrans, OFF

        Gui, Font, s9 cWhite Normal, Segoe UI
        Gui, Add, Text, x45 y185 w500 h60 BackgroundTrans c0xCCCCCC, example text

        Gui, Font, s10 cWhite Bold
        Gui, Add, Button, x425 y505 w115 h40 gOpenPluginsFolder, Open Plugins Folder

        Gui, Color, 0x1E1E1E
        Gui, Add, Picture, x445 y600 w27 h19, %DiscordPNG%
        Gui, Add, Picture, x538 y601 w18 h19, %RobloxPNG%

        Gui, Font, s11 cWhite Bold Underline, Segoe UI
        Gui, Add, Text, x430 y600 w150 h38 Center BackgroundTrans c0x00FF00 gDonateClick, Donate!
        Gui, Add, Text, x330 y600 w138 h38 Center BackgroundTrans c0x00D4FF gNeedHelpClick, Need Help?
    }
    
    ;OVERRIDE THIS FUNCTION TO DO GUICONTROL CHECKS
    GuiControlChecks()
    {
        global
        Toggle_GuiControl("CrafterStatus", crafterToggle)
        if (crafterToggle) {
            autoCrafterDetection := true
            autoCrafterLastCheck := A_TickCount
        } else {
            autoCrafterDetection := false
        }
    }
}

goto AutoCrafter_EOF
ToggleAutoCrafter:
    autoCrafter := !autoCrafter
    Toggle_GuiControl("AutoCrafterStatus", autoCrafter, "autoCrafter")
return


ToggleCrafter:
    crafterToggle := !crafterToggle
    Toggle_GuiControl("CrafterStatus", crafterToggle, "crafterToggle")
    if (crafterToggle) {
        autoCrafterDetection := true
        autoCrafterLastCheck := A_TickCount
        IniWrite, true, %iniFilePath%, "Macro", "autoCrafterDetection"
    } else {
        IniWrite, false, %iniFilePath%, "Macro", "autoCrafterDetection"
    }
return

UpdateAutoCrafterInterval:
    Gui, Submit, NoHide
    newInterval := AutoCrafterInterval * 60000
    if (newInterval > 0) {
        autoCrafterInterval := newInterval
        IniWrite, %autoCrafterInterval%, %iniFilePath%, "Macro", "autoCrafterInterval"
    }
return

ToggleAutoCrafterWebhook:
    autoCrafterWebhook := !autoCrafterWebhook
    Toggle_GuiControl("AutoCrafterWebhookStatus", autoCrafterWebhook, "autoCrafterWebhook")
return

RunAutoCrafter() {
    MouseGetPos, originalX, originalY
    global res

    if (res = "1080p") {
        RunAutoCrafter1080p()
    } else if (res = "1440p") {
        RunAutoCrafter1440p()
    } else if (res = "1366x768") {
        RunAutoCrafter768p()
    }

    MouseMove, %originalX%, %originalY%, 0
}

; 1080p Auto Crafter
RunAutoCrafter1080p() {
    Send, {Esc}
    Sleep, 300
    Send, R
    Sleep, 500
    Send, {Enter}
    Sleep, 2000

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
    Send, {w up}
    Send, {a up}
    Send, {s up}
    Send, {d up}
    Send, {space up}
    Send, {e up}
    reset := false
    Sleep 300

    Send, {Esc}
    Sleep, 650
    Send, R
    Sleep, 650
    Send, {Enter}
    sleep 2600
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
    Send, {Esc}
    Sleep, 300
    Send, R
    Sleep, 500
    Send, {Enter}
    Sleep, 2000

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


AutoCrafter_EOF:

Log.Info("[PLUGIN=>""auto crafter.ahk""]" . " Finished Loading!")

global crafterToggle := false
global autoCrafterDetection := false
global autoCrafterLastCheck := 0
global autoCrafterCheckInterval := 2000
global autoCrafter := false
global autoCrafterWebhook := false
global autoCrafterLastRun := 0
global autoCrafterInterval := 300000
global autoCrafterTime := 300000
global hasCrafterPlugin := true
global Gui_Crafter_Png   := A_ScriptDir . "\gui\Crafter.png"