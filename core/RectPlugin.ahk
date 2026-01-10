;@cleanupregex "/\[\]/g" "new Array"
global PLUGINS_LIST := []
;@cleanupend
class Plugin
{
    static S_LEFT        := 1
    static S_TOP         := 2
    static S_RIGHT       := 3
    static S_BOTTOM      := 4
    static S_CENTER      := 5 ;ALSO WRITEN AS NONE but leaving as center

    Width := 1920
    Height := 1080

    /**
     * @description makes a new plugin to be loaded and pushes it to the stack
     * @class Plugin
     * @classdesc Plugin definition and exectution
     * @param {Number} width  window width used when making the plugin, default 2560
     * @param {Number} height window height used when making the plugin, default 1440
     * @constructor
     */
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

    /**
     * @description what is run during the main loop
     * @param {"byref boolean"} restartPathing the restartPathing variable given from the main script, we can set this if we need to restart the pathing
     * @returns {Boolean} if false we end the loop of the current run
     */
    PluginRun(byref restartPathing)
    {
        Return true
    }

    /**
     * @description function called when plugin is setup at the start
     * @example <caption>good to use the following template</caption>
     * PluginSetup()
     * {
     *     global ; X, Y <== example global variables
     *     local  ; var1, var2, var3 := "something" <== example local variables
     *     ;;initialise code bellow here;;
     * }
     * @example <caption>Webhook Example</caption>
     * PluginSetup()
     * {
     *     global
     *     if (not inStr(webhookURL, "code"))
     *          this.plugin_can_post := false
     * ....more code
     * }
     */
    PluginSetup()
    {
        ; global
        ; local
    }

    /**
     * @description adds new tabs to tab list
     * @example <caption>if a tab is required setting a return to a string like so is required</caption>
     * SetupTabList()
     * {
     *     return "|tab_name"
     * }
     * @return {String|Null}
     */
    SetupTabList()
    {

    }

    /**
     * @description Gui Setup done in here {@link Plugin#SetupTabList}
     * @example <caption>to hook a tab created with {@link Plugin#SetupTabList|SetupTabList()}</caption>
     * SetupGui()
     * {
     *     global
     *     Gui, Tab, tab_name //this should be the same as the string
     *                    //used in {@link Plugin#SetupTabList|SetupTabList()}
     * ....more code
     * }
     */
    SetupGui()
    {

    }

    /**
     * @description used to read variables from the ini file at startup {@link Plugin#QuickLoad:QuickLoad("variable", default)}
     * @example
     * IniRead()
     * {
     *     global
     *     local temp_variable
     *     IniRead, temp_variable, %iniFilePath%, "Category", "variable_save_name"
     *     if (temp_variable != "ERROR")
     *         variable := tempPSLink //We have a variable so we can set it here!
     *      
     *     Else //Write the default variable to the ini if it doesn't already exist
     *         IniWrite, % "", %iniFilePath%, "Category", "variable_save_name"
     * ....more code
     * }
     */
    IniRead()
    {

    }
    

    /**
     * @description because the order of iniread and setupgui are the way they are
     * <br/>we also have a second function called after both to update control states
     * @example
     * GuiControlChecks()
     * {
     *     global
     *     local color, state, name_fix, catagory_fix
     * 
     *     GuiControl,, the_control, (the_control_active ? "ON" : "OFF")
     *     GuiControl, (the_control_active ? "+c0x00DD00" : "+c0xFF4444"), the_control
     * 
     *     //sometimes that change needs to be savesd to file
     *     IniWrite, % (the_control_active ? "true" : "false"), %iniFilePath%, "Category", "variable_save_name"
     * ....more code
     * }
     */
    GuiControlChecks()
    {
        
    }

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

    RegisterFixedPoint(X, Y, Side, Name:="")
    {
        PointID := RectangleBuilder.DrawFixedPoint(X, Y, 15, 15)
        PointObject := RectangleBuilder.get_Window(PointID)
        if Name != ""
            PointObject.set_Name(Name)
        PointObject.SetVisibility(true,true)
        PointObject.set_Anchor(Side, false)
        PointObject.SnapAdjustToResolution(this.Width, this.Height)
        PointObject.set_Color(this.getRandomColor())
        this.LocalThings.Push(PointObject)
        return PointObject
    }

    ; Side: 0 no scaled, 0x1 scaled witdth, 0x2 scaled height, 0x3 both
    RegisterScaledPoint(X, Y, Side, Name:="")
    {
        tempSide := Side ; & 0x3
        PointID := RectangleBuilder.DrawScaledPoint(X, Y, 15, 15)
        PointObject := RectangleBuilder.get_Window(PointID)
        if Name != ""
            PointObject.set_Name(Name)
        PointObject.SetVisibility(true,true)
        PointObject.set_Anchor(tempSide, true)
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
