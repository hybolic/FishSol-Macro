;[DEV COMMENT] will eventually contain settings
class Debugger
{
    static PerformanceTest      := true
    static LogToFile            := true
    static Log_More_Info        := true
    static Log_Basic_Info       := true
    static DoMouseClick         := true
    static DoMouseMove          := true
    static DoSendKeystrokes     := true

    static ForceHideLabels      := true
    static ForceHideViews       := true
    static Internal_FPS         := 60
    static Internal_States_FTU  := 1
    static Internal_Window_FTU  := 1
    static _Internal_Logs_FTU   := Debugger.Internal_FPS * 5
    Internal_Logs_FTU    {
        get {
            return _Internal_Logs_FTU
        } set {
            return _Internal_Logs_FTU := min(max(value, Debugger.Internal_FPS * 1), Debugger.Internal_FPS * 30)
        } }


}
;[DEV COMMENT] the log class
class Log
{
    
    static Log_Directory := "\logs"
    static Log_File := ""
    static __TB_MAX  := 50
    static ShowConsoleWindow := false
    static StoredConsoleLog := ""

    static ConsoleLogHandle := ""
    static ConsoleGuiHandle := ""
    static ConsoleOpenLogDirButton := ""
    ;[DEV COMMENT] disabled for now
    CleanUpLogs()
    {
        ; CLEANUP DISABLED DUE TO FILE LOGGING BEING DISABLED ON UPLOAD
        ; Log.message("LOGS", "Check if Excess Logs need to be Archived and Removed", false, true, false)

        ; Max_Logs_Left := 5

        ; UnIndexed_Array := []
        ; Max_Files_In_Zip := 15
        ; logDir := Log.getCurrentLogDirectory()
        ; Time_Indexed_Array := {}
        ; offset := 0
        ; Log.message("", ".", false, true, false)

        ; Loop, Files, %logDir%\*.log, F
        ; {
        ;     log_file_time := A_LoopFileTimeCreated + offset
        ;     log_file_path := A_LoopFileFullPath
        ;     loop
        ;     {
        ;         offset++
        ;         new_offset := offset + log_file_time
        ;     }
        ;     Until ((Time_Indexed_Array[new_offset]) != 0)
        ;     Time_Indexed_Array[(log_file_time+offset)] := log_file_path
            
        ; }
        ; Log.message("", ".", false, true, false)
        
        ; if Time_Indexed_Array.Count() < Max_Logs_Left
        ; {
        ;     Log.message(, " Log Count low, cleanup not needed! :D", false, true, true)
        ;     return
        ; }

        ; Current_Zip_Counter := 0

        ; Loop, Files, %logDir%\*.zip, F
        ; {
        ;     temp_Current_Zip_Counter := RegExReplace(A_LoopFileName, "[^\d]+")
        ;     if (temp_Current_Zip_Counter > Current_Zip_Counter)
        ;         Current_Zip_Counter := temp_Current_Zip_Counter
        ; }
        ; Log.message("", ".", false, true, false)

        ; for k, v in Time_Indexed_Array
        ;     UnIndexed_Array.Push(v)
        
        ; Log.message("", ".", false, true, false)

        ; Files_To_Remove := UnIndexed_Array.Count() - Max_Logs_Left
        ; if (UnIndexed_Array.Count() > Files_To_Remove)
        ; {
        ;     Log.message("", " Found!", false, true, true)
        ;     Zip_Group_Index:= 0
        ;     Zip_Group := []
        ;     Large_Groups := Object()
            
        ;     loop % Files_To_Remove / Max_Files_In_Zip
        ;     {
        ;         Zip_Group_Index++
        ;         Zip_Group := []
        ;         loop %Max_Files_In_Zip%
        ;         {
        ;             Array_Indexed := % (((Zip_Group_Index - 1) * Max_Files_In_Zip) + (A_Index))
        ;             Zip_Group.push(UnIndexed_Array[Array_Indexed])
        ;         }
        ;         Large_Groups.push(Zip_Group)
        ;     }
        ;     for k, File_Group in Large_Groups
        ;     {
        ;         Current_Zip_Counter++
        ;         Zip_File_Path := logDir . "\CompressedLogs_" . Current_Zip_Counter . ".zip"
        ;         Files := File_Group
        ;         Log.Info_With_Extra("Compressing old logs to CompressedLogs_" . Current_Zip_Counter . ".zip!", "[" . Zip_File_Path . "]", true, true)
        ;         if !FileExist(Zip_File_Path) {
        ;             File := FileOpen(Zip_File_Path, "w")
        ;             File.WriteInt(0x06054B50)
        ;             File.Length := 22
        ;             File.Close()
        ;         }

        ;         Folder := ComObjCreate("Shell.Application").NameSpace(Zip_File_Path)
        ;         count  := Folder.Items.Count
                
        ;         for index, file in Files {
        ;             Folder.CopyHere(file)
        ;             while Folder.Items.Count < count + index
        ;                 Sleep, 50
        ;         }
        ;         Log.Info_With_Extra(" DONE!", " With Extra Steps :D", true, true)
        ;     }
        ;     sleep 100
        ;     for k, File_Group in Large_Groups
        ;     {
        ;         for index, file in File_Group {
        ;             if FileExist(file)
        ;                 if (Temp_Dest)
        ;                     FileMove % file, % Temp_Dest, false
        ;                 else
        ;                     FileDelete, % file
        ;                 while FileExist(file)
        ;                     sleep 50
        ;         }
        ;     }
        ; }else
        ;     Log.message("", " huh? guess there was a mistake!", false, true, true)
    }

    ;[DEV COMMENT] log the current error given
    Error(message, startNewLine:=true)
    {
        Log.message("ERROR", message, true, true, startNewLine)
    }

    ;[DEV COMMENT] log the current exception given
    Exception(message, exc, startNewLine:=true)
    {
        Log.message("EXCEPTION-", message, true, true, startNewLine)
        if exc.HasKey("Line") or exc.HasKey("Message")
            Log.message("EXCEPTION+", exc.Line . ": " . exc.Message, true, true, startNewLine)
        else
            Log.message("EXCEPTION+", "no message given!", true, true, startNewLine)
    }

    ;[DEV COMMENT] log an info message
    Info(message, startNewLine:=true)
    {
        if Debugger.Log_Basic_Info
            Log.message("INFO", message, false, true, startNewLine)
    }

    ;[DEV COMMENT] log a low info message, usually these don't even get pushed to file
    Low_Info(value, startNewLine:=true)
    {
        if Debugger.Log_More_Info
            Log.message("LOWINFO", value, false, false, startNewLine)
    }
    ;[DEV COMMENT] two part messaeg first containing the info message and the second the extra details that won't get logged
    ExtraInfo(message, message2, startNewLine:=true)
    {
        throw Exception("WHY ARE YOU STILL USING THIS!!!")
        if Debugger.Log_Basic_Info
            Log.message("INFO", message, false, true, startNewLine)
        if Debugger.Log_More_Info
            Log.message("INFO+", message2, false, false, startNewLine)
    }

    ;[DEV COMMENT]  better version of the one above
    Info_With_Extra(message, message2, pushToFile:=false, startNewLine:=true)
    {
        if Debugger.Log_Basic_Info
            Log.message("INFO", message . (Debugger.Log_More_Info ? message2 : ""), false, pushToFile, startNewLine)
    }

    ;[DEV COMMENT] worst option but here anyway
    ExtraInfo2(message, message2, pushToFile:=false, startNewLine:=true)
    {
        throw Exception("WHY ARE YOU STILL USING THIS!!!")
        if Debugger.Log_Basic_Info
            Log.message("INFO", message, false, pushToFile, startNewLine)
        if Debugger.Log_More_Info
            Log.message("", message2, false, pushToFile, startNewLine)
    }
    
    static Temp_Disable_Log2File_switch := -1
    ;[DEV COMMENT] temporarily disables the log to file function to allow the dev to
    ;                 dump large amounts of stuff to the console but not to file
    Temp_Disable_Log2File()
    {
        if(Debugger.LogToFile) and (not Temp_Disable_Log2File_switch)
            Temp_Disable_Log2File_switch := Debugger.LogToFile
        Debugger.LogToFile := False
        return this
    }
    ;[DEV COMMENT] brains of the Logger
    message(prefix, value, openConsoleWindow:=false, pushToFile:=false, newLineStarter := true)
    {
        message_string :=  ""
        spacer := ""
        newLine := ""

        if (newLineStarter = true)
        {
            newLine .= "`r`n"
        }

        if openConsoleWindow and (Log.ConsoleLogHandle)  
        {
            Log.ShowConsoleWindow:= true
            Gui, GuiConsoleWindow:Show, NoActivate
        }

        if (strlen(prefix) > 0)
        {
            message_string .= Log.getTimeDate() . " " . "[" . prefix . "]"
            spacer .= " "
        }

        message_string .= spacer . (IsObject(value) ? print_loop(value,false,"","",true) : value)
        
        Log.StoredConsoleLog .= message_string . newLine

        StoredLogLength := StrLen(RegExReplace(Log.StoredConsoleLog, "[^\n]*"))
        MaxSizeOfStoredLog := min(StoredLogLength, Log.__TB_MAX - 1)
        if (StoredLogLength > MaxSizeOfStoredLog)
            Log.StoredConsoleLog := RegExReplace(Log.StoredConsoleLog, ".+?[\n\r]{1,2}",r,o, StoredLogLength - MaxSizeOfStoredLog)
        
        if (Log.ConsoleLogHandle)
        {
            ConsoleLogHandle := Log.ConsoleLogHandle
            GuiControl, GuiConsoleWindow:, %ConsoleLogHandle%, % Log.StoredConsoleLog
        }

;[DEV COMMENT] File Logging REMOVED FOR NOW to reduce spam in files
;        if (Debugger.LogToFile or pushToFile)
;            FileAppend, % (FileExist(Log.getCurrentLog()) ? newLine : "") . message_string, % Log.getCurrentLog()

        if (Temp_Disable_Log2File_switch != -1)
        {
            Debugger.LogToFile := Temp_Disable_Log2File_switch
            Temp_Disable_Log2File_switch := -1
        }
    }
    
    ;[DEV COMMENT] gets current directory for the log files to go into
    getCurrentLogDirectory()
    {
        if not (FileExist(A_ScriptDir . Log.Log_Directory) ~= "D")
        {
            FileCreateDir, % A_ScriptDir . Log.Log_Directory
            Log.Low_Info("[LOG?] No Logs Directory Making one! => " . A_ScriptDir . Log.Log_Directory)
        }
        return A_ScriptDir . Log.Log_Directory
    }
    
    ;[DEV COMMENT] gets the current log file name with directory
    getCurrentLog()
    {
        if (not (Log.Log_File)) or StrLen(Log.Log_File) = 0
            Log.Log_File := Log.getCurrentLogDirectory() . "\" . Log.getTimeDate("dd-MM-yyyy-HHmm") . ".log"
        return Log.Log_File
    }
    
    ;[DEV COMMENT] quick time date function
    getTimeDate(time_date_style:="dd/MM/yy HH:mm:ss", prefix:="",postfix:="")
    {
        FormatTime, __TimeDate,, %time_date_style%
        __TimeDate := prefix . __TimeDate  . prefix
        return __TimeDate
    }

    ;[DEV COMMENT] formally <dumpRectToConsole()> now <dumpObjectToConsole>
    ;                does as it says, just straight dumps the contents of the object to
    ;                   the logger
    dumpObjectToConsole(object, spacer:="", cleanup:=false, pushtofile:=false)
    {
        Log.message("DUMP",JSONStringify(object, spacer, cleanup), true, pushtofile, true)
    }

    ;[DEV COMMENT] forcefully show the debug console
    ShowConsole()
    {
        Log.ShowConsoleWindow := true
        Gui, GuiConsoleWindow:Show
    }

    ;[DEV COMMENT] makes the console, should only need to be called once
    MakeConsole()
    {
        global
        Log.message("LOGS", "Making Log Console Window", false, true, false)
        ;Set Debugger to true while starting up and use settings to turn it back off later
        Debugger.LogToFile        := true
        Debugger.Log_More_Info    := true
        Debugger.Log_Basic_Info   := true

        log_self_class = this
        

        Gui, GuiConsoleWindow:New, -Resize +AlwaysOnTop -0x30000 +hwndHandelConsoleWindow
        Log.message("", ".",false,true,false)
        
        LogButton := Log.ConsoleOpenLogDirButton
        Gui, GuiConsoleWindow:Add, Button, v%LogButton% w80 +hwndOpenLogDirButton, % "Open Log Directory"
        Log.message("", ".",false,true,false)

        openLogDir  := ObjBindMethod(this, "OpenLogDir", OpenLogDirButton)
        GuiControl, GuiConsoleWindow:+g, %OpenLogDirButton%, %openLogDir%
        Log.message("", ".",false,true,false)

        __TB_MAX := Log.__TB_MAX
        
        Gui, GuiConsoleWindow:Add, Edit, w500 r%__TB_MAX% Multi -Wrap +VScroll -HScroll +hwndConsoleWindowHandle
        Log.message("", ".",false,true,false)
        
        Log.ConsoleLogHandle := ConsoleWindowHandle
        Gui, GuiConsoleWindow:Show, % "Hide Autosize x" . (450) . " y" ((1920 / 2) - 200)
        Log.message("", ".",false,true,false)
        
        if Log.ShowConsoleWindownsoleShow
            Gui, GuiConsoleWindow:Show
        Log.message("", ".",false,true,false)
        
        Log.ConsoleGuiHandle := HandelConsoleWindow
        Log.message("", ".",false,true,false)

        onClose  := ObjBindMethod(this, "GuiClose", HandelConsoleWindow)
        OnMessage(Log.WM_SYSCOMMAND, onClose)

        consoleMade := true
        Log.message("", " Done!",false,true,true)
        Log.CleanUpLogs()
    }
    
    static WM_SYSCOMMAND := 0x112, SC_CLOSE := 0xF060
    ;[DEV COMMENT] stops the gui from being deleted when closed but instead hides it
    GuiClose(gui_, wp, lp, msg, hwnd) {
        if (gui_ = hwnd && wp = Log.SC_CLOSE){
            Log.ShowConsoleWindow:= false
            Gui, GuiConsoleWindow:Hide
            return true
        }
    }

    ;[DEV COMMENT] opens the log file directory
    OpenLogDir(p*)
    {
        run, % "explorer.exe /expand, " . Log.getCurrentLogDirectory()
    }
}


JSONStringify(object, space_char:="", cleanup:=false)
{
    indent := ""
    gap := ""
    single_gap := ""
    

    if strlen(space_char) > 0
    {
        if (space_char ~= "[^\t\r\f\v\n\s]+")
        {
            single_gap := " "
            gap .= " "
            indent := "`n"
        }
        else
        {
            single_gap := SubStr(space_char, 1, 1)
            gap .= space_char
            indent := "`n"
        }
    }

    __c := "{" . indent
    __c .= print_loop(object, single_gap, gap, indent, cleanup)
    __c .= indent . "}"
    return __c
}

print_loop(item, single_gap, gap, indent, cleanup:=false)
{
    curstr := ""
 
    ______temp_index := 0 
    if IsObject(item)
        for key, _value in item
        {
            ______temp_index++

            if IsArray(_value)
            {
                curstr .= gap . """" . key . """" . single_gap . ":" . single_gap . "[" . indent

                print_UnIndexed_Array_index := 0
                Loop % _value.Count()
                {
                    print_UnIndexed_Array_index++
                    if IsArray(_value[print_UnIndexed_Array_index])
                    {
                        curstr .= gap . single_gap . single_gap . "{" . indent
                        curstr .= print_loop(_value[print_UnIndexed_Array_index], single_gap, (single_gap . single_gap . single_gap . gap), indent) . indent
                        curstr .= gap . single_gap . single_gap . "}"
                    }
                    else
                    {
                        curstr .= gap . single_gap . """" . _value[print_UnIndexed_Array_index] . """"
                    }

                    if print_UnIndexed_Array_index < % (_value.Count())
                        curstr .= ","

                    curstr .= indent
                }
                curstr .= gap . "]"
                if A_Index < (item.Count())
                    curstr .= ","
                curstr .= indent
            }
            else if IsObject(_value) and _value.Count() > 0
            {
                curstr .= gap .  """" . key . """" . single_gap . ":" . indent
                curstr .= gap . single_gap . "{" . indent
                curstr .= print_loop(_value, single_gap, (single_gap . single_gap . gap), indent)
                curstr .= gap . single_gap .  "}"
                if ______temp_index < (item.Count())
                    curstr .= "," . indent
                curstr .= indent
            }
            else
            {
                if isNumber(_value) and (not key ~= "(?i)(color)") ; check if it is a hex number some other way
                    curstr .= gap . """" . key . """" . single_gap . ":" . single_gap . _value
                else
                    curstr .= gap . """" . key . """" . single_gap . ":" . single_gap . """" . _value . """"
                if ______temp_index <(item.Count())
                    curstr .= "," . indent
            }
        }
    
    if cleanup
        return sanitize_string(curstr)
    else
        return curstr
}

sanitize_string(byref __string)
{
    repalced_string := RegExReplace(__string, "(?i)(sorted_)[\d]{4}_")
    repalced_string := RegExReplace(repalced_string, "(?i)(""FALSE"")","false")
    repalced_string := RegExReplace(repalced_string, "(?i)(""TRUE"")","true")
    repalced_string := RegExReplace(repalced_string, "(?i)(CLASSTYPE)","class")
    repalced_string := RegExReplace(repalced_string, "(?:\.\d*?[1-9])\K0+") ;TRAILING ZEROS
    __string := repalced_string
    return repalced_string
}


SortedArrayRemove(array, name)
{
    for key, _UNUSED_ in array
    {
        unsorted_name := RegExReplace(key, "Sorted_[\d]*_")
        if unsorted_name = name
        {
            array.Delete(key)
            return true
        }
    }
    return false
}

SortedArrayMake(params*)
{
    Sorted_Array := Object()
    loop % (params.Length() / 2)
    {
        index        := A_Index
        key_index    := A_Index * 2 - 1
        value_index  := A_Index * 2
        key          := params[key_index]
        value        := params[value_index]
        new_key_name := "Sorted_" Format("{:04}", index) "_" key
        Sorted_Array[new_key_name] := value
    }
    return Sorted_Array
}

;simple math lerp function
lerp(A,B,T)
{
    return A + ((B - A) * T)
}

isString(object)
{
    if object is Alpha
        return True
    if object is Alnum
        return True
    else
        if (not IsObjectFixed(object)) and RegExMatch(object, "(?:[\w\s]|[[:punct:]])+")
            return True
    return false
}

;simple is this a number check
isNumber(object)
{
    if object is Number
        return True
    return false
}

;Not the best way to detect an array but good enough
IsArray(object) {
    if not IsObjectFixed(object)
        Return false
    if (object.Count() = 0) or (object.Length() = 0)
        return false
    For k, _ in object 
    {
        If not isNumber(k) or not RegExMatch(object, "^[\d]+\.*[\d]*(?![\d])")
            return false
    }
   Return True
}

IsObjectFixed(byref object)
{
    checking := object
    if IsObject(object)
        ret_val := true
    else
        ret_val := false
    object := checking
    return object
}

goto LOG_AHK_SKIP_LABELS

ToggleConsole:
    Log.ShowConsole()
return

LOG_AHK_SKIP_LABELS:

Log.message("LogStartup", "Logging Started at " . Log.getTimeDate("HH:mm:ss"),False,True,True)

;[DEV COMMENT] MAKE THAT CONSOLE WINDOW
Log.MakeConsole()

;[DEV COMMENT] check the Tray icon on the bottom right, 
;       right click and at the top of the menu we have the console window opener
Menu, Tray, NoStandard
Menu, Tray, Add, % "&Open Logs", ToggleConsole
Menu, Tray, Add, % ""
Menu, Tray, Standard
