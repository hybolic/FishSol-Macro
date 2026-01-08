;[DEV COMMENT] will eventually contain settings
class Debugger
{
    static PerformanceTest      := true
    static LogToFile            := true
    static Log_More_Info        := true
    static Log_Basic_Info       := true
    static DoMouseClick         := false
    static DoMouseMove          := false
    static DoSendKeystrokes     := false
    static DoSleep              := false

    static ForceHideLabels      := false
    static Visual_ShowObjectKey := false
    static ForceHideViews       := false
    static Internal_FPS         := 10
    static Internal_States_FTU  := 1
    static Internal_Window_FTU  := 1
    static _Internal_Logs_FTU   := Debugger.Internal_FPS * 5
    Internal_Logs_FTU(val:=-1)
    {
        if val = -1
            return Debugger._Internal_Logs_FTU
        else
            return Debugger._Internal_Logs_FTU := min(max(value, Debugger.Internal_FPS * 1), Debugger.Internal_FPS * 30)
    } 


}
;[DEV COMMENT] the log class
/**
 * @class Log
 * @hideconstructor
 */
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
    /**
     * @decription Temporarily disabled to prevent zip file compression spam
     * @static
     */
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
    /**
     * @description sends Error to log
     * @static
     * @param {String} message
     * @param {Boolean} [startNewLine=true]
     */
    Error(message, startNewLine:=true)
    {
        Log.message("ERROR", message, true, true, startNewLine)
    }

    ;[DEV COMMENT] log the current exception given
    /**
     * @description sends Exception to log
     * @static
     * @param {String} message
     * @param {Exception} exc
     * @param {Boolean} [startNewLine=true]
     */
    Exception(message, exc, startNewLine:=true)
    {
        Log.message("EXCEPTION-", message, true, true, startNewLine)
        if exc.HasKey("Line") or exc.HasKey("Message")
            Log.message("EXCEPTION+", exc.Line . ": " . exc.Message, true, true, startNewLine)
        else
            Log.message("EXCEPTION+", "no message given!", true, true, startNewLine)
    }

    ;[DEV COMMENT] log an info message
    /**
     * @description sends Info to log
     * @static
     * @param {String} message
     * @param {Boolean} [startNewLine=true]
     */
    Info(message, startNewLine:=true)
    {
        if Debugger.Log_Basic_Info
            Log.message("INFO", message, false, true, startNewLine)
    }

    ;[DEV COMMENT] log a low info message, usually these dont even get pushed to file
    /**
     * @description sends Low Priority Info to log<br/>usually something that doesnt need to be saved to file
     * @static
     * @param {String} message
     * @param {Boolean} [startNewLine=true]
     */
    Low_Info(value, startNewLine:=true)
    {
        if Debugger.Log_More_Info
            Log.message("LOWINFO", value, false, false, startNewLine)
    }

    ;[DEV COMMENT] two part messaeg first containing the info message and the second the extra details that wont get logged
    /**
     * @ignore
     */
    ExtraInfo(message, message2, startNewLine:=true)
    {
        throw Exception("WHY ARE YOU STILL USING THIS!!!")
        if Debugger.Log_Basic_Info
            Log.message("INFO", message, false, true, startNewLine)
        if Debugger.Log_More_Info
            Log.message("INFO+", message2, false, false, startNewLine)
    }

    ;[DEV COMMENT]  better version of the one above
    /**
     * @description combination of {@link Log#Info|Info()} and {@link Log#Low_Info|Low_Info()} in one call
     * <br/>similar use case as Low_Info but you optionally keep the info if push is set to true
     * @static
     * @param {String} message
     * @param {String} message2
     * @param {Boolean} [pushToFile=true]
     * @param {Boolean} [startNewLine=true]
     */
    Info_With_Extra(message, message2, pushToFile:=false, startNewLine:=true)
    {
        if Debugger.Log_Basic_Info
            Log.message("INFO", message . (Debugger.Log_More_Info ? message2 : ""), false, pushToFile, startNewLine)
    }

    ;[DEV COMMENT] worst option but here anyway
    /**
     * @ignore
     */
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
    /**
     * @description if we are logging to file we temporarily switch that off
     * @static
     */
    Temp_Disable_Log2File()
    {
        if(Debugger.LogToFile) and (not Temp_Disable_Log2File_switch)
            Temp_Disable_Log2File_switch := Debugger.LogToFile
        Debugger.LogToFile := False
        return this
    }

    ;[DEV COMMENT] brains of the Logger
    /**
     * @description brains of the Logger, logs messages to the console aswell as to file if enabled
     * @static
     * @param {String} prefix the prefix of the message ie [INFO] or [DEBUG]
     * @param {String} Message 
     * @param {Boolean} [OpenConsoleWindow:=false]
     * @param {Boolean} [PushToFile:=false]
     * @param {Boolean} [StartNewLine:=true]
     */
    message(prefix, value, openConsoleWindow:=false, pushToFile:=false, newLineStarter := true)
    {
        temp_speed := A_BatchLines
        SetBatchLines, %MAX_SPEED%
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

        SetBatchLines, %temp_speed%
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

        ;[DEV COMMENT] check the Tray icon on the bottom right, 
        ;       right click and at the top of the menu we have the console window opener
        Menu, Tray, NoStandard
        Menu, Tray, Add, % "&Open Logs", ToggleConsole
        Menu, Tray, Add, % "&Toggle Lables", HideLabels
        Menu, Tray, Add, % "&Toggle Rects", HideViews
        Menu, Tray, Add, % "&Toggle Debug", ToggleDebug
        Menu, Tray, Add, % ""
        Menu, Tray, Standard

    }
    
    static WM_SYSCOMMAND := 0x112
    static SC_CLOSE := 0xF060
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

/**
 * @description stringify an object using a crude JsonStringify {@link Global.print_loop|loop}
 * @name JSONStringify
 * @param {Object} object the object to be dumped into a string
 * @param {Character} [space_char=empty] the character used to give the json string spaces, if supplied new lines will also be added
 * @param {Boolean} [cleanup=false] cleans up the string removing anything that was used to keep the arrays in a logical order
 * @returns {String}
 * @function
 * @memberof Global
 */
JSONStringify(object, space_char:="", cleanup:=false)
{
    new_line := ""
    gap := ""
    single_gap := ""
    

    if strlen(space_char) > 0
    {
        if (space_char ~= "[^\t\r\f\v\n\s]+")
        {
            single_gap := " "
            gap .= " "
            new_line := "`n"
        }
        else
        {
            single_gap := SubStr(space_char, 1, 1)
            gap .= space_char
            new_line := "`n"
        }
    }

    __c := "{" . new_line
    __c .= print_loop(object, single_gap, gap, new_line, cleanup)
    __c .= new_line . "}"
    return __c
}

/**
 * loop "function" of {@link Global.JSONStringify|Json} Stringify
 * @name print_loop
 * @param {Object} item
 * @param {Character} single_gap
 * @param {String} gap
 * @param {Character} new_line
 * @param {Boolean} [cleanup=false] cleans up the string removing anything that was used to keep the arrays in a logical order
 * @returns {String}
 * @function
 * @memberof Global
 */
print_loop(item, single_gap, gap, new_line, cleanup:=false)
{
    curstr := ""
 
    ______temp_index := 0 
    if IsObject(item)
        for key, _value in item
        {
            ______temp_index++

            if IsArray(_value)
            {
                curstr .= gap . """" . key . """" . single_gap . ":" . single_gap . "[" . new_line

                print_UnIndexed_Array_index := 0
                Loop % _value.Count()
                {
                    print_UnIndexed_Array_index++
                    if IsArray(_value[print_UnIndexed_Array_index])
                    {
                        curstr .= gap . single_gap . single_gap . "{" . new_line
                        curstr .= print_loop(_value[print_UnIndexed_Array_index], single_gap, (single_gap . single_gap . single_gap . gap), new_line) . new_line
                        curstr .= gap . single_gap . single_gap . "}"
                    }
                    else
                    {
                        curstr .= gap . single_gap . """" . _value[print_UnIndexed_Array_index] . """"
                    }

                    if print_UnIndexed_Array_index < % (_value.Count())
                        curstr .= ","

                    curstr .= new_line
                }
                curstr .= gap . "]"
                if A_Index < (item.Count())
                    curstr .= ","
                curstr .= new_line
            }
            else if IsObject(_value) and _value.Count() > 0
            {
                curstr .= gap .  """" . key . """" . single_gap . ":" . new_line
                curstr .= gap . single_gap . "{" . new_line
                curstr .= print_loop(_value, single_gap, (single_gap . single_gap . gap), new_line)
                curstr .= gap . single_gap .  "}"
                if ______temp_index < (item.Count())
                    curstr .= "," . new_line
                curstr .= new_line
            }
            else
            {
                if isNumber(_value) and (not key ~= "(?i)(color)") ; check if it is a hex number some other way
                    curstr .= gap . """" . key . """" . single_gap . ":" . single_gap . _value
                else
                    curstr .= gap . """" . key . """" . single_gap . ":" . single_gap . """" . _value . """"
                if ______temp_index <(item.Count())
                    curstr .= "," . new_line
            }
        }
    
    if cleanup
        return sanitize_string(curstr)
    else
        return curstr
}

/**
 * @description sanatizes the string of strings and returns a clean string<pre>
 * <b>(?i)(sorted_)[\d]{4}_</b>        // Remove "Sorted_####_" from the string
 * <b>(?i)(""FALSE"")</b>   ==>  <b>false</b> // makes false lowercase
 * <b>(?i)(""TRUE"")</b>    ==>  <b>true</b>  // makes true lowercase
 * <b>(?i)(CLASSTYPE)</b>   ==>  <b>class</b> // replaces "CLASSTYPE" with "class"
 * <b>(?:\.\d*?[1-9])\K0+</b>          // removes trailing zeros of float</pre>
 * @name sanitize_string
 * @param {String} string byref
 * @returns {String}
 * @function
 * @memberof Global
 */
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


/**
 * @class SortedArray_Func
 * @classdesc Global Sorted Array Functions
 * @hideconstructor
 */


/**
 * @class Global
 * @classdesc Global Functions
 * @hideconstructor
 */

/**
 * @typedef  SortedArray
 * @memberof SortedArray_Func
 * @name SortedArray
 * @description an array of string keys and value objects, yes this is a keypair list, but if definied as such is not entirely true
 * @property {String} Key    name of the object
 * @property {Object} Value
 */

/**
 * looks for and removes item from sorted array
 * @name SortedArrayRemove
 * @param {SortedArray} array
 * @param {String} item_name
 * @returns {Boolean}
 * @function
 * @memberof SortedArray_Func
 */
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

/**
 * looks for and removes item from sorted array<br/>pairs of key value in long aaa list give to be turned into an array <b>SortedArrayMake(key, value, key2, value2)</b>
 * @name SortedArrayMake
 * @param {...Object} array pairs of String and Objects
 * @returns {SortedArray} Sorted Array
 * @function
 * @memberof SortedArray_Func
 */
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

/**
 * pushes a new item to the sorted array!<br/>it does cause it to become messy but its here just in case its needed
 * @name Push
 * @param {SortedArray} array byref Sorted Array
 * @param {String} key
 * @param {Object} value
 * @returns {SortedArray}
 * @function
 * @memberof SortedArray_Func
 */
Push(byref array, key, value)
{
    highest := -1
    used_numbers := []
    for key, _ in array
    {
        the_index := SubStr(key, 7, 4) + 0
        if (the_index) > %highest%
            highest := (the_index + 1)
        used_numbers.Push(the_index)
    }
    i := 1
    loop
        i++
    until  not the_index[highest+i]

    new_key_name := "Sorted_" Format("{:04}", highest + i) "_" key
    array[new_key_name] := value
    return array
}


/**
 * remove element from array using its known sorted index
 * <br/> returning the removed object
 * @name RemoveAt
 * @param {SortedArray} array byref Sorted Array
 * @param {Integer} index
 * @returns {Object} the removed object
 * @function
 * @memberof SortedArray_Func
 */
RemoveAt(byref array, index)
{
    
    for key, value in array
    {
        the_index := SubStr(key, 7, 4) + 0
        if the_index = %index%
        {
            saved_value := value
            array.Delete(key)
            return saved_value
        }
    }
    return ""
}

/**
 * @global 
 */
;simple math lerp function
lerp(A,B,T)
{
    return A + ((B - A) * T)
}

/**
 * @name isString
 * @param {Object} object
 * @returns {Boolean}
 * @function
 * @memberof Global
 */
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

/**
 * @name isNumber
 * @param {Object} object
 * @returns {Boolean}
 * @function
 * @memberof Global
 */
isNumber(object)
{
    if object is Number
        return True
    return false
}

/**
 * @name IsArray
 * @param {Object} object
 * @returns {Boolean}
 * @function
 * @memberof Global
 */
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

/**
 * @name IsObjectFixed
 * @description stops the whole IsObject() "function" from making the variable an object after checking if it is one
 * @param {Object} object
 * @returns {Boolean}
 * @function
 * @memberof Global
 */
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