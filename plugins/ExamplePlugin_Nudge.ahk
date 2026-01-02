/*
{ClassName: ExamplePlugin_Nudge
Width: 2560,
Height: 1440
}
*/
class ExamplePlugin_Nudge extends Plugin
{
    PluginRun(byref restartPathing)
    {
        global
        Log.Low_Info("I WAS CALLED DURING RUNTIME! :D")
        Return true
    }

    ;OVERRIDE THIS FUNCTION TO ADD STUFF ON CREATION
    PluginSetup()
    {
        Log.Low_Info("I WAS CALLED DURING SETUP! :D")
        Interrupts.RegisterInterupt(CorePlugin.PostMove.NonVip, this, "RunNonVipPreFishMove", false)
        Interrupts.RegisterInterupt(CorePlugin.PostMove.Vip   , this, "RunVipPreFishMove"   , false)
        Interrupts.RegisterInterupt(CorePlugin.PostMove.Abysl , this, "RunAbyslPreFishMove" , false)
    }
    ;CorePlugin_PreReset CorePlugin_PostMovementPreFish_NonVip CorePlugin_PostMovementPreFish_Vip CorePlugin_PostMovementPreFish_Abys
    ;OVERRIDE THIS FUNCTION TO ADD STUFF ON CREATION
    SetupTabList()
    {
        Log.Low_Info("I WAS CALLED DURING TABLIST CREATION! :D")
        return "|Nudger"
    }

    ;OVERRIDE THIS FUNCTION TO ADD STUFF TO CLASS ON CREATION
    SetupGui()
    {
        global
        Log.Low_Info("I WAS CALLED DURING GUI CREATION! :D")
        Gui, Tab, Nudger
        Gui, Font, s20 cWhite Bold, Segoe UI
        Gui, Add, Text, x25 y85 w570 h45 Center BackgroundTrans c0x7F50FE, % "NADIR PATCHES!!!"
        Gui, Font, s9 c0xCCCCCC Normal
        Gui, Font, s10 cWhite Bold, Segoe UI
        Gui, Add, Text, xm+10 y125 w180 BackgroundTrans, % "NUDGING SETTINGS"
        Gui, Add, Checkbox, xm+10 y+m BackgroundTrans vEnableNudging   gUpdateCheckBoxPATCHES
        Gui, Add, Text, xp+20 w30 BackgroundTrans
        Gui, Add, Text, xp+15 w150 BackgroundTrans, % "ENABLE NUDGER"
        Gui, Add, Checkbox, xm+10 y+m BackgroundTrans vAlwaysOnNudging gUpdateCheckBoxPATCHES 
        Gui, Add, Text, xp+20 w30 BackgroundTrans
        Gui, Add, Text, xp+15 vAlwaysOnNudging_TEXT  w150 BackgroundTrans, % "[Only]"
        Gui, Add, Text, xp+100 BackgroundTrans, % "Nudge"
        Gui, Add, Checkbox, xm+10 y+m BackgroundTrans vWhenFailSafe gUpdateCheckBoxPATCHES
        Gui, Add, Text, xp+20 w30 BackgroundTrans
        Gui, Add, Text, xp+15 BackgroundTrans vWhenFailSafe_TEXT w160, % "[After]"
        Gui, Add, Text, xp+100 BackgroundTrans, % "Failsafe"
        Gui, Add, Picture, x430 y500 w200 h192 BackgroundTrans, %Gui_ExamplePlugin_Nudge_Png%

    }

    ;OVERRIDE THIS FUNCTION TO ADD STUFF ON CREATION
    IniRead()
    {
        global
        local tempEnableNudging, tempAlwaysOnNudging, tempAutoCrafterDetection, CATAGORY_INI
        Log.Low_Info("I WAS CALLED DURING INI SETTINGS READ! :D")
        CATAGORY_INI := "Macro"
        IniRead, tempEnableNudging, %iniFilePath%, "NadirPatches", "enableNudging"
        if (tempEnableNudging != "ERROR")
        {
            G_EnableNudging := (tempEnableNudging = "true" || tempEnableNudging = "1")
        }
        IniRead, tempAlwaysOnNudging, %iniFilePath%, "NadirPatches", "alwaysOnNudging"
        if (tempAlwaysOnNudging != "ERROR")
        {
            G_AlwaysOnNudging := (tempAlwaysOnNudging = "true" || tempAlwaysOnNudging = "1")
        }
        IniRead, tempAutoCrafterDetection, %iniFilePath%, "NadirPatches", "whenFailSafe"
        if (tempWhenFailSafe != "ERROR")
        {
            G_WhenFailSafe := (tempWhenFailSafe = "true" || tempWhenFailSafe = "1")
        }
    }
    
    RunNonVipPreFishMove(byref loopCount, byref restartPathing)
    {
        if ((G_EnableNudging) and ((G_AlwaysOnNudging) or (WhenFailSafe = fishingFailsafeRan))) {
            sleep 200
            Send, {%keyA% Down}
            sleep 1400
            Send, {%keyA% Up}
            sleep 75
            Send, {%keyW% Down}
            sleep 100
            Send, {%keyW% Up}
        }
        return 0
    }
    
    RunVipPreFishMove(byref loopCount, byref restartPathing)
    {
        if ((G_EnableNudging) and ((G_AlwaysOnNudging) or (WhenFailSafe = fishingFailsafeRan))) {
            sleep 200
            Send, {%keyA% Down}
            sleep 1400
            Send, {%keyA% Up}
            sleep 75
            Send, {%keyW% Down}
            sleep 100
            Send, {%keyW% Up}
        }
        return 0
    }
    
    RunAbyslPreFishMove(byref loopCount, byref restartPathing)
    {
        if ((G_EnableNudging) and ((G_AlwaysOnNudging) or (WhenFailSafe = fishingFailsafeRan))) {
            sleep (200*0.75)
            Send, {%keyA% Down}
            sleep (1400*0.75)
            Send, {%keyA% Up}
            sleep (75*0.75)
            Send, {%keyW% Down}
            sleep (100*0.75)
            Send, {%keyW% Up}
        }
        
        return 0
    }
    
    ;OVERRIDE THIS FUNCTION TO DO GUICONTROL CHECKS
    GuiControlChecks()
    {
        global
        Log.Low_Info("I WAS CALLED DURING GUI CONTROL CHECKS! :D")
        GuiControl,, EnableNudging, %G_EnableNudging%
        GuiControl,, AlwaysOnNudging, %G_AlwaysOnNudging%
        GuiControl,, WhenFailSafe, %G_EnableNudging%
        Gosub, UpdateCheckBoxPATCHES
    }
}

goto ExamplePlugin_Nudge_EOF

UpdateCheckBoxPATCHES:
    Gui, Submit, NoHide
    if EnableNudging
    {
        GuiControl, enable, AlwaysOnNudging
        if AlwaysOnNudging
        {
            GuiControl, disable, WhenFailSafe
            Gui, Font, s10 cLime Bold, Segoe UI
            GuiControl, Font, AlwaysOnNudging_TEXT
            Gui, Font, s10 cGray Bold, Segoe UI
            GuiControl, Font, WhenFailSafe_TEXT
        }
        Else
        {
            GuiControl, enable, WhenFailSafe
            if WhenFailSafe
                Gui, Font, s10 cLime Bold, Segoe UI
            Else
                Gui, Font, s10 cYellow Bold, Segoe UI
            GuiControl, Font, WhenFailSafe_TEXT
            Gui, Font, s10 cLime Bold, Segoe UI
            GuiControl, Font, AlwaysOnNudging_TEXT
        }
    }
    else
    {
        Gui, Font, s10 cGray Bold, Segoe UI
        GuiControl, Font, AlwaysOnNudging_TEXT
        Gui, Font, s10 cGray Bold, Segoe UI
        GuiControl, Font, WhenFailSafe_TEXT
        GuiControl, disable, AlwaysOnNudging
        GuiControl, disable, WhenFailSafe
    }
    if G_EnableNudging != EnableNudging
        IniWrite, %EnableNudging%, %iniFilePath%, "NadirPatches", "enableNudging"
    if G_AlwaysOnNudging != AlwaysOnNudging
        IniWrite, %AlwaysOnNudging%, %iniFilePath%, "NadirPatches", "alwaysOnNudging"
    if G_WhenFailSafe != WhenFailSafe
        IniWrite, %WhenFailSafe%, %iniFilePath%, "NadirPatches", "whenFailSafe"
    G_EnableNudging   := EnableNudging
    G_AlwaysOnNudging := AlwaysOnNudging
    G_WhenFailSafe    := WhenFailSafe
    GuiControl, , AlwaysOnNudging_TEXT, % "[" (AlwaysOnNudging ? "Always" : "Only") "]"
    GuiControl, , WhenFailSafe_TEXT, % "[" (AlwaysOnNudging ? "AWLAYS OFF" : (WhenFailSafe ? "Before" : "After")) "]"
Return

ExamplePlugin_Nudge_EOF:

Log.Info("[PLUGIN=>""ExamplePlugin_Nudge.ahk""]" . " Finished Loading!")
Log.Info("[PLUGIN=>""ExamplePlugin_Nudge.ahk""]" . " Yippee!!")

global G_EnableNudging := true
global G_AlwaysOnNudging := true
global G_WhenFailSafe := true
global Gui_ExamplePlugin_Nudge_Png := A_ScriptDir . "\plugins\ExamplePlugin_Nudge\Hex.png"