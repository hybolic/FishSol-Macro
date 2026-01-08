
;@cleanupregex "/{.*}/g" "new Object()"
global allVisible := False
global QuickRegex := {True_False:"(?i)(true|false|0|1)", Num_Int:"^[\d]*$", Num_Float:"^[\d]*\.{0,1}[\d]*$", Num_Hex:"([0-9A-Fa-f]{6,6})|(0x[0-9A-Fa-f]{6,6})", JsonQuick:"{.*}", JsonValid:"((?<o>{((?<s>([\s\n\r]*)[\s\n\r]*\""""([^\0-\x1F\""""\\]|\\[\""""\\\/bfnrt]|\\u[0-9a-fA-F]{4})*\""""[\s\n\r]*)[\s\n\r]*:[\s\n\r]*(?<v>\g<s>|(?<n>-?(0|[1-9]\d*)(.\d+)?([eE][+-]?\d+)?)[\s\n\r]*|\g<o>|\g<a>|true|false|null))?\s*((?<c>,[\s\n\r]*)\g<s>(?<d>:[\s\n\r]*)\g<v>)*[\s\n\r]*})|(?<a>\[\g<v>?(\g<c>\g<v>)*\])[\s\n\r]*)", ForceEnd:"(?(?<!$)(*THEN)(*COMMIT)(*FAIL)|(*ACCEPT))"}

class RectangleBuilder
{
    static AllWindows   := {}
    static UpdateTicker := 0
    MakeOverlayGui()
    {
        global
        Gui, OVERLAY:New, , % "OVERLAY"
        Gui, OVERLAY: +LastFound -Caption +ToolWindow +AlwaysOnTop +hwndHANDLE_OVERLAY +E0x02000000 +E0x00080000
        WinSet, ExStyle, +0x20
        WinSet, AlwaysOnTop, On
        Gui, OVERLAY:Color, 000000
        WinSet, TransColor, 000000 255
        Gui, OVERLAY:Show, Hide x0 y0 w2560 h1440 NoActivate
    }


    DrawRect(newX, newY, oldW, oldH, old_border_thickness:=3, border_color:=0xFF00FF,name:="")
    {
        newW := oldW
        newH := oldH
        border_thickness := old_border_thickness

        IfLess, border_thickness, 0
            border_thickness := 1

        IfLess, oldW, % (border_thickness * 2)
            newW := border_thickness * 2

        IfLess, oldH, % (border_thickness * 2)
            newH := border_thickness * 2
        if (StrLen(name) > 3) and not (RectangleBuilder.AllWindows.HasKey(name)) and &name != &_______________________________AAAAAAAAAAAAAAAAAAAAAA
            window_key := name
        Else
            window_key := "rect_" . RectangleBuilder.AllWindows.Count()
        

        innerX2 := newW - border_thickness
        innerY2 := newH - border_thickness
        
        __obj := new Rectangle(newX, newY, newW, newH, border_thickness, window_key, border_color)
        __obj.set_Key(window_key)
        __Obj.T_Set(newX, newY)

        RectangleBuilder.AllWindows[window_key] := __obj

        if not allVisible
            __obj.SetVisibility(false,true)

        return window_key
    }
    
    DrawPoint(newX, newY, newW, newH, old_border_thickness:=3, border_color:=0xFFFFFF)
    {
        RobloxWindow.UpdateStates()
        RobloxWindow.Update_Rectangle_Locations()
        
        border_thickness := 2

        window_key := "Point_" . RectangleBuilder.AllWindows.Count()
        ; Gui, %window_key%:New, +Lastfound +AlwaysOnTop +Toolwindow ,%window_key%

        innerX2 := newW - border_thickness
        innerY2 := newH - border_thickness

        ; Gui, %window_key%:Color, %border_color%
        ; Gui, -Caption

            
        posX := newX ; - (newW / 2)
        posY := newY ; - (newH / 2)

        ; WinSet, Region, 0-0 %newW%-0 %newW%-%newH% 0-%newH% 0-0    %border_thickness%-%border_thickness% %innerX2%-%border_thickness% %innerX2%-%innerY2% %border_thickness%-%innerY2% %border_thickness%-%border_thickness% 

        ; Gui, %window_key%:Show, w%newW% h%newH% x%posX% y%posY% NoActivate
        ; Gui, %window_key%: +AlwaysOnTop
        ; msgbox % (newY - RobloxWindow.State.Screen.Y)
        __obj := new Point(newX, newY, newW, newH, border_thickness, window_key, border_color)
        __obj.set_Key(window_key)
        __obj.set_Anchor(this.Anchors.None)
        __Obj.T_Set(newX, newY)

        RectangleBuilder.AllWindows[window_key] := __obj

        if not allVisible
            __obj.SetVisibility(false,true)

        return window_key
    }

    
    DrawFixedPoint(newX, newY, newW, newH, border_color:=0xFFFFFF)
    {
        return RectangleBuilder.Make("FixedPoint", "FixedPoint", newX, newY, newW, newH, border_color).GetWindowKey()
    }

    
    DrawScaledPoint(newX, newY, newW, newH, border_color:=0xFFFFFF)
    {
        return RectangleBuilder.Make("ScaledPoint", "ScaledPoint", newX, newY, newW, newH, border_color).GetWindowKey()
    }
    
    MakeBorderedAdjusted(className, prefix, newX, newY, newW, newH, old_border_thickness:=3, border_color:=0xFFFFFF)
    {
        newW := oldW
        newH := oldH
        border_thickness := old_border_thickness

        IfLess, border_thickness, 0
            border_thickness := 1

        IfLess, oldW, % (border_thickness * 2)
            newW := border_thickness * 2

        IfLess, oldH, % (border_thickness * 2)
            newH := border_thickness * 2
        if (StrLen(name) > 3) and not (RectangleBuilder.AllWindows.HasKey(name)) and &name != &_______________________________AAAAAAAAAAAAAAAAAAAAAA
            window_key := name
        Else
            window_key := "rect_" . RectangleBuilder.AllWindows.Count()
        

        innerX2 := newW - border_thickness
        innerY2 := newH - border_thickness
        
        __obj := new Rectangle(newX, newY, newW, newH, border_thickness, window_key, border_color)
        __obj.set_Key(window_key)
        __Obj.T_Set(newX, newY)

        RectangleBuilder.AllWindows[window_key] := __obj

        if not allVisible
            __obj.SetVisibility(false,true)

        return window_key
    }

    Make(className, prefix, newX, newY, newW, newH, border_color:=0xFFFFFF)
    {   
        border_thickness := 2

        window_key := prefix . "_" . RectangleBuilder.AllWindows.Count()
            
        posX := newX
        posY := newY

        __obj := new %className%(newX, newY, newW, newH, border_thickness, window_key, border_color)
        __obj.set_Key(window_key)
        __obj.set_Anchor(this.Anchors.None)
        __Obj.T_Set(newX, newY)

        RectangleBuilder.AllWindows[window_key] := __obj

        if not allVisible
            __obj.SetVisibility(false,true)

        return __obj
    }

    DrawSearch(newX, newY, oldW, oldH, old_border_thickness:=3, border_color:=0xFF00FF)
    {
        RobloxWindow.UpdateStates()
        RobloxWindow.Update_Rectangle_Locations()

        border_thickness := old_border_thickness

        IfLess, border_thickness, 0
            border_thickness := 1

        window_key := "SearchBox_" . RectangleBuilder.AllWindows.Count()

        __obj := new SearchBox(newX, newY, oldW, oldH, border_thickness, window_key, border_color)
        __obj.set_Key(window_key)
        __obj.set_Anchor(this.Anchors.None)
        __Obj.T_Set(newX, newY)

        RectangleBuilder.AllWindows[window_key] := __obj

        if not allVisible
            __obj.SetVisibility(false,true)

        return window_key
    }

    get_Window(label)
    {
        if not isObject(RectangleBuilder.AllWindows[label]) and StrLen(label) > 0
        {
            return this.get_window_from_label(label)
        }
        return RectangleBuilder.AllWindows[label]
    }

    get_window_from_label(window)
    {
        window_list := []
        for key, value in RectangleBuilder.AllWindows
            if value = window
                window_list.push(value)
        return window_list
    }

    get_label(window)
    {
        for key, value in RectangleBuilder.AllWindows
            if value = window
                return key
        return ""
    }
     
    Update_Rectangle_Locations()
    {
        SetBatchLines, -1
        RectangleBuilder.SnappingWindow := true
        if RobloxWindow.isDirty() ; and isObject(RobloxWindow.State) and IsObject(RobloxWindow.State.Screen)
        {
            ;;;;;;;;;;;UPDATE LOCATION OF WINDOW HELPER;;;;;;;;;;;
            Anchors.MainWindow.CHeight := RobloxWindow.State.Screen.Height
            Anchors.MainWindow.CWidth  := RobloxWindow.State.Screen.Width

            ; Anchors.MainWindow.T_Set(RobloxWindow.State.Screen.X, RobloxWindow.State.Screen.Y)
            Anchors.MainWindow.set_Scale(RobloxWindow.State.Screen.Height,RobloxWindow.State.Screen.Width)
            Anchors.MainWindow.Scale(RobloxWindow.State.Screen.Width,RobloxWindow.State.Screen.Height)
            Anchors.MainWindow.Move(RobloxWindow.State.Screen.X, RobloxWindow.State.Screen.Y)
            RobloxWindow.UnmarkDirty()
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            

            for index, value in RectangleBuilder.AllWindows
            {
                if value.WindowKey = Anchors.MainWindow.WindowKey or value.WindowKey = "EditorRect"
                    Continue
                if not value.hasGui
                {
                    GUI, OVERLAY:Font, s12
                    value.MakeGui()
                }
                value.MoveGui()
            }
            
            if not this.WindowMouseGui
                this.MakeMouseGui()
            this.MoveMouseGui()
            
            ; WinSet, Redraw,, % "OVERLAY ahk_exe AutoHotkey.exe"
        }
        RectangleBuilder.SnappingWindow := false
    }
    static Cursors := {Normal:"C:\Windows\Cursors\aero_arrow.cur", LClick:"C:\Windows\Cursors\aero_link.cur", RClick:"C:\Windows\Cursors\aero_link_i.cur", Wait:"C:\Windows\Cursors\aero_busy.ani"}
    static BackLinkCursors := {0:RectangleBuilder.Cursors.Normal, 1:RectangleBuilder.Cursors.LClick, -1:RectangleBuilder.Cursors.RClick, 2:RectangleBuilder.Cursors.Wait}

    MakeMouseGui()
    {
        global
        local w1,h1,x1,y1,color1,n1,n2
        MouseGetPos, x1, y1
        w1 := Format("{:d}",30) + 0
        h1 := Format("{:d}",30) + 0
        x1 := Format("{:d}",x1 - (w1/2)) + 0
        y1 := Format("{:d}",y1 - (h1/2)) + 0
        
        color1 := "F0FF0F"

        RectangleBuilder.WindowMouseGui  := "MOUSE_GUI_MOUSE_GUI_MOUSE_GUI_"

        n1 := RectangleBuilder.WindowMouseGui

        Gui, OVERLAY:Add, Picture, w%w1% h%h1% x%x1% y%y1% hwnd%n1%_1 v%n1% BackgroundTrans c%color1% Disabled , % RectangleBuilder.Cursors.Normal
        Gui, OVERLAY:Add, Text, x%x1% y%y1% v%n1%TEXT cFFFFFF BackgroundTrans +hwndHANDLE_%n1%TEXT, % "MOUSE CURSOR EMULATOR"
        RectangleBuilder.FrameTimer := new StopWatch
    }
    
    static CurMousePos := { X:0, Y:0, Click:0 }
    static LasMousePos := { X:0, Y:0, Click:0 }

    MoveMouseGui()
    {
        deltaTime := RectangleBuilder.FrameTimer.Stop().getTimeData().get_Raw()
        x1 := RectangleBuilder.CurMousePos.X
        y1 := RectangleBuilder.CurMousePos.Y

        x2 := RectangleBuilder.LasMousePos.X
        y2 := RectangleBuilder.LasMousePos.Y

        x  := lerp(x1,x2,.5-deltaTime)
        y  := lerp(y1,y2,.5-deltaTime)

        w1 := 30
        h1 := 30
        x1 := Format("{:d}",x) + 0
        y1 := Format("{:d}",y) + 0
        
        n1 := RectangleBuilder.WindowMouseGui

        

        if Debugger.ForceHideViews or (Debugger.DoMouseClick or Debugger.DoMouseMove or Debugger.DoSendKeystrokes)
            x1 := -19985
        GuiControl, OVERLAY:MoveDraw, %n1%, x%x1% y%y1% w%w1% h%h1%
        if(RectangleBuilder.CurMousePos.Click != RectangleBuilder.LasMousePos.Click)
        {
            n3 := n1 "_1"
            n3 := %n3%
            v := RectangleBuilder.BackLinkCursors[RectangleBuilder.CurMousePos.Click]
            GuiControl, OVERLAY:, %n3%, % v
            ; GuiControl, OVERLAY:, %n1%, % v
        }
        n2 := "HANDLE_" n1 "TEXT"

        
        if Debugger.ForceHideViews or Debugger.ForceHideLabels or (Debugger.DoMouseClick or Debugger.DoMouseMove or Debugger.DoSendKeystrokes)
            x1 := -19985
        else if x1 = -19985
            x1 := Format("{:d}",x) + 0
        RectangleBuilder.LasMousePos := {X:x,Y:y,Click:RectangleBuilder.CurMousePos.Click}
        x1 += 30
        y1 += 15
        GuiControl, OVERLAY:MoveDraw, %n1%TEXT, x%x1% y%y1%


        WinSet, TOP,, % "ahk_id " . %n1%_1
        WinSet, TOP,, % "ahk_id " . %n2%
        
        RectangleBuilder.FrameTimer.Start()
    }

    static MissingColor := "0xFF00FF"
        
    sanitize_json_object(json_string)
    {
        __string := RegExReplace(json_string, "(?i)(Sorted_)[0-9]{4}_")
        __string := RegExReplace(__string, "(?i)(""FALSE"")","false")
        __string := RegExReplace(__string, "(?i)(""TRUE"")","true")
        __string := RegExReplace(__string, "(?i)(CLASSTYPE)","class")
        __string := RegExReplace(__string, "(?:\.\d*?[1-9])\K0+") ;TRAILING ZEROS
        return __string
    }

    QuickMake(oldW, oldH)
    {
        newX := 0
        newY := 0
        
        newW := oldW
        newH := oldH
        border_thickness := 3

        IfLess, newW, % 6
            newW := 6

        IfLess, newH, % 6
            newH := 6

        window_key := "rect_" . RectangleBuilder.AllWindows.Count()
        ; Gui, %window_key%:New, +Lastfound +AlwaysOnTop +Toolwindow ,%window_key%

        innerX2 := newW - border_thickness
        innerY2 := newH - border_thickness

        ; Gui, %window_key%:Color, %border_color%
        ; Gui, -Caption

        ; WinSet, Region, 0-0 %newW%-0 %newW%-%newH% 0-%newH% 0-0    %border_thickness%-%border_thickness% %innerX2%-%border_thickness% %innerX2%-%innerY2% %border_thickness%-%innerY2% %border_thickness%-%border_thickness% 
        ; Gui, %window_key%:Show, w%newW% h%newH% x%newX% y%newY% NoActivate Hide 
        ; Gui, %window_key%: +AlwaysOnTop        
        obj := new MainWindow(newX, newY, newW, newH, border_thickness, window_key, 0xFF00FF)
        
        obj.set_Key(window_key)

        
        if Anchors.Built
            obj.set_Anchor(Anchors.None)

        RectangleBuilder.AllWindows[window_key] := obj

        return obj
    }

    DrawRect_From_Points(x1,y1,x2,y2,border_thickness:=3,border_color:=0xFF00FF)
    {
        X := Min(x1, x2)
        Y := Min(y1, y2)
        W := Abs(x2 - x1)
        H := Abs(y2 - y1)

        val := this.DrawRect(X, Y, W, H, border_thickness, border_color)
        return val
    }

    Show_AllRects()
    {
        Loop % RectangleBuilder.AllWindows.Count()
        {
            this.ShowRect(A_Index)
        }
    }

    Hide_AllRects()
    {
        val := index
        Loop %val%
        {
            this.HideRect(A_Index)
        }
    }

    Destroy_AllRects()
    {
        Loop % RectangleBuilder.AllWindows.Count()
        {
            this.DestroyRect(A_Index)
        }
    }

    ShowRect(index)
    {
        try{
            ;Gui, %index%:Show 
            ;Gui, %index%: +AlwaysOnTop
        }Catch e {
            Log.Error("[" . A_LineNumber . "][ShowRect]" . index . " does not exist!`n`t" . e.Message)
        }
    }

    HideRect(index)
    {
        Gui, %index%:Hide
    }

    ;probably don't use this one unless you have too
    DestroyRect(index)
    {
        this.get_Window(index).DestroyMe()
    }
    
    MoveRect(gui_title,posX,posY)
    {
        if not (gui_title = unset)
        {
            WinMove, % gui_title " ahk_class AutoHotkeyGUI",,% posX,% posY
        }
    }

    ResizeRect(index, scaleX, scaleY, border_thickness:=-1)
    {
        val := index
        if border_thickness = -1
            border_thickness := RectangleBuilder.get_Window(index).Border
        innerX2:=scaleX-border_thickness
        innerY2:=scaleY-border_thickness
        ; WinSet, Region, 0-0 %scaleX%-0 %scaleX%-%scaleY% 0-%scaleY% 0-0    %border_thickness%-%border_thickness% %innerX2%-%border_thickness% %innerX2%-%innerY2% %border_thickness%-%innerY2% %border_thickness%-%border_thickness%, % val " ahk_class AutoHotkeyGUI"
        ; WinGetPos, posX, posY,,, % val " ahk_class AutoHotkeyGUI"
        ; WinMove, % val " ahk_class AutoHotkeyGUI",,% posX,% posY, % scaleX, % scaleY
        ;this.get_Window(index).set_Scale(scaleX, scaleY)
    }

    ColorRect(index, color)
    {
        val := index
        ; Gui, %val%:Color, %color%
    }
}


class Anchors
{
    static LEFT        := 1
    static TOP         := 2
    static RIGHT       := 3
    static BOTTOM      := 4
    static NONE        := 5

    static MainWindow    := {}
    static LeftAnchor    := {}
    static TopAnchor     := {}
    static BottomAnchor  := {}
    static CenterAnchor  := {}
    static Built         := false
    static _Anchors := []

    Build_Default_Anchors(___Width,___Height)
    {
        this.MainWindow   := RectangleBuilder.QuickMake(___Width,___Height)

        this.MainWindow.set_Color(0x555555)
        this.MainWindow.set_Name("Roblox")
        
        MainWindow.Move(0,0)
        
        this.Built := true

    }
    
    get_anchor(index)
    {
        return this.from_Name(index)
    }

    static fromEnum = {"Left":"EL"
                ,"Top":"ET"
                ,"Right":"ER"
                ,"Bottom":"EB"
                ,"None":"None"
                ,"None":"NA"}

    static fromEnumStr = {"Left":1
                ,"Top":2
                ,"Right":3
                ,"Bottom":4
                ,"None":5
                ,"":5}

    static fromVal = {"EL":1
                ,"ET":2
                ,"ER":3
                ,"EB":4
                ,"None":5
                ,"None":5
                ,"NONE":5
                ,"NA":5}

    from_Name(name)
    {
        if RegExMatch(name,"\d")
        {
            If name between 1 and 5
            {
                return name
            }
        }
        if this.fromEnumStr.HasKey(name)
        {
            return this.fromEnumStr[name]
        }
        if this.fromVal.HasKey(name)
        {
            return this.fromVal[name]
        }
        if this.fromEnumStr.HasKey(%name%)
        {
            return this.fromEnumStr[%name%]
        }
        if this.fromVal.HasKey(%name%)
        {
            return this.fromVal[%name%]
        }
        if this.fromEnumStr[name] > 0
        {
            return this.fromEnumStr[name]
        }
        if this.fromVal[name] > 0
        {
            return this.fromVal[name]
        }
        return -1 . name
    }
    
    
    Quick_Make_Anchor(anchor, parent)
    {
        throw new Error("Change this function!")
        ; window_key := "FixedAnchor_" . Anchors.get_Name(anchor) . "_" . RectangleBuilder.AllWindows.Count()
        ; _obj := new AnchorRectangle(0, 0, parent.Width, parent.Height, 0, window_key, 0xFF00FF)

        ; _obj.set_Key(window_key)
        ; _obj.set_Name("FixedAnchor_" . Anchors.get_Name(anchor))
        ; ;obj.set_Anchor(anchor)

        ; parent.addChild(_obj)

        
        ; ; Gui, %window_key%:New, +Lastfound +AlwaysOnTop +Toolwindow ,%window_key%

        ; newX := 0
        ; newY := 0
        
        ; newW := 1920
        ; newH := 1080
        ; border_thickness := 3

        ; innerX2 := newW - border_thickness
        ; innerY2 := newH - border_thickness

        ; ; Gui, %window_key%:Color, "0x00FF00"
        ; Gui, -Caption

        ; ; WinSet, Region, 0-0 %newW%-0 %newW%-%newH% 0-%newH% 0-0    %border_thickness%-%border_thickness% %innerX2%-%border_thickness% %innerX2%-%innerY2% %border_thickness%-%innerY2% %border_thickness%-%border_thickness% 
        ; ; Gui, %window_key%:Show, w%newW% h%newH% x%newX% y%newY% NoActivate Hide
        ; ; Gui, %window_key%: +AlwaysOnTop
        ; RectangleBuilder.AllWindows[window_key] := _obj
        
        ; Anchors[Anchors.get_Name(anchor)]   := _obj
        return _obj
    }

    getNumber(_obj)
    {
        obj := _obj
        if obj is Alpha
            obj := this.from_Name(_obj)
        if obj > 0
        {
            if obj = 1
                return % "Left" 
            else if obj = 2
                return % "Top"
            else if obj = 3
                return % "Right"
            else if obj = 4
                return % "Bottom"
            else if obj = 5
                return % "Centered" ; % "None"
        }
        return "UNKNOWN"
    }

    getName(value)
    {
        if value is Number
            Return this.getNumber(_value)
        return "UNKNOWN" 
    }
}

class FixedPoint extends Point
{
    
    CLASSTYPE  := "FixedPoint"
    
    __New(x, y, w, h, b, name, color:="")
    {
        base.__New(x, y, w, h, b, name, color)
        this.CLASSTYPE  := "FixedPoint"
    }

    MoveByAnchor(_X,_Y,Parent)
    {   
        this.T_Set(_X + this.X, _Y + this.Y)
        this.Move(_X, _Y)
    }
    
    SnapAdjustToResolution(refInWidth, refInHeight)
    {
        Log.Info(this.Label ? this.Label : this.WindowKey . " is being adjust to match its new anchor resolution [" . refInWidth . "x" . refInHeight . "]")
        this.set_position(this.X, this.Y)
    }
}

class ScaledPoint extends Point
{
    
    CLASSTYPE  := "ScaledPoint"
    
    __New(x, y, w, h, b, name, color:="")
    {
        base.__New(x, y, w, h, b, name, color)
        this.CLASSTYPE  := "ScaledPoint"
    }

    HighOffset(_X,_Y)
    {
        this.HighX := _X
        this.HighY := _Y
    }

    LowOffset(_X,_Y)
    {
        this.LowX := _X
        this.LowY := _Y
    }

    set_Anchor(anchor,skip_warnings:=false)
    {
        this.AnchorRef := anchor
        this.AnchorLocation := anchor
    }

    MoveByAnchor(_X,_Y,Parent)
    {
        _X2 := 0
        _Y2 := 0
            
        XFixed     :=  this.AnchorLocation &  0x1
        YFixed     := (this.AnchorLocation & (0x1 << 1)) >> 1
        shrink     := (this.AnchorLocation & (0x1 << 2)) >> 2
        flag_X     := (this.AnchorLocation & (0x1 << 3)) >> 3
        add_X      := (this.AnchorLocation & (0x1 << 4)) >> 4
        flag_Y     := (this.AnchorLocation & (0x1 << 5)) >> 5
        add_Y      := (this.AnchorLocation & (0x1 << 6)) >> 6

        S_X := (this.X * (this.LastScale ? this.LastScale : 1))
        S_Y := (this.Y * (this.LastScale ? this.LastScale : 1))
            
        PWidth  := RobloxWindow.State.Screen.Width ? RobloxWindow.State.Screen.Width : 2560
        PHeight := RobloxWindow.State.Screen.Height? RobloxWindow.State.Screen.Height : 1440

        if Parent.Label != "Roblox"
        {
            _X3 := Parent.T_X - _X 
            _Y3 := Parent.T_Y - _Y
            
            
            smaller_scale := min(PWidth/2560, PHeight/1440)

            FWidth  := (Parent.FWidth  ? Parent.FWidth  : Parent.CWidth ) * (shrink ? smaller_scale : Parent.LastScale)
            FHeight := (Parent.FHeight ? Parent.FHeight : Parent.CHeight) * (shrink ? smaller_scale : Parent.LastScale)

            if (not (this.LowX = this.HighX))
            {
                if XFixed
                    _X2 += _X + _X3 + lerp(FWidth * this.LowX, FWidth * this.HighX, ((flag_X ? ((Parent.FWidth?Parent.FWidth:Parent.CWidth) * (add_X ? min(RobloxWindow.State.Screen.Width/2560, RobloxWindow.State.Screen.Height/1440) : max(RobloxWindow.State.Screen.Width/2560, RobloxWindow.State.Screen.Height/1440))) : FWidth) * Parent.LastScale))
                Else
                    _X2 += _X + S_X
            }
            else
            {
                if XFixed
                    _X2 += _X + _X3 + ((flag_X ? ((Parent.FWidth?Parent.FWidth:Parent.CWidth) * (add_X ? min(RobloxWindow.State.Screen.Width/2560, RobloxWindow.State.Screen.Height/1440) : max(RobloxWindow.State.Screen.Width/2560, RobloxWindow.State.Screen.Height/1440))) : FWidth) * this.X)
                Else
                    _X2 += _X + _X3 + S_X
            }
            
            if (not (this.LowY = this.HighY))
            {
                if YFixed
                    _Y2 := _Y + _Y3 + lerp(FHeight * this.LowY, FHeight * this.HighY, ((flag_Y ? ((Parent.FHeight?Parent.FHeight:Parent.CHeight) * (add_Y ? min(RobloxWindow.State.Screen.Width/2560, RobloxWindow.State.Screen.Height/1440) : max(RobloxWindow.State.Screen.Width/2560, RobloxWindow.State.Screen.Height/1440))) : FHeight) * Parent.LastScale))
                else
                    _Y2 := _Y + _Y3 + S_Y
            }
            else
            {
                if YFixed
                    _Y2 := _Y + _Y3 + ((flag_Y ? ((Parent.FWidth?Parent.FWidth:Parent.CWidth) * (add_Y ? min(RobloxWindow.State.Screen.Width/2560, RobloxWindow.State.Screen.Height/1440) : max(RobloxWindow.State.Screen.Width/2560, RobloxWindow.State.Screen.Height/1440))) : FHeight) * this.Y)
                else
                    _Y2 := _Y + _Y3 + S_Y
            }
        }
        else
        {
            if (not (this.LowX = this.HighX))
            {
                if XFixed
                    _X2 += _X + lerp(PWidth * this.LowX, PWidth * this.HighX, (PWidth  - 800) / (2560 - 800))
                Else
                    _X2 += _X + (PWidth * S_X)
            }
            else
            {
                if XFixed
                    _X2 += _X + (PWidth * this.X)
                Else
                    _X2 += _X + (PWidth * S_X)
            }

            if (not (this.LowY = this.HighY))
            {
                if YFixed
                    _Y2 := _Y + lerp(PHeight * this.LowY, PHeight * this.HighY, (PHeight - 600) / (1440 - 600))
                else
                    _Y2 := _Y + (PHeight * S_Y)
            }
            else
            {
                if YFixed
                    _Y2 := _Y + (PHeight * this.Y)
                else
                    _Y2 := _Y + (PHeight * S_Y)
            }
        }
        this.T_Set(_X2, _Y2)
        this.Move(_X, _Y)
    }
}

; class MirroredPoint extends Point
 ; {
     
 ;     CLASSTYPE  := "MirroredPoint"
     
 ;     __New(x, y, w, h, b, name, color:="")
 ;     {
 ;         base.__New(x, y, w, h, b, name, color)
 ;         this.CLASSTYPE  := "MirroredPoint"
 ;     }
 
 ;     MoveByAnchor(_X,_Y,Parent)
 ;     {
 ;         _X2 := 0
 ;         _Y2 := 0
         
 ;         PWidth  := RobloxWindow.State.Screen.Width ? RobloxWindow.State.Screen.Width : 2560
 ;         PHeight := RobloxWindow.State.Screen.Height? RobloxWindow.State.Screen.Height : 1440
 
 ;         S_X := (this.X * (this.LastScale ? this.LastScale : 1))
 ;         S_Y := (this.Y * (this.LastScale ? this.LastScale : 1))
         
 ;         HorizontalPlane :=  this.AnchorLocation & 0x1
 ;         VerticlePlane := (this.AnchorLocation & 0x2) >> 1
 ;         Invert := (this.AnchorLocation & 0x4) >> 2
 
 ;         if HorizontalPlane
 ;         {             ;im hoping doing a bit shift is 
 ;             if Invert ;faster then multiply and divide by 2
 ;                 _X2 := ((_X << 1) - PWidth + (S_X << 1)) >> 1
 ;             Else
 ;                 _X2 := _X + PWidth - S_X
 ;         } else
 ;             _X2 := _X + S_X
 
 ;         if VerticlePlane
 ;         {   
 ;             if Invert
 ;                 _Y2 := ((_Y << 1) - PHeight + (S_Y << 1)) >> 1
 ;             else
 ;                 _Y2 := _Y + PHeight - S_Y
 ;         } else
 ;             _Y2 := _Y + S_Y
         
 ;         this.T_Set(_X2, _Y2)
 ;         this.Move(_X, _Y)
 ;     }
 
 ;     SnapAdjustToResolution(refInWidth, refInHeight)
 ;     {
 ;         Log.Info(this.Label ? this.Label : this.WindowKey . " is being adjust to match its new anchor resolution [" . refInWidth . "x" . refInHeight . "]")
         
 ;         inWidth       := refInWidth
 ;         inHeight      := refInHeight
 
 ;         OutWidth      := 2560
 ;         OutHeight     := 1440
         
 ;         scaleW        := min( inWidth   / OutWidth , OutWidth / inWidth  )
 ;         scaleH        := min( OutHeight / inHeight , inHeight / OutHeight)
         
 ;         OutWidthHalf  := OutWidth  / 2
 ;         OutHeightHalf := OutHeight / 2
         
 ;         Switch % Anchors.from_Name(this.AnchorLocation)
 ;         {
 ;             Case 1: ;LEFT
 ;                 this.set_position(this.X * scaleW
 ;                                 , this.Y * scaleH - (OutHeightHalf ))
 ;             Case 2: ;TOP
 ;                 this.set_position(this.X * scaleW - (OutWidthHalf  )
 ;                                 , this.Y * scaleH)
 ;             Case 3: ;RIGTH
 ;                 this.set_position(this.X * scaleW
 ;                                 , this.Y * scaleH - (OutHeightHalf ))
 ;             Case 4: ;BOTTOM
 ;                 this.set_position(this.X * scaleW
 ;                                 , this.Y * scaleH - (OutHeightHalf ))
 ;             case 5: ;Centered/NONE
 ;                 this.set_position(this.X * scaleW - (OutWidthHalf  )
 ;                                 , this.Y * scaleH - (OutHeightHalf ))
 ;             default : ;maybe just center all of it?
 ;                 this.set_position(this.X * scaleW - (OutWidthHalf  )
 ;                                 , this.Y * scaleH - (OutHeightHalf ))
 ;         }
 ;     }
 
 ;     prepForSave()
 ;     {
 ;         ChildrenPrepped := {}
 ;         loop % this.Children.Count()
 ;         {
 ;             _child := this.Children[A_Index]
 ;             new_key_name := "Sorted_" Format("{:04}", A_Index) "_" _child.Label
 ;             ChildrenPrepped[new_key_name] := _child.prepForSave()
 ;         }
         
 ;         mirror := ""
 
 ;         switch (this.AnchorLocation & 0x3)
 ;         {
 ;             case 0 : mirror := "None"
 ;             case 1 : mirror := "Horizontal"
 ;             case 2 : mirror := "Vertical"
 ;             case 3 : mirror := "Both"
 ;         }
 
 ;         mirror .= (((this.AnchorLocation & 0x4) >> 2) ? " Inverted " : " ") . this.AnchorLocation
 
 ;         output := SortedArrayMake("CLASSTYPE", this.CLASSTYPE
 ;                     ,"Label" , this.Label
 ;                     ,"X" , this.X
 ;                     ,"Y" , this.Y
 ;                     ,"HardEdgeScale" , this.UseOuter
 ;                     ,"Visible" , this.Visible ? "TRUE" : "FALSE"
 ;                     ,"MirrorComment" , mirror
 ;                     ,"Children" , ChildrenPrepped )
 ;         if not this.Children.Length()
 ;             SortedArrayRemove(output,"Children")
 ;         return output
 ;     }
; }

class Point extends  Rectangle
{
    CLASSTYPE  := "Point"
    
    __New(x, y, w, h, b, name, color:="")
    {
        base.__New(x, y, w, h, b, name, color)
        this.CLASSTYPE  := "Point"
        this._isAnchor := false
    }

    do_scale(ScreenWidth, ScreenHeight,first:=false)
    {
        _BT := this.Border

        _W2 := this.Width
        _H2 := this.Height

        HW2o := this.Width  / 2 + 1
        HH2o := this.Height / 2 + 1

        HW2_ := this.Width  / 2
        HH2_ := this.Height / 2


        ; oo _o
        ; o_ __


        iX2 := _W2 - _BT
        iY2 := _H2 - _BT

        if this.Visible and allVisible
        {
            ; WinSet, Region,  0-0 %_W2%-0 %_W2%-%_H2% 0-%_H2% 0-0   %_BT%-%_BT% %iX2%-%_BT% %iX2%-%iY2% %_BT%-%iY2% %_BT%-%_BT% , % this.WindowKey " ahk_class AutoHotkeyGUI" ;                  
            ; WinSet, Region,   0-0 %_W2%-0 %_W2%-%_H2% 0-%_H2% 0-0   %_BT%-%_BT% %iX2%-%_BT% %iX2%-%iY2% %_BT%-%iY2% %_BT%-%_BT%  %HW2o%-%HH2_% %HW2_%-%HH2_% %HW2_%-%HH2o% %HW2o%-%HH2o% %HW2o%-%HH2_%       , % this.WindowKey " ahk_class AutoHotkeyGUI"
            ; WinMove, % this.WindowKey " ahk_class AutoHotkeyGUI",,,, % _W2, % _H2
        }
    }

    SetVisibility(vis,now:=false)
    {
        this.Visible := vis
        if vis
            this.Show(now)
        else
            this.Hide(now)
    }
    
    MakeGui()
    {
        global
        local w1, h1, x1, x2, y1, y2, n1, n2, n3, color1, text_, text_W, text_H, text_X, text_Y, font_size
        this.hasGui := true
        
        color1 := SubStr(Format("{:p}", this.Color), 11,6)
        
        this.GUI_WINDOW_HANDLE := "MOVEABLE_" . this.WindowKey
        this.GUI_TEXT_HANDLE   := "HANDLE_" this.GUI_WINDOW_HANDLE "_TEXT"
        
        n1 := this.GUI_WINDOW_HANDLE
        n2 := this.GUI_TEXT_HANDLE

        w1 := Format("{:d}",this.Width) + 0
        h1 := Format("{:d}",this.Height) + 0
        if this.IsAnchor()
        {
            w1 := 3
            h1 := 3
        }

        x1 := Format("{:d}",this.T_X - (w1/2)) + 0
        x2 := min(max(Format("{:d}",this.T_X + w1 + 10) + 0, 10), 2560)

        y1 := Format("{:d}",this.T_Y - (h1/2)) + 0
        y2 := min(max(Format("{:d}",this.T_Y) + 0, 10), 1430)

        Gui, OVERLAY:Add, Progress, w%w1% h%h1% x%x1% y%y1% v%n1% BackgroundTrans c%color1% +Border Disabled, 100
        font_size := "s" . (this.IsAnchor() ? 6 : 9)
        GUI, OVERLAY:Font, %font_size%
        Gui, OVERLAY:Add, Text, x%x2% y%y2% v%n1%_TEXT cFFFFFF BackgroundTrans +hwndHANDLE_%n1%_TEXT, % (Debugger.Visual_ShowObjectKey ? this.WindowKey ":" : "") this.Label

        n3 := %n2%
        GuiControlGet, text_, Pos, %n3%
        this.GUI_TEXT_W := text_W
        this.GUI_TEXT_H := text_H
    }

    MoveGui()
    {
        global
        local w1, h1, x1, x2, y1, y2, n1, n2

        w1 := Format("{:d}",this.Width) + 0
        h1 := Format("{:d}",this.Height) + 0
        if this.IsAnchor()
        {
            w1 := 3
            h1 := 3
        }
        
        x1 := Format("{:d}",this.T_X - (w1/2)) + 0
        if Debugger.ForceHideLabels or not this.Visible or Debugger.ForceHideViews
            x2 := -10000
        else
            x2 := min(max(Format("{:d}",this.T_X + w1) + (this.IsAnchor() ? 10 : 0), 10), 2550-this.GUI_TEXT_W)
        y1 := Format("{:d}",this.T_Y - (h1/2)) + 0
        y2 := min(max(Format("{:d}",y1 - (this.IsAnchor() ? this.GUI_TEXT_H / 2 : 0 )) + 0, this.GUI_TEXT_H), 1440-this.GUI_TEXT_H)

        n1 := this.GUI_WINDOW_HANDLE
        n2 := this.GUI_TEXT_HANDLE

        if Debugger.ForceHideViews or not this.Visible
            y1 := -10000
        GuiControl, OVERLAY:Move, %n1%, x%x1% y%y1% w%w1% h%h1%
        GuiControl, OVERLAY:MoveDraw, %n1%_TEXT, x%x2% y%y2%
        WinSet, TOP,, % "ahk_id " . %n2%
    }

    set_Scale_Position_Now(posX,posY,_,__)
    {
        border_thickness := this.Border
        posW := this.Width
        posH := this.Height
        innerX2 := posW-border_thickness
        innerY2 := posH-border_thickness
        
        this.set_position(posX,posY)
        this.set_Scale(posW,posH)

        posX_OFFSET := posX - (posW / 2)
        posY_OFFSET := posY - (posH / 2)
        
        if this.Visible and allVisible
        {
            ; WinSet, Region, 0-0 %posW%-0 %posW%-%posH% 0-%posH% 0-0    %border_thickness%-%border_thickness% %innerX2%-%border_thickness% %innerX2%-%innerY2% %border_thickness%-%innerY2% %border_thickness%-%border_thickness%, % this.WindowKey " ahk_class AutoHotkeyGUI"
            ; WinMove, % this.WindowKey " ahk_class AutoHotkeyGUI",, % posX_OFFSET, % posY_OFFSET, % posW, % posH
        }
    }
    
    do_move(_X, _Y,first:=false)
    {
        if this.Visible
        {
            X := first ? this.X : this.T_X
            Y := first ? this.Y : this.T_Y

            temp_wind := this.WindowKey

            posX_OFFSET := X - (this.Width  / 2)
            posY_OFFSET := Y - (this.Height / 2)

            ; WinMove, % temp_wind " ahk_exe AutoHotkey.exe",,% posX_OFFSET, % posY_OFFSET
        }
    }
    
    prepForSave()
    {
        ChildrenPrepped := {}
        loop % this.Children.Count()
        {
            _child := this.Children[A_Index]
            new_key_name := "Sorted_" Format("{:04}", A_Index) "_" _child.Label
            ChildrenPrepped[new_key_name] := _child.prepForSave()
        }
        
        output := SortedArrayMake("CLASSTYPE", this.CLASSTYPE
                    ,"Label" , this.Label
                    ,"X" , this.X
                    ,"Y" , this.Y
                    ,"HardEdgeScale" , this.UseOuter
                    ,"Visible" , this.Visible ? "TRUE" : "FALSE"
                    ,"AnchorLocation" , Anchors.getName(this.AnchorLocation)
                    ,"AnchorComment" ,  this.AnchorRef . " " . (this.useOuter ? "Fit on Inside" : "Fit on Outside")
                    ,"Children" , ChildrenPrepped )
        if not this.Children.Length()
                SortedArrayRemove(output,"Children")
        return output
    }

    prepForJsonDump()
    {
        output := Object()
        output := base.prepForJsonDump()
        SortedArrayRemove(output,"Border")
        SortedArrayRemove(output,"Color")
        SortedArrayRemove(output,"Visible")
        return output
    }

    T_SetScale(W,H)
    {
        this.CWidth  := this.Width
        this.CHeight := this.Height
    }
    
    MouseMoveAndClick(WhichButton, speed)
    {
        this.MouseMove(speed)
        this.Click(WhichButton)
    }
    
    MouseMoveAndClickWithSleep(WhichButton, speed, Sleep1, Sleep2_:="")
    {
        local Sleep2
        
        if &Sleep2_ = &unset__________________adsads
            Sleep2 := Sleep1
        Else
            Sleep2 := Sleep2_

        this.MouseMove(speed)
        
        Log.Low_Info("Sleep " Sleep1)
        RectangleBuilder.CurMousePos.Click := 2
        sleep %Sleep1%
        RectangleBuilder.CurMousePos.Click := 0
        
        this.Click(WhichButton)
        
        Log.Low_Info("Sleep " Sleep2)
        RectangleBuilder.CurMousePos.Click := 2
        sleep %Sleep2%
        RectangleBuilder.CurMousePos.Click := 0
    }

    MouseMove(speed)
    {
        Log.Low_Info("MouseMove @" this.T_X ":" this.T_Y)

        ; RectangleBuilder.CurMousePos.X := this.T_X
        ; RectangleBuilder.CurMousePos.Y := this.T_Y
        ; RectangleBuilder.MarkDirty()
        if Debugger.DoMouseMove
            MouseMove, % this.T_X, % this.T_Y, %speed%
    }

    Click(WhichButton)
    {
        ; RectangleBuilder.CurMousePos.Click := instr(WhichButton, "left",false) ? 1 : -1
        if Debugger.DoMouseClick
            MouseClick, %WhichButton% ;, % T_X, % T_Y, % ClickCount, % speed, % DownOrUp, % rel
        Log.Low_Info("MouseClick " WhichButton)
        ; RectangleBuilder.CurMousePos.Click := 0
    }

    PixelSeachPoint(Hex, variation, byref outX := "", byref outY := "")
    {
        return this.PixelSeach(Hex, variation, outX, outY)
    }

    PixelSeach(Hex, variation, byref outX := "", byref outY := "")
    {
        global
        local tempRESET_VIS, el
        Log.Low_Info("PixelSearch @" this.T_X ":" this.T_Y)
        if this.Visible
        {
            this.Hide(true)
            tempRESET_VIS := true
        }
        
        PixelSearch, x, y, % this.T_X, % this.T_Y, % this.T_X, % this.T_Y, % Hex , 3, Fast RGB
        el := ErrorLevel
        outX := x
        outY := y

        if tempRESET_VIS
            this.Show(true)
        
        return el
    }

    PixelGetColor(byref out)
    {
        global
        local tempRESET_VIS, el
        Log.Low_Info("PixelGetColor @" this.T_X ":" this.T_Y)
        if this.Visible
        {
            this.Hide(true)
            tempRESET_VIS := true
        }
        
        PixelGetColor, var_out, % this.T_X, % this.T_Y, RGB
        el := ErrorLevel
        out := var_out

        if tempRESET_VIS
            this.Show(true)
        
        return el
    }

    MoveByAnchor(_X,_Y,Parent)
    {
        _X2 := 0
        _Y2 := 0
        PWidth  := RobloxWindow.State.Screen.Width ? RobloxWindow.State.Screen.Width : 2560
        PHeight := RobloxWindow.State.Screen.Height? RobloxWindow.State.Screen.Height : 1440

        AAnchor := Anchors.MainWindow

        AWidth  := AAnchor.CWidth ? AAnchor.CWidth : 2560
        AHeight := AAnchor.CHeight? AAnchor.CHeight : 1440
        
        MWidth  := (this.CWidth ? this.CWidth : 1)
        MHeight := (this.CHeight ? this.CHeight : 1)

        S_X := (this.X * (this.LastScale ? this.LastScale : 1))
        S_Y := (this.Y * (this.LastScale ? this.LastScale : 1))
        
        Switch % Anchors.from_Name(this.AnchorLocation)
        {
            ;LEFT
            Case 1:
                _X2 := _X + S_X
                _Y2 := _Y + S_Y + ((PHeight) / 2)
            ;TOP
            Case 2:
                _X2 := _X + S_X + ((PWidth) / 2)
                _Y2 := _Y + S_Y
            ;RIGTH
            Case 3:
                _X2 := PWidth + S_X + _X
                _Y2 := ((PHeight) / 2) + _Y + S_Y
            ;BOTTOM
            Case 4:
                _X2 := ((PWidth ) / 2) + _X + S_X
                _Y2 := PHeight + _Y + S_Y
            ;/ Centered
            case 5:
                _X2 := ((PWidth )  / 2) + _X + S_X
                _Y2 := ((PHeight)  / 2) + _Y + S_Y
        }
        
        this.T_Set(_X2, _Y2)
        this.Move(_X, _Y)
    }

    
    isAnchor()
    {
        return this._isAnchor
    }

}

class SearchBox extends  Rectangle
{
    CLASSTYPE  := "SearchBox"
    
    __New(x, y, width, height, border, name, color:="")
    {
        base.__New(x,y,width, height, border, name, color)
        this.CLASSTYPE  := "SearchBox"
    }

    PixelSearch(byref outX, byref outY, color, vari := 3, mode := "")
    {
        global
        local T_X2, T_Y2, el
        T_X2 := T_X + CWidth
        T_Y2 := T_Y + CHeight
        
        PixelSearch, px, py, % this.T_X, % this.T_Y, % this.T_X2, % this.T_Y2, % color, % vari, (mode = "" ? Fast RGB : %mode%)
        el := ErrorLevel
        
        outX := px
        outY := py
        return el
    }
}

class AnchorRectangle extends Rectangle
{
    CLASSTYPE :=  "AnchorRectangle"
    
    
    __New(x, y, width, height, border, name, color:="")
    {
            throw new Error("Change this function!")
        base.__New(x,y,width, height, border, name, color)
        this.Visible := allVisible
        this.CLASSTYPE :=  "AnchorRectangle"
    }
    prepForSave()
    {
        ChildrenPrepped := {}
        loop % this.Children.Count()
        {
            _child := this.Children[A_Index]
            new_key_name := "Sorted_" Format("{:04}", A_Index) "_" _child.Label
            ChildrenPrepped[new_key_name] := _child.prepForSave() := _child.prepForSave()
        }
        
        output := SortedArrayMake("CLASSTYPE", this.CLASSTYPE
                    ,"Label" , this.Label
                    ,"X" , this.X
                    ,"Y" , this.Y
                    ,"HardEdgeScale" , this.UseOuter
                    ,"AnchorLocation" , Anchors.getName(this.AnchorLocation)
                    ,"AnchorComment" , this.AnchorRef . " " . (this.useOuter ? "Fit on Inside" : "Fit on Outside")
                    ,"Children" , ChildrenPrepped )
        if not this.Children.Length()
            SortedArrayRemove(output,"Children")
        return output
    }

    prepForJsonDump()
    {
        ChildrenPrepped := {}
        loop % this.Children.Count()
        {
            _child := this.Children[A_Index]
            new_key_name := "Sorted_" Format("{:04}", A_Index) "_" _child.Label
            ChildrenPrepped[new_key_name] := _child.prepForSave() := _child.prepForJsonDump()
        }
        
        output := SortedArrayMake("CLASSTYPE", this.CLASSTYPE
                    ,"AnchorLocation" , Anchors.getName(this.AnchorLocation)
                    ,"AnchorScaleType" , this.useOuter ? "Fit Inside" : "Fit Outside"
                    ,"Children" , ChildrenPrepped )
        if not this.Children.Length()
            SortedArrayRemove(output,"Children")
        return output
    }
    
    isAnchor()
    {
        return true
    }

    set_anchor_internal(the_anchor)
    {
        if not the_anchor is Number
        {
            Log.Error(this.Label . " Tried to set " . the_anchor " as its anchor!")
            Return
        }

        this.AnchorLocation := the_anchor
        this.AnchorRef      :=  Anchor.get_Name(the_anchor)
    }
}

class MainWindow extends  Rectangle
{
    CLASSTYPE :=  "MainWindow"
    
    __New(x, y, width, height, border, name, color:="")
    {
        base.__New(x,y,width, height, border, name, color)
        this.CLASSTYPE :=  "MainWindow"
    }

    prepForSave()
    {
        ChildrenPrepped := {}
        loop % this.Children.Count()
        {
            _child := this.Children[A_Index]
            new_key_name := "Sorted_" Format("{:04}", A_Index) "_" _child.Label
            ChildrenPrepped[new_key_name] := _child.prepForSave() := _child.prepForSave()
        }
        
        output := SortedArrayMake("CLASSTYPE", this.CLASSTYPE
                    ,"Label" , this.Label
                    , "PosSize", SortedArrayMake("Width" , this.Width
                                   ,"Height" , this.Height)
                    ,"Color" , "0x" . SubStr(Format("{:p}", this.Color), 11,6)
                    ,"Visible" , this.Visible ? "TRUE" : "FALSE"
                    ,"Children" , ChildrenPrepped )
        if not this.Children.Length()
            SortedArrayRemove(output,"Children")
        return output
    }
    
    prepForJsonDump()
    {
        ChildrenPrepped := {}
        loop % this.Children.Count()
        {
            _child := this.Children[A_Index]
            new_key_name := "Sorted_" Format("{:04}", A_Index) "_" _child.Label
            ChildrenPrepped[new_key_name] := _child.prepForSave() := _child.prepForJsonDump()
        }
        
        output := SortedArrayMake("CLASSTYPE", this.CLASSTYPE
                    ,"Children" , ChildrenPrepped )
        if not this.Children.Length()
            SortedArrayRemove(output,"Children")
        
        return output
    }


    addChild(child)
    {
        if not (child.Label = this.Label)
            base.addChild(child)
    }
    ; Move(_X,_Y,first:=false)
    ; {
    ;     Log.Info("MOVING Main!!!")
    ;     base.Move(_X,_Y,first)
    ; }
}

class ProtoRect
{

    ;static CLASSTYPE  := "Rectangle"
    CLASSTYPE       := "Rectangle"
    X              := unset
    Y              := unset
    Width          := unset
    Height         := unset
    Border         := 3
    Color          :=  MissingColor
    Label          := unset
    WindowKey      := unset
    AnchorLocation :=  Anchor.None
    AnchorRef      := "Center"
    Visible        := True
    UseOuter       := false

    Children := []

    stored_monitor_stats := false

    CWidth  := 0
    CHeight := 0
    
    LastScale := 1
    T_X := 0
    T_Y := 0

    __New(x, y, width, height, border, name, color:="")
    {
        this.X          := x
        this.Y          := y
        this.T_X        := x
        this.T_Y        := y
        this.Width      := width
        this.Height     := height
        this.Border     := border
        this.WindowKey  := name
        this.UseOuter   := false

        if color != "" or (color is xdigit)
            this.Color := color

        if name = ""
            this.Label := "Rectangle"
        else if (name is alpha) or (name is alnum)
            this.Label := name
        else
            this.Label := "Rectangle"
        
        this.Visible := true
        this.Children := []
        this.stored_monitor_stats := False
        
        this.CWidth  := 0
        this.CHeight := 0
        
        this.LastScale := 1

        this.AnchorLocation := 0
        this.AnchorRef := ""

        Anchors.MainWindow.addChild(this)
        this.set_Anchor(Anchors.None)
    }

    SnapToSides()
    {
        this.UseOuter := true
    }

    SnapAdjustToResolution(refInWidth, refInHeight)
    {
        Log.Info(this.Label ? this.Label : this.WindowKey . " is being adjust to match its new anchor resolution [" . refInWidth . "x" . refInHeight . "]")
        
        inWidth       := refInWidth
        inHeight      := refInHeight

        OutWidth      := 2560
        OutHeight     := 1440
        
        scaleW        := min( inWidth   / OutWidth , OutWidth / inWidth  )
        scaleH        := min( OutHeight / inHeight , inHeight / OutHeight)
        
        OutWidthHalf  := OutWidth  / 2
        OutHeightHalf := OutHeight / 2
        
        ;    switch (((this.useOuter = 1) or (this.useOuter)) ? true : false)
        ;    {
        ;    case true :
        Switch % Anchors.from_Name(this.AnchorLocation)
        {
            Case 1: ;LEFT
                this.set_position(this.X * scaleW
                                , this.Y * scaleH - (OutHeightHalf ))
            Case 2: ;TOP
                this.set_position(this.X * scaleW - (OutWidthHalf  )
                                , this.Y * scaleH)
            Case 3: ;RIGTH
                this.set_position(this.X * scaleW
                                , this.Y * scaleH - (OutHeightHalf ))
            Case 4: ;BOTTOM
                this.set_position(this.X * scaleW
                                , this.Y * scaleH - (OutHeightHalf ))
            case 5: ;Centered/NONE
                this.set_position(this.X * scaleW - (OutWidthHalf  )
                                , this.Y * scaleH - (OutHeightHalf ))
            default : ;maybe just center all of it?
                this.set_position(this.X * scaleW - (OutWidthHalf  )
                                , this.Y * scaleH - (OutHeightHalf ))
        }
        ;    }
    }

    SnapToOppositeEdge()
    {
        this.UseOuter := false
    }

    set_Name(name)
    {
        this.Label := name
    }

    get_position()
    {
        return {X:this.X,Y:this.Y}
    }

    get_scale()
    {
        return {Width:this.Width,Height:this.Height}
    }

    get_center()
    {
        return {Width:this.Width / 2,Height:this.Height / 2}
    }

    get_center_on()
    {
        return {X:this.X + (this.Width / 2),Y:this.Y + (this.Height / 2)}
    }

    set_position(_x,_y)
    {
        this.X := _x
        this.Y := _y
    }

    set_Scale(width,height)
    {
        this.Width  := width
        this.Height := height
    }

    set_Color(hex)
    {
        if hex = "" or not (hex is xdigit)
            this.Color := RectangleBuilder.MissingColor
        else
            this.Color := hex
        _val := this.WindowKey
        Gui, %_val%:Color, %hex%
    }
    
    set_Key(key)
    {
        if not (key = unset or key = "")
            this.WindowKey := key
    }

    checkOffset(x,y)
    {
        Log.Error(this.Label " X: " (x - this.T_X) " Y:" (y - this.T_Y))
    }

    set_Anchor(anchor,skip_warnings:=false)
    {
        if not skip_warnings
        {
            if not anchor is Number
                Log.Error(this.Label . " Tried to set " . anchor " as its anchor!")
        }
        
        ; Anchors.get_anchor(this.AnchorRef).removeChild(this)
        
        this.AnchorRef := Anchors.getNumber(anchor)
        this.AnchorLocation := Anchors.from_Name(anchor)
    }

    NoAnchor()
    {
        Anchors[this.AnchorRef].removeChild(this)
        this.Delete("AnchorRef")
        this.Delete("AnchorLocation")
    }
    
    NoChildren()
    {
        this.ClearChildren()
        this.Remove("Childern")
    }

    ClearChildren()
    {
        if(this.Children.Count() > 0)
        {
            loop % this.Children.Count()
            {
                this.Children[A_Index].ClearChildren()
                this.Children[A_Index].DestroyMe()
            }
        }
        this.Children := {}
    }

    DestroyMe()
    {
        this.Hide()
        RectangleBuilder.AllWindows.Delete(index)
        RectangleBuilder.AllWindows[index] := {}
        RectangleBuilder.AllWindows.Delete(index)
        RectangleBuilder.AllWindows.Remove(Key)
    }

    isAnchor()
    {
        return false
    }

    GetWindowKey()
    {
        return this.WindowKey
    }

    T_Set(X,Y)
    {
        this.T_X := format("{:d}", X) + 0
        this.T_Y := format("{:d}", Y) + 0
    }

    T_SetScale(W,H)
    {
        this.CWidth  := format("{:d}", W) + 0
        this.CHeight := format("{:d}", H) + 0
    }

    addChild(child)
    {
        if child.Label ~= "EditorRect"
            return
        for _, Win in RectangleBuilder.AllWindows
            Win.removeChild(child)
        this.Children.push(child)
    }
    
    removeChild(child)
    {
        childfound := false
        loop % this.Children.Count()
            if this.Children[A_Index] = child
            {
                _indexed_number := A_Index
                this.Children.RemoveAt( _indexed_number )
                break
            }
        loop % this.Children.Count()
            if this.Children[A_Index] = child
            {
                Log.Error("did not delete! " . this.Children[A_Index].Label)
            }
    }

    Hide(now:=true)
    {
        WindowGui := this.GUI_WINDOW_HANDLE
        WindowGui2 := this.GUI_TEXT_HANDLE
        GuiControl, OVERLAY:Hide, %WindowGui%
        GuiControl, OVERLAY:Hide, %WindowGui2%_TEXT
        if now
            try{
                RectangleBuilder.HideRect(this.WindowKey)
            }Catch e {
                Log.Error("[" . A_LineNumber . "][Hide]" . this.Label . ":" . this.WindowKey . " does not exist!`n`t" . e.Message)
            }
    }
    
    Show(now:=true)
    {
        WindowGui := this.GUI_WINDOW_HANDLE
        WindowGui2 := this.GUI_TEXT_HANDLE
        GuiControl, OVERLAY:Show, %WindowGui%
        GuiControl, OVERLAY:Show, %WindowGui2%_TEXT

        if now
            try{
                ; MouseMove % T_X, % T_Y
                RectangleBuilder.ShowRect(this.WindowKey)
            }Catch e {
                Log.Error("[" . A_LineNumber . "][Show]" . this.Label . ":" . this.WindowKey . " does not exist!`n`t" . e.Message)
            }
    }

    SetVisibility(vis,now:=false)
    {
        local
        this.Visible := vis
        if vis
            this.Show(now)
        else
            this.Hide(now)
    }

    SetVisibility_R(vis, now:=false)
    {
        this.SetVisibility(vis, now)
        if this.Children.Count() > 0
        {
            Log.Low_Info("[" . this.Label . ":" . this.WindowKey . "] has children that need to be recursively hid!!")
            for key, child in this.Children
            {
                Log.Low_Info(json.dump(key))
                child.SetVisibility_R(vis, now)
            }
        }
    }
}

class SaveableProtoRect extends ProtoRect
{

    prepForJsonDump()
    {
        ChildrenPrepped := {}
        loop % this.Children.Count()
        {
            _child := this.Children[A_Index]
            new_key_name := "Sorted_" Format("{:04}", A_Index) "_" _child.Label
            ChildrenPrepped[new_key_name] := _child.prepForSave() := _child.prepForJsonDump()
        }
        Vector2d := SortedArrayMake("X" , this.X
                    ,"Y" , this.Y
                    ,"CurrentX" , this.T_X
                    ,"CurrentY" , this.T_Y
                    ,"Width" , this.Width
                    ,"Height" , this.Height
                    ,"CurrentWidth" , this.cWidth
                    ,"CurrentHeight" , this.cHeight)
        if not (Debugger.Log_More_Info or Debugger.Log_Basic_Info)
        {
            SortedArrayRemove(Vector2d,"CurrentX")
            SortedArrayRemove(Vector2d,"CurrentY")
            SortedArrayRemove(Vector2d,"CurrentWidth")
            SortedArrayRemove(Vector2d,"CurrentHeight")
        }

        output := SortedArrayMake("CLASSTYPE", this.CLASSTYPE
                    , "PosSize", Vector2d
                    , "Border" , this.Border
                    , "HardEdgeScale" , this.UseOuter
                    , "Color" , "0x" . SubStr(Format("{:p}", this.Color), 11,6)
                    , "Visible" , this.Visible ? "TRUE" : "FALSE"
                    , "AnchorLocation" , Anchors.getName(this.AnchorLocation)
                    , "AnchorScaleType" , this.useOuter ? "Fit Inside" : "Fit Outside"
                    , "Children" , ChildrenPrepped )
        if not this.Children.Length()
            SortedArrayRemove(output,"Children")
        return output
    }

    
    prepForSave()
    {
        ChildrenPrepped := {}
        loop % this.Children.Count()
        {
            _child := this.Children[A_Index]
            new_key_name := "Sorted_" Format("{:04}", A_Index) "_" _child.Label
            ChildrenPrepped[new_key_name] := _child.prepForSave() := _child.prepForSave()
        }
        
        output := SortedArrayMake("CLASSTYPE", this.CLASSTYPE
                    ,"Label" , this.Label
                    ,"X" , this.X
                    ,"Y" , this.Y
                    ,"Width" , this.Width
                    ,"Height" , this.Height
                    ,"Border" , this.Border
                    ,"HardEdgeScale" , this.UseOuter
                    ,"Color" , "0x" . SubStr(Format("{:p}", this.Color), 11,6)
                    ,"Visible" , this.Visible ? "TRUE" : "FALSE"
                    ,"AnchorLocation" , Anchors.getName(this.AnchorLocation)
                    ,"AnchorComment" ,  this.AnchorRef . " " . (this.useOuter ? "Fit on Inside" : "Fit on Outside")
                    ,"Children" , ChildrenPrepped )
        if not this.Children.Length()
            SortedArrayRemove(output,"Children")
        return output
    }
    
    fromJsonObject(object, label, refInWidth  := 2560, refInHeight := 1440)
    {
        this.set_Name(label)
        this.set_Anchor(RectangleBuilder.Anchor.get_Name((object.AnchorLocation)))

        if RegExMatch(object.color,QuickRegex.Num_Hex)
            this.Color := object.color
        else
            this.Color := RectangleBuilder.MissingColor

        if RegExMatch(object.X, QuickRegex.Num_Int) and RegExMatch(object.Y, QuickRegex.Num_Int)
            this.set_position(object.X, object.Y)
        
        if RegExMatch(object.Width, QuickRegex.Num_Int) and RegExMatch(object.Height, QuickRegex.Num_Int)
            this.set_Scale(object.Width,object.Height)
        else
            this.set_Scale(100,100)

        if RegExMatch(object.Visible, QuickRegex.True_False)
            this.SetVisibility(object.Visible)
        Else
            this.SetVisibility(False)

        if RegExMatch(object.HardEdgeScale, QuickRegex.True_False)
            this.UseOuter := object.HardEdgeScale
        else
            this.UseOuter := false

        if RegExMatch(object.Border, QuickRegex.Num_Int)
            this.Border := object.Border
        else
            this.Border := 3
        
        Log.Info(this.CLASSTYPE . " has been made labeled " . this.Label)
        
        inWidth       := refInWidth
        inHeight      := refInHeight

        AAnchor       := Anchors.MainWindow

        OutWidth      := AAnchor.Width
        OutHeight     := AAnchor.Height
        scaleW        := min( inWidth  / OutWidth, OutWidth  / inWidth )
        scaleH        := min( PHeight  / inHeight, inHeight  / PHeight )
        
        OutWidthHalf  := OutWidth  / 2
        OutHeightHalf := OutHeight / 2
        
        switch (((this.useOuter = 1) or (this.useOuter)) ? true : false)
        {
        case true :
            Switch % Anchors.from_Name(this.AnchorLocation)
            {
            Case 1: ;LEFT
                this.set_position(this.X * scaleW
                                , this.Y * scaleH - (OutWidthHalf + AAnchor.Y))
            Case 2: ;TOP
                this.set_position(this.X * scaleW - (OutWidthHalf + AAnchor.X)
                                , this.Y * scaleH)
            Case 3: ;RIGTH
                this.set_position(this.X * scaleW
                                , this.Y * scaleH - (OutHeightHalf + AAnchor.Y))
            Case 4: ;BOTTOM
                this.set_position(this.X * scaleW
                                , this.Y * scaleH - (OutHeightHalf + AAnchor.Y))
            case 5: ;Centered/NONE
                this.set_position(this.X * scaleW - (OutWidthHalf  + AAnchor.X)
                                , this.Y * scaleH - (OutHeightHalf + AAnchor.Y))
            }
        case false : ;maybe just center all of it?
            this.set_position(this.X * scaleW - (OutWidthHalf  + AAnchor.X)
                            , this.Y * scaleH - (OutHeightHalf + AAnchor.Y))
        }
        return this
    }
}

class Rectangle extends SaveableProtoRect
{
    __New(x, y, width, height, border, name, color:="")
    {
        base.__New(x, y, width, height, border, name, color)
    }

    ScaleByParent(ScreenWidth, ScreenHeight, Parent)
    {
        Saved_Size := Anchors.MainWindow

        PH2 := ScreenHeight
        PW2 := ScreenWidth
        
        PW3 := 2560
        PH3 := 1440
        

        smaller_scale := max(PW2/PW3, PH2/PH3)
        
        if (this.AnchorLocation = 4) or (this.AnchorLocation = 2)
        {
            bigger_scale  := PW2/PW3
        }
        else if (this.AnchorLocation = 3) or (this.AnchorLocation = 1)
        {
            bigger_scale  := PH2/PH3
        }
        else
        {
            bigger_scale := Min(PW2/PW3, PH2/PH3)
        }
        

        scale := 1
        if this.UseOuter
            scale := bigger_scale
        Else
            scale := smaller_scale

        W2 := (this.Width  * scale)
        H2 := (this.Height * scale)

        this.LastScale := scale
        
        this.CWidth  := W2
        this.CHeight := H2
        
        this.Scale(ScreenWidth, ScreenHeight)
    }

    do_scale(ScreenWidth, ScreenHeight,first:=false)
    {
        border_thickness := this.Border

        W2 := first ? ScreenWidth : this.CWidth
        H2 := first ? ScreenHeight : this.CHeight

        innerX2 := W2-border_thickness
        innerY2 := H2-border_thickness

        if this.Visible and allVisible
        {
            
            this.drawable.SetWidth(this.CWidth,this.CHeight)
            ; WinSet, Region, 0-0 %W2%-0 %W2%-%H2% 0-%H2% 0-0    %border_thickness%-%border_thickness% %innerX2%-%border_thickness% %innerX2%-%innerY2% %border_thickness%-%innerY2% %border_thickness%-%border_thickness%, % this.WindowKey " ahk_class AutoHotkeyGUI"
            ; WinMove, % this.WindowKey " ahk_class AutoHotkeyGUI",,,, % W2, % H2
        }
    }
    
    Scale(ScreenWidth,ScreenHeight)
    {
        this.do_scale(ScreenWidth,ScreenHeight)
        loop % this.Children.Count()
            this.Children[A_Index].ScaleByParent(ScreenWidth,ScreenHeight,this)
    }

    set_Scale_Position_Now(posX,posY,posW,posH)
    {
        border_thickness := this.Border

        innerX2 := posW-border_thickness
        innerY2 := posH-border_thickness
        
        this.set_position(posX,posY)
        this.set_Scale(posW,posH)
        
        if this.Visible and allVisible
        {
            ; WinSet, Region, 0-0 %posW%-0 %posW%-%posH% 0-%posH% 0-0    %border_thickness%-%border_thickness% %innerX2%-%border_thickness% %innerX2%-%innerY2% %border_thickness%-%innerY2% %border_thickness%-%border_thickness%, % this.WindowKey " ahk_class AutoHotkeyGUI"
            ; WinMove, % this.WindowKey " ahk_class AutoHotkeyGUI",, % posX, % posY, % posW, % posH
        }
    }

    MoveByAnchor(_X,_Y,Parent)
    {
        _X2 := 0
        _Y2 := 0
        PWidth  := RobloxWindow.State.Screen.Width ? RobloxWindow.State.Screen.Width : 2560
        PHeight := RobloxWindow.State.Screen.Height? RobloxWindow.State.Screen.Height : 1440

        AAnchor := Anchors.MainWindow

        AWidth  := AAnchor.CWidth ? AAnchor.CWidth : 2560
        AHeight := AAnchor.CHeight? AAnchor.CHeight : 1440
        
        MWidth  := (this.CWidth ? this.CWidth : 1)
        MHeight := (this.CHeight ? this.CHeight : 1)

        S_X := (this.X * (this.LastScale ? this.LastScale : 1))
        S_Y := (this.Y * (this.LastScale ? this.LastScale : 1))

        Switch % Anchors.from_Name(this.AnchorLocation)
        {
            ;LEFT
            Case 1:
                _X2 := _X + S_X
                _Y2 := _Y + S_Y  ;  - ((PHeight) / 2)
            ;TOP
            Case 2:
                _X2 := _X + S_X  ;  - ((PWidth) / 2) 
                _Y2 := _Y + S_Y
            ;RIGTH
            Case 3:
                _X2 := (_X + PWidth) - (MWidth + S_X)
                _Y2 := _Y + S_Y 
            ;BOTTOM
            Case 4:
                _X2 := _X + S_X
                _Y2 := (_Y + PHeight) - (MHeight + S_Y)
            ;/ Centered
            case 5:                                         ;IDK WHEN I CHANGED ALL THIS BUT IT BROKE
                _X2 :=_X + S_X  + ((PWidth - MWidth) / 2)   ; wrong?
                _Y2 :=_Y + S_Y  + ((PHeight - MHeight) / 2) ; wrong?
        }
        
        this.T_Set(_X2, _Y2)
        this.Move(_X, _Y)
    }

    Move(_X,_Y,first:=false)
    {
        this.do_move(this.T_X, this.T_Y, first)
        if(this.Children.Count() > 0)
        {
            loop % this.Children.Count()
                this.Children[A_Index].MoveByAnchor(_X, _Y, this)
        }
    }
    
    do_move(_X, _Y,first:=false)
    {
        if this.Visible
        {
            X := first ? this.X : this.T_X
            Y := first ? this.Y : this.T_Y

            temp_wind := this.WindowKey
            ;WinMove, % temp_wind " ahk_exe AutoHotkey.exe",,% X, % Y
        }
    }

    MakeGui()
    {
        global
        local w, h, x, y, color, n1, n2, x2, y2, text_, text_W, text_H, text_X, text_Y
        this.hasGui := true
        
        w  := Format("{:d}",this.CWidth  ? this.CWidth  : this.Width) + 0
        h  := Format("{:d}",this.CHeight ? this.CHeight : this.Height) + 0
        x  := Format("{:d}",this.T_X) + 0
        x2 := min(max(Format("{:d}",x + w) + 0, 10), 2560)
        y  := Format("{:d}",this.T_Y) + 0
        y2 := min(max(Format("{:d}",y + h - 10)  + 0, 10), 1430)

        
        
        color := SubStr(Format("{:p}", this.Color), 11,6)
        
        this.GUI_WINDOW_HANDLE := "MOVEABLE_" . this.WindowKey
        this.GUI_TEXT_HANDLE   := "HANDLE_" this.GUI_WINDOW_HANDLE "_TEXT"
        
        n1 := this.GUI_WINDOW_HANDLE
        n2 := this.GUI_TEXT_HANDLE

        Gui, OVERLAY:Add, Text, x%x2% y%y2% v%n1%_TEXT cFFFFFF BackgroundTrans +Hwnd%n2%, % (Debugger.Visual_ShowObjectKey ? this.WindowKey ":" : "") this.Label
        Gui, OVERLAY:Add, Progress, w%w% h%h% x%x% y%y% v%n1% BackgroundTrans c%color% +Border Disabled, 100
        WinSet, TOP,, % "OVERLAY ahk_id " %n2%

        n3 := %n2%
        GuiControlGet, text_, Pos, %n3%
        this.GUI_TEXT_W := text_W
        this.GUI_TEXT_H := text_H
    }
    
    MoveGui()
    {
        global
        local w, h, x, y, color, n1, n2, x2, y2

        n1 := this.GUI_WINDOW_HANDLE
        n2 := this.GUI_TEXT_HANDLE

        w  := Format("{:d}",this.CWidth  ? this.CWidth  : this.Width) + 0
        h  := Format("{:d}",this.CHeight ? this.CHeight : this.Height) + 0
        x  := Format("{:d}",this.T_X) + 0
        x2 := min(max(Format("{:d}",x + (w/2) - (this.GUI_TEXT_W/2)) + 0, 10), 2560 - (this.GUI_TEXT_W + 10))
        y  := Format("{:d}",this.T_Y) + 0
        y2 := min(max(Format("{:d}",y + (h/2) - (this.GUI_TEXT_H/2)) + 0, this.GUI_TEXT_H), 1440 - (this.GUI_TEXT_H))
        if (h < this.GUI_TEXT_H)
            y2 += this.GUI_TEXT_H
        else if (w < this.GUI_TEXT_W)
            x2 := min(max(x + w + 10, 10), 2560 - (this.GUI_TEXT_W + 10))

        if Debugger.ForceHideLabels or not this.Visible or Debugger.ForceHideViews
            x2 := -10000
        
        if Debugger.ForceHideViews or not this.Visible
            x  := -10000

        GuiControl, OVERLAY:Move, %n1%_TEXT, x%x2% y%y2%
        GuiControl, OVERLAY:Move, %n1%,      x%x% y%y% w%w% h%h%
        WinSet, TOP,, % "OVERLAY ahk_id " %n2%
    }
}