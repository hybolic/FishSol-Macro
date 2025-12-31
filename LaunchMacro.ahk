; Preloader for Plugins

global _PluginFolder_     := A_ScriptDir "\plugins"
PluginLoader.LoadPlugins()
ExitApp
class PluginLoader
{
    ; Not a replacement for simple human safety but will work for now
    static PluginRegex          := "(?i)^(?:(?:\s*[\w _]+ +:= +new +)|(?:.*new +))(?=\C+?\nclass +([\w_]*) +extends +plugin\s+{[\w\W]*})\g1\(\d+,\d+\)"
    static MetaDataRegex        := "(?i)(?:\/\*\C*?(?P<Json>{\C*?(?=\C*?\s*?ClassName *?: *((?P<Plugin>\w+)(?=,))(?=\C+?class\s+?\g2 *))(?=\C*?\s*Width *?: *(?P<Width>\d{3,4}))(?=\C*?\s*?Height *?: * (?P<Height>\d{3,4}))\C*?})\C*?\*\/)(?=\C*?\nclass +(?(?=\g{2}[ ])(?:\g{2})|(?!)) +extends +plugin\s+{[\w\W]*})"
    static AhkExtractIncludes   := "(?<=#include)\s*plugins\\(?P<PLUGIN>(.*)\.ahk)"

    static CurrentPluggins      := Object()
    LoadPlugins()
    {
        if not FileExist(_PluginFolder_ . "\PluginManager.ahk")
        {
            out := FileOpen(_PluginFolder_ . "\PluginManager.ahk", "w")
            out.Close()
        }

        PluginLoader.CurrentPluggins := Object()
        fix_file := ""
        Loop, Read, %_PluginFolder_%\PluginManager.ahk
        {
            out := PluginLoader.getRegexObject(A_LoopReadLine, PluginLoader.AhkExtractIncludes)
            file_name := out.Matches[1].Group.PLUGIN.Value 
            
            PluginLoader.CurrentPluggins[file_name]              := Object()
            if FileExist(_PluginFolder_ . "\" . file_name)
            {
                fix_file .= A_LoopReadLine . "`n"
            }
            Else
            {
                PluginLoader.NeedsReload := true
                PluginLoader.FixFile     := true
            }
            PluginLoader.CurrentPluggins[file_name].path         := _PluginFolder_ . "\" . file_name
            PluginLoader.CurrentPluggins[file_name].plugin_class := Object()
        }
        out := FileOpen(_PluginFolder_ . "\PluginManager.ahk", "rw")
        if PluginLoader.FixFile
        {
            out.Position := 0
            out.write(RTrim(fix_file, "`n"))
            out.Position := 0
        }
        full_doc := out.read()
        Loop, Files, %_PluginFolder_%\*.ahk, F
        {
            if A_LoopFileName ~= "PluginManager.ahk"
                Continue

            temp_file_read := FileOpen(A_LoopFileFullPath, "r")
            contents := temp_file_read.Read()
            temp_file_read.Close()
            if RegExMatch(contents, PluginLoader.MetaDataRegex)
            {
                meta_data  := PluginLoader.getRegexObject(contents, PluginLoader.MetaDataRegex)
                for index, key in meta_data.Matches
                {
                    Groups      := key.Group
                    ClassName   := Groups.Plugin.value
                    Width       := Groups.Width.value+0
                    Height      := Groups.Height.value+0
                    
                    plugin_data := { PluginClass : ClassName, Height : Groups.Height.value+0, Width : Groups.Width.value+0, ExtraJson : RegexReplace(Groups.Json.Value,"\b[a-zA-Z_]+","""$0""") }
                    
                    if not PluginLoader.CurrentPluggins[A_LoopFileName]
                    {
                        out.WriteLine("#include plugins\" . A_LoopFileName)
                        PluginLoader.CurrentPluggins[A_LoopFileName]              := Object()
                        PluginLoader.CurrentPluggins[A_LoopFileName].path         := _PluginFolder_ . "\" . A_LoopFileName
                        PluginLoader.CurrentPluggins[A_LoopFileName].plugin_class := Object()
                        PluginLoader.NeedsReload := true
                    }
                    regexed_new_class_line := "new " . ClassName . "\(" . Width . "," . Height . "\)"
                    if not full_doc ~= regexed_new_class_line
                    {
                        new_class_line := "PLUGIN_" . ClassName . " := " . "new " . ClassName . "(" . Width . "," . Height . ")"
                        out.WriteLine(new_class_line)
                    }
                    ;make new instance of the plugin class
                    PluginLoader.CurrentPluggins[A_LoopFileName].plugin_class.Push(plugin_data)
                }
            }
        }
        out.Close()
        msgbox % "DONE!"
        the_script := A_ScriptDir . "\fishSol.ahk"
        Run %the_script%, %A_ScriptDir%
    }
    
    getRegexObject(haystack, needle, Study := false)
    {
        VarOutValue := Object()
        VarOutValue.Matches := Object()
        
        
        if needle ~= "(?i)"
            REGEX .= "i"

        if not (needle ~= "$|^")
            REGEX .= "m"
        
        if Study
            REGEX .= "S"

        REGEX .= "O)" needle
        


        Match := 1
        lastPos := 1
        if not RegExMatch(haystack, REGEX, VarOut)
            return
        
        loop
        {
            curPos := RegExMatch(haystack, REGEX, VarOut, lastPos)
            if (curPos = 0)
                break

            VarOutValue.Matches[Match] := Object()
            if VarOut.Pos  [0] > 0
                VarOutValue.Matches[Match].Position := VarOut.Pos  [0]
            if VarOut.Len  [0] > 0
                VarOutValue.Matches[Match].Length   := VarOut.Len  [0]
            if VarOut.Value[0] != ""
                VarOutValue.Matches[Match].Value    := VarOut.Value[0]
            if VarOut.Name [0] != ""
                VarOutValue.Matches[Match].Name     := VarOut.Name [0]
            if VarOut.Mark() != ""
                VarOutValue.Matches[Match].Mark     := VarOut.Mark()

            if ((VarOut.Count()) > 1)
            {
                VarOutValue.Matches[Match].Count    := VarOut.Count()
                VarOutValue.Matches[Match].Group := Object()
                loop % VarOut.Count() 
                {
                    index := A_Index
                    if(VarOut.Name [A_Index])
                        index := VarOut.Name [A_Index]
                    VarOutValue.Matches[Match].Group[index] := Object()
                    VarOutValue.Matches[Match].Group[index].Position := VarOut.Pos  [A_Index]
                    VarOutValue.Matches[Match].Group[index].Length   := VarOut.Len  [A_Index]
                    VarOutValue.Matches[Match].Group[index].Value    := VarOut.Value[A_Index]
                    if VarOut.Name [A_Index] != ""
                        VarOutValue.Matches[Match].Group[index].Name     := VarOut.Name [A_Index]
                    VarOutValue.Matches[Match].Group[index].Index    := A_Index
                    if (VarOutValue.Matches[Match].Group[index].Length = 0) and (VarOutValue.Matches[Match].Group[index].Position = 0) and (VarOutValue.Matches[Match].Group[index].Value = "")
                        something := VarOutValue.Matches[Match].Group.Delete(index)
                }
            }
            
            lastPos := (VarOut.Pos[0] + 1)
            Match++
        }
        VarOutValue.Count := Match - 1
        VaribleOut := VarOutValue
        return VarOutValue
    }
}