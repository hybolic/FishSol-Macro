#Include core\Timer.ahk
#include core\log.ahk
#Include core\Rectangle.ahk
#include core\RectPlugin.ahk

;abstraction class
class Window{
    
     /**
     * @class Window
     * @classdesc Window
     * @param {String} winExe - the window EXE this class is monitoring
     * @constructor
     */ 
    __New(winExe) {
        Window.lastInstance := this
        this.WindowID := winExe

        ;gets dpi from ahk runtime but do note after startup its not updated
        Window.WindowsDPIScale := A_ScreenDPI / 96
        ;so we do it ourselves
        OnMessage(Window.WM_DISPLAYCHANGE, "Window.DpiChange")

        ;window border and title bar sizes
        SysGet, temp_wh_tbb,    % Window.SM_CXSIZE
        SysGet, temp_wh_tbb_s,  % Window.SM_CYSMICON
        SysGet, temp_wh_bs,     % Window.SM_CXSIZEFRAME
        SysGet, temp_wh_bp,     % Window.SM_CXPADDEDBORDER
        
        this.win_WH_TitleBarButton   := temp_wh_tbb
        this.win_WH_TitleBarButton_Small := temp_wh_tbb_s
        this.win_WH_BorderSize       := temp_wh_bs
        this.win_WH_BorderPadding    := temp_wh_bp

        this.win_WH_FrameWithPadding := this.win_WH_BorderSize + this.win_WH_BorderPadding

        ;Excluded TitleBar
        this.Offset_Width_Windowed   :=  this.win_WH_FrameWithPadding * 2
        this.Offset_Height_Windowed  := (this.win_WH_FrameWithPadding * 2) + this.win_WH_TitleBarButton_Small
        this.Offset_X_Windowed       :=  this.win_WH_BorderSize
        this.Offset_Y_Windowed       :=  this.win_WH_TitleBarButton_Small + this.win_WH_BorderSize
        this.State := { FullScreen:false
                    , BorderLess:false
                    , Maximised:false
                    , WindowState : "ClosedApplication"
                    , Screen:{X:0,Y:0,Width:0,Height:0}
                    , Focus:false
                    , Locked:false}
    }

    static lastInstance := ""
    /**
     * @fixed {Number}
     * @description {@link https://learn.microsoft.com/en-us/windows/win32/gdi/wm-displaychange|WM_DISPLAYCHANGE}
     */
    static WM_DISPLAYCHANGE := 0x7E

    /**
     * @fixed {Number}
     * @description {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics#SM_CXSIZE|SM_CXSIZE}
     */
    static SM_CXSIZE := 30
    /**
     * @fixed {Number}
     * @description {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics#SM_CYSIZE|SM_CYSIZE}
     */
    static SM_CYSIZE := 31
    
    /**
     * @fixed {Number}
     * @description {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics#SM_CXSMICON|SM_CXSMICON}
     */
    static SM_CXSMICON := 49
    /**
     * @fixed {Number}
     * @description {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics#CYSMICON|SM_CYSMICON}
     */
    static SM_CYSMICON := 50

    /**
     * @fixed {Number}
     * @description {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics#SM_CXSIZEFRAME|SM_CXSIZEFRAME}
     */
    static SM_CXSIZEFRAME := 32
    /**
     * @fixed {Number}
     * @description {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics#SM_CXPADDEDBORDER|SM_CXPADDEDBORDER}
     */
    static SM_CXPADDEDBORDER := 92

    /**
     * @static {Number} win_WH_TitleBarButton
     */
    static win_WH_TitleBarButton := 0
    /**
     * @static {Number} win_WH_TitleBarButton_Small
     */
    static win_WH_TitleBarButton_Small := 0
    /**
     * @static {Number} win_WH_BorderSize
     */
    static win_WH_BorderSize := 0
    static win_WH_BorderPadding := 0
    static win_WH_FrameWithPadding := 0

    ;local

    Offset_Width_Windowed := 0
    Offset_Height_Windowed := 0
    Offset_X_Windowed := 0
    Offset_Y_Windowed := 0

    Offset_Width_Maximized := 0
    Offset_Height_Maximized := 0
    Offset_X_Maximized := 0
    Offset_Y_Maximized := 0

    static WindowsDPIScale := 1

    State := {}

    WindowID      := ""
    temp_WindowID := ""

    /**
     * @description {@link https://www.autohotkey.com/boards/viewtopic.php?style=19&t=102586#p456809|LizardCobra} thank you for this peice of code
     * @function
     * @param {Number} wParam
     * @param {Number} lParam
     */
    DpiChange( wParam, lParam) {
        DPI_AWARENESS_CONTEXT := DllCall("User32.dll\GetThreadDpiAwarenessContext", "ptr")
        DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
        SysGet, monNum, MonitorPrimary
        DllCall("Shcore\GetScaleFactorForMonitor", "Ptr", Window.EnumMonitors()[monNum], "UIntP", scale)
        Window.WindowsDPIScale := scale / 100
        DllCall("SetThreadDpiAwarenessContext", "ptr", DPI_AWARENESS_CONTEXT, "ptr")
    }

    /**
     * @description {@link https://www.autohotkey.com/boards/viewtopic.php?style=19&t=102586#p456809|LizardCobra} thank you for this peice of code<br/>
     *              {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-enumdisplaymonitors|User32\EnumDisplayMonitors}
     * @function
     */
    EnumMonitors() {
        global EnumProc := RegisterCallback("Window.MonitorEnumProc")
        global Monitors := []
        return DllCall("User32\EnumDisplayMonitors", "Ptr", 0, "Ptr", 0, "Ptr", EnumProc, "Ptr", &Monitors, "Int") ? Monitors : false
    }

    /**
     * @description {@link https://www.autohotkey.com/boards/viewtopic.php?style=19&t=102586#p456809|LizardCobra} thank you for this peice of code<br/>
     *              {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-monitorenumproc|User32\MonitorEnumProc}
     * @function
     * @param {?HMONITOR} hMonitor
     * @param {?HDC} hDC
     * @param {?LPRECT} pRECT
     * @param {?LPARAM} ObjectAddr
     * @return {Boolean} true
     */
    MonitorEnumProc(hMonitor, hDC, pRECT, ObjectAddr) {
        global Monitors := Object(ObjectAddr)
        Monitors.Push(hMonitor)
        return true
    }

    
    getWindowForUpdates()
    {
        IfWinExist, % "ahk_exe" . " " . this.WindowID
            this.temp_WindowID := "ahk_exe" . " " . this.WindowID
        Else
            this.temp_WindowID := "rect_fakewindow ahk_exe AutoHotkey.exe"
        return this.temp_WindowID
    }

    /**
     * @function
     * @returns {Boolean}
     */
    Exists()
    {
        this.getWindowForUpdates()
        IfWinExist, % this.temp_WindowID 
            return true
        return false
    }


    /**
     * @function
     * @returns {Boolean}
     */
    Is_Focused()
    {
        this.getWindowForUpdates()
        IfWinActive, % this.temp_WindowID
            return true
        return false
    }

    Dirty := false


    /**
     * @function
     * @returns {Boolean}
     */
    isDirty()
    {
        return this.Dirty
    }


    /**
     * @description Marks WindowState as Needing to be updated
     * @function
     */
    MarkDirty()
    {
        this.Dirty := True
    }

    /**
     * @description Munarks WindowState as Needing to be updated
     * @function
     */
    UnmarkDirty()
    {
        this.Dirty := false
    }

    /**
     * @function
     * @returns {Boolean}
     */
    StateIsFocused()
    {
        return this.State.Focus
    }
    

    /**
     * updates the internal states of the Window Data
     * @function
     */
    UpdateStates()
    {
        SetBatchLines, -1
        RectangleBuilder.SnappingWindow := true
        if not this.Exists()
        {
            if not (this.State.WindowState ~= "ApplicationClosed")
            {
                this.MarkDirty()
                this.State := {  FullScreen:false
                            , BorderLess:false
                            , Maximised:false
                            , WindowState : "ApplicationClosed"
                            , Screen:{X:0,Y:0,Width:0,Height:0}
                            , Focus:false}
            }
            RectangleBuilder.SnappingWindow := false
            return
        }

        new_State := this.Get_Window_States()
        old_State := this.State

        if not IsMatch(old_State, new_State)
        {
            this.MarkDirty()
            this.State := new_State
        }
        
        RectangleBuilder.SnappingWindow := false
    }

    /**
     * @typedef {'Minimized'|'Windowed'|'Maximized'|'Fullscreen'|'Borderless'} WindowStateString
     * @property "Windowed"  Default Window state
     * @property "Maximized" Window is Maximized
     * @property "Minimized" Window is Minimized
     * @property "Fullscreen" Window is Fullscreen
     * @property "Borderless" Window is Borderless
     */

    /**
     * @memberof Window
     * @typedef ScreenState
     * @property  {Integer} TrueX
     * @property  {Integer} TrueY
     * @property  {Integer} X
     * @property  {Integer} Y
     * @property  {Integer} Width
     * @property  {Integer} Height
     */

    /**
     * @memberof Window
     * @typedef WindowState
     * @property  {Boolean} isExclusiveFullscreen
     * @property  {Boolean} isMaximised
     * @property  {WindowStateString} WindowState - possible string outcomes {@link WindowStateString|['Minimized' 'Windowed' 'Maximized' 'Fullscreen' 'Borderless']}
     * @property  {ScreenState} Screen
     * @property  {Boolean} Focus
     */
    
    /**
     * @function
     * @returns {WindowState}
     */
    Get_Window_States()
    {
        WinGet, WinState, MinMax, % "ahk_exe" . " " .  this.WindowID
        windowScreenState := "Windowed"
        switch WinState
        {
            case -1 : windowScreenState := "Minimized" 
            case  0 : windowScreenState := "Windowed" 
            case  1 : windowScreenState := "Maximized"
        }

        WinGetPos, winX, winY, winWidth, winHeight, % "ahk_exe" . " " .  this.WindowID
        
        SysGet, mon, Monitor

        monWidth := monRight - monLeft
        monHeight := monBottom - monTop
        
        isExclusiveFullscreen  := (winX = monLeft and winY = monTop and winWidth = monWidth and winHeight = monHeight)
        isBorderlessFullscreen := (Abs(winWidth - monWidth) <= 10 and Abs(winHeight - monHeight) <= 10 and winX <= 5 && winY <= 5)
        isWindowedMode         := WinState =  0
        isMaximised            := WinState =  1
        isMinimised            := WinState = -1
        isFocused              := this.Is_Focused() = 1
        offs                   := {X:winX,Y:winY,Width:winWidth,Height:winHeight}
        offs.TrueX := winX
        offs.TrueY := winY
        if not (isExclusiveFullscreen or isBorderlessFullscreen)
        {
            if not isMinimised
            {
                offs.X      := (winX + this.Offset_X_Windowed)
                offs.Y      := (winY + this.Offset_Y_Windowed)
                offs.Width  := winWidth
                if isWindowedMode
                    offs.Width  -= this.Offset_Width_Windowed
                offs.Height := (winHeight - this.Offset_Height_Windowed)
            }
            else
            {
                offs.X      := this.State.Screen.X
                offs.Y      := this.State.Screen.Y
                offs.Width  := this.State.Screen.Width
                offs.Height := this.State.Screen.Height
            }
        }

        return {  FullScreen:isExclusiveFullscreen
                , BorderLess:isBorderlessFullscreen
                , Maximised:isMaximised
                , WindowState :(isExclusiveFullscreen ? "Fullscreen" : ( isBorderlessFullscreen ? "Borderless" : windowScreenState))
                , Screen:offs
                , Focus:isFocused}
    }

    RunStartup(width := "", height := "")
    {
        ___Width  := MathStuff.NumOrDefault(width, 1920)
        ___Height := MathStuff.NumOrDefault(height, 1080)
        Anchors.Build_Default_Anchors(___Width, ___Height)
        sleep 1
        time_to_update1 := 1000 / Debugger.Internal_FPS
        SetTimer, RUN_UPDATES, %time_to_update1%
    }
}

class _RobloxWindow extends Window
{
    __New()
    {
        base.__New("RobloxPlayerBeta.exe")
    }
}


goto ROBLOX_AHK_GOTO_EOF

RUN_UPDATES:
    SetBatchLines, -1
    if RectangleBuilder.SnappingWindow
        Return
    LogUpdateChecker++
    if mod(LogUpdateChecker, Debugger.Internal_States_FTU) = 0
        RobloxWindow.UpdateStates()
    if mod(LogUpdateChecker, Debugger.Internal_Window_FTU) = 0
        RectangleBuilder.Update_Rectangle_Locations()
return

IsMatch(obj1, obj2)
{
    for key, val in obj2
        if (IsObject(val) or IsObject(obj1[key]))
            if not IsMatch(obj1[key], val)
                return false
        else if (old_State[key] != val)
            return false
    return true
}

ROBLOX_AHK_GOTO_EOF:

global RobloxWindow := new _RobloxWindow