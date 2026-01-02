global PLUGINS_LIST := []

class Plugin
{
    static S_LEFT        := 1
    static S_TOP         := 2
    static S_RIGHT       := 3
    static S_BOTTOM      := 4
    static S_CENTER      := 5 ;ALSO WRITEN AS NONE but leaving as center

    Width := 1920
    Height := 1080

    __New(width, height)
    {
        Log.Info("[PLUGIN=>" . this.__Class . "] I've been Created! W: " . width . " H: " . height)
        this.Width  := width
        this.Height := height
        PLUGINS_LIST.push(this)
    }

    Run()
    {
        ; Log.Info("[PLUGIN=>" . this.__Class . "] is Running!")
        ; this.PluginRun()
    }

    PluginRun(byref restartPathing)
    {
        Return true
    }

    ;OVERRIDE THIS FUNCTION TO ADD STUFF ON CREATION
    PluginSetup()
    {
        ; global
        ; local
    }

    ;OVERRIDE THIS FUNCTION TO ADD STUFF ON CREATION
    SetupTabList()
    {}

    ;OVERRIDE THIS FUNCTION TO ADD STUFF TO CLASS ON CREATION
    SetupGui()
    {}
    
    ;OVERRIDE THIS FUNCTION TO ADD STUFF ON CREATION
    IniRead()
    {}
    
    ;OVERRIDE THIS FUNCTION TO DO GUICONTROL CHECKS
    GuiControlChecks()
    {}

    ; The Points and Rects
    LocalThings := []

    RegisterPoint(X, Y, Side, Name:="")
    {

        PointID := RectangleBuilder.DrawPoint(X, Y, 15, 15, 2, 0xFFFFFF)
        PointObject := RectangleBuilder.get_Window(PointID)
        if Name != ""
            PointObject.set_Name(Name)
        PointObject.SetVisibility(true,true)
        PointObject.set_Anchor(Side, false)
        PointObject.SnapToSides()
        PointObject.SnapAdjustToResolution(this.Width, this.Height)
        PointObject.set_Color(this.getRandomColor())
        this.LocalThings.Push(PointObject)
        return PointObject
    }

    RegisterRect(X, Y, W, H, Side, Name:="")
    {
        RectID := RectangleBuilder.DrawRect(X, Y, W, H, 2, 0xFFFFFF)
        RectObject := RectangleBuilder.get_Window(RectID)
        if Name != ""
            RectObject.set_Name(Name)
        RectObject.SetVisibility(true,true)
        RectObject.set_Anchor(Side, false)
        RectObject.SnapToSides()
        RectObject.SnapAdjustToResolution(this.Width,this.Height)
        RectObject.set_Color(this.getRandoomColor())
        this.LocalThings.Push(RectObject)
        return RectObject
    }

    RegisterSearchXY2(X, Y, X2, Y2, Side, Name:="")
    {
        return this.RegisterSearch( min(X,X2), min(Y,Y2), Abs(X2-X), Abs(Y2-Y), Side, Name)
    }

    RegisterSearch(X, Y, W, H, Side, Name:="")
    {
        RectID := RectangleBuilder.DrawSearch(X, Y, W, H, 2, 0xFFFFFF)
        RectObject := RectangleBuilder.get_Window(RectID)
        if Name != ""
            RectObject.set_Name(Name)
        RectObject.SetVisibility(true,true)
        RectObject.set_Anchor(Side, false)
        RectObject.SnapToSides()
        RectObject.SnapAdjustToResolution(this.Width,this.Height)
        RectObject.set_Color(this.getRandomColor())
        this.LocalThings.Push(RectObject)
        return RectObject
    }

    check()
    {}
    
    ; part of the visualiser
    HideAll()
    {
        for k, rect in this.LocalThings
            rect.Hide()
            
    }

    ; part of the visualiser
    ShowAll(force:=false)
    {
        for k, rect in this.LocalThings
        {
            if (rect.Visible or not force)
                rect.Show()
        }
    }

    ; part of the visualiser
    getRandomColor()
    {
        HEX := "0|1|2|3|4|5|6|7|8|9|A|B|C|D|E|F|0|1|2|3|4|5|6|7|8|9|A|B|C|D|E|F|0|1|2|3|4|5|6|7|8|9|A|B|C|D|E|F|0|1|2|3|4|5|6|7|8|9|A|B|C|D|E|F|0|1|2|3|4|5|6|7|8|9|A|B|C|D|E|F|0|1|2|3|4|5|6|7|8|9|A|B|C|D|E|F|0|1|2|3|4|5|6|7|8|9|A|B|C|D|E|F|"
        Sort, HEX, Random D|
        HEX := SubStr(StrReplace(HEX, "|"), 1, 6)
        return "0x" . HEX
    }

    ;will probably pull this out and into its own thing
    SendWebhook(title, color := "0") {
        global
        local time, timestamp, json, http
        
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

    DoSleep(ms:=300)
    {
        Log.Low_Info("Sleep " . ms)
        if Debugger.DoSleep
            Sleep %ms%
    }

    SendKey(key_press)
    {
        Log.Low_Info("Send " . key_press)
        if Debugger.DoSendKeystrokes
            Send %key_press%
    }

    SendKeySleep(key_press, ms:=300)
    {
        this.SendKey(key_press)
        this.DoSleep(ms)
    }
    
    QuickReset()
    {
        this.SendKeySleep("{Esc}",650)
        this.SendKeySleep("R",650)
        this.SendKeySleep("{Enter}",2000)
    }
}


LoadPlugins()
{
    Log.Info("Loading Plugins!")
    pt2  := new StopWatch
    for _, plugin_class in PLUGINS_LIST
    {
        Log.message("BENCHMARK", "[" . plugin_class.__Class . "] has started to load", false, true)
        pt2.Start()
        plugin_class.PluginSetup()
        Log.message("BENCHMARK", "PLUGIN SETUP=>" . plugin_class.__Class . " took " . pt2.Stop().getTimeData().get_ms() . "ms to load!", false, true)
    }
    pt2 := ""
}

;Tester := new Tester(2560,1440)

class Tester extends Plugin
{
    PluginSetup()
    {
        MSGBOX, % "THE TEST PLUGIN HAS BEEN LOADED"
        this.VisualWidth := 100

        this.Left_Tester           := this.RegisterRect(0, 0, this.S_LEFT, "Left")
        this.Left_Tester  .set_Scale(this.VisualWidth,1440)
        this.Left_Tester  .set_position(0,-720)

        this.Right_Tester          := this.RegisterRect(0, 0, this.S_RIGHT, "Right")
        this.Right_Tester .set_Scale(this.VisualWidth,1440)
        this.Right_Tester .set_position(0,-720)

        this.Top_Tester            := this.RegisterRect(0, 0, this.S_BOTTOM, "Bottom")
        this.Top_Tester   .set_Scale(2560,this.VisualWidth)
        this.Top_Tester   .set_position(-1280,0)

        this.Bottom_Tester         := this.RegisterRect(0, 0, this.S_TOP, "Top")
        this.Bottom_Tester.set_Scale(2560,this.VisualWidth)
        this.Bottom_Tester.set_position(-1280,0)

        this.Center_Tester         := this.RegisterRect(0, 0, this.S_CENTER, "Center")
        this.Center_Tester.set_Scale(this.VisualWidth*3,this.VisualWidth*3)
        this.Center_Tester.set_position(0, 0)
    }

    PluginRun(byref restartPathing)
    {
        Return true
    }
}

class Interrupts
{
    static registry := []

    RegisterInterupt(callname, this_class, function, CanForceEnd:=false)
    {
        if not Interrupts.registry.hasKey(callname)
        {
            Interrupts.registry[callname] := []
        }
        Interrupts.registry[callname].Push({This_Class : this_class
        , FuncCall : function,      CheckForceEnd : CanForceEnd})
    }

    ; Self contained Interrupt call, if inturrupt would return or modify values with byrefs please use GetInterrupts and make your own Caller
    CallForInterrupt(callname, params*)
    {
        for index, value in Interrupts.registry
        {
            function := value.FuncCall
            TheClass := value.This_Class
            if(value.CanForceEnd)
            {
                try ret := TheClass[%function%](params)
                if not ret = "" and not ret = 0 ; if something says to stop running we stop running
                    return ret
            }
            else
                try ret := TheClass[%function%](params)
        }
        return 0
    }

    GetInterrupts(CallName)
    {
        return Interrupts.registry[callname]
    }
}



; For _, interrupt in GetInterrup("PostWalkToFishingSpot")
; {
;     function := interrupt.Function
;     interrupt.ClassName.%function%(var1, var2, var3)
; } 
