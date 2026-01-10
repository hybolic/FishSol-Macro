#Requires AutoHotkey v1.1
#NoEnv
#SingleInstance, Force
#Persistent

global fishSolVersion := ""

global MAX_SPEED := -1 ;max speed
global STANDARD_SPEED := A_BatchLines ;store default speed
SetBatchLines, %MAX_SPEED% ;run as fast as possible during setup

SetWorkingDir %A_ScriptDir%

prevBiome := "None"
prevState := "None"
iniFilePath := A_ScriptDir "\..\settings.ini"
biomeColors := { "NORMAL":16777215, "SAND STORM":16040572, "HELL":6033945, "STARFALL":6784224, "CORRUPTION":9454335, "NULL":0, "GLITCHED":6684517, "WINDY":9566207, "SNOWY":12908022, "RAINY":4425215, "DREAMSPACE":16743935, "PUMPKIN MOON":13983497, "GRAVEYARD":16777215, "BLOOD RAIN":16711680, "CYBERSPACE":2904999, "AURORA":10040319 }
EnvGet, LocalAppData, LOCALAPPDATA

if (FileExist(iniFilePath)) {
    IniRead, tempVersion, %iniFilePath%, "Macro", "LastVersion"                            ;if set and valid use it
    fishSolVersion := ((tempVersion != "Error" and tempVersion ~= "1\.[2356789]\.\d)") ? tempVersion : "1.9.4")
    ;                                   ^check if set              ^regex known versions from github    ^ last known version
    IniRead, tempWebhook, %iniFilePath%, "Macro", "webhookURL"
    IniRead, tempPSLink, %iniFilePath%, "Biomes", "privateServerLink"
    if (tempWebhook != "ERROR" && tempPSLink != "ERROR")
    {
        webhookURL := tempWebhook
        privateServerLink := tempPSLink
    } else {
        ExitApp
    }
}

if (!InStr(webhookURL, "discord")) {
    ExitApp
}

       ; ~10 KB (adjust if needed)
global maxReadBytes := 1024*10
       ;  256 B (adjust if needed)
global maxReadBytes := 256

lastFileSize := 0

SetBatchLines, %STANDARD_SPEED% ;set speed back to normal shouldn't be needed
SetTimer, CheckBiome, 1000      ;as ahk resets line speed for each thread start
return                          

ProcessExist(Name) {
    if WinExist("ahk_exe" . Name)
        return true ; quick check before slow check
    for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
        if (process.Name = Name)
            return true
    return false
}

CheckBiome:
    SetBatchLines, %MAX_SPEED% ;this will reset once thread ends
    if (!ProcessExist("RobloxPlayerBeta.exe")) {
        return
    }
    logDir := LocalAppData "\Roblox\logs"
    newestTime := 0
    newestFile := ""

    ; Find latest log file
    Loop, Files, %logDir%\*.log, F
    {
        if (A_LoopFileTimeModified > newestTime) {
            newestTime := A_LoopFileTimeModified
            newestFile := A_LoopFileFullPath
        }
    }

    if !newestFile
        return

    file := FileOpen(newestFile, "r")
    if !IsObject(file)
        return 

    ; Read only the last ~10 KB (adjust if needed)
    size := file.Length
    chunkSize := max(min(size - lastFileSize, minReadBytes), maxReadBytes) ; calculate byte offset from lastFileSize and file.length, keeping it between a min and max value.
    lastFileSize = size ; push new size to lastFileSize variable  ; if we never go below 256B or above 10KB (adjust if needed)
    if (size > chunkSize)
        file.Seek(-chunkSize, 2) ; 2 = from end of file
    content := file.Read()
    file.Close()
    
    lines := StrSplit(content, "`n")
    regexLine := """state"":""((?:\\.|[^""])*)"".*?""largeImage"":\{""hoverText"":""((?:\\.|[^""])*)"""
    ; Read upward for the last BloxstrapRPC
    Loop % lines.MaxIndex()
    {
        line := lines[lines.MaxIndex() - A_Index + 1]
        if InStr(line, "[BloxstrapRPC]")
        {
            if RegExMatch(line, regexLine, m) {
                state := m1
                biome := m2
                break
            }

        }
    }

    if (biome && biome != "" && biome != prevBiome)
    {
        biomeKey := "Biome" StrReplace(biome, " ", "")
        IniRead, isBiomeEnabled, %iniFilePath%, "Biomes", %biomeKey%, 1
        isBiomeBypass := false
        if (biome = "GLITCHED" || biome = "DREAMSPACE" || biome = "CYBERSPACE")
            isBiomeBypass := true  ; check once so it doesn't need to rechecked

        if (isBiomeEnabled = 1 || isBiomeBypass) {
            prevBiome := biome
            biome_url := StrReplace(biome, " ", "_")
            thumbnail_url := "https://maxstellar.github.io/biome_thumb/" biome_url ".png"

            color := biomeColors.HasKey(biome) ? biomeColors[biome] : 16777215

            time := A_NowUTC
            timestamp := SubStr(time,1,4) "-" SubStr(time,5,2) "-" SubStr(time,7,2) "T" SubStr(time,9,2) ":" SubStr(time,11,2) ":" SubStr(time,13,2) ".000Z"

            if (isBiomeBypass) {
                content := "@everyone"
            } else {
                content := ""
            }

            json := "{"
            . """embeds"": ["
            . "  {"
            . "    ""description"": ""> ### Biome Started - " biome "\n> ### [Join Server](" privateServerLink ")"","
            . "    ""color"": " color ","
            . "    ""thumbnail"": {""url"": """ thumbnail_url """},"
            . "    ""footer"": {""text"": ""fishSol v" . fishSolVersion . """, ""icon_url"": ""https://maxstellar.github.io/fishSol%20icon.png""},"
            . "    ""timestamp"": """ timestamp """"    ; ^ using new fishsols version found in ini file else it will default to 1.9.4
            . "  }"
            . "],"
            . """content"": """ content """"
            . "}"

            http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            http.Open("POST", webhookURL, false)
            http.SetRequestHeader("Content-Type", "application/json")
            http.Send(json)
        }
    }
    if (state && state != "In Main Menu" && state != "Equipped _None_" && state != "" && state != prevState)
    {
        if (prevState != "None") {
            needle := Chr(92) Chr(34), pos1 := InStr(state, needle), auraName := (pos1 ? (pos2 := InStr(state, needle, false, pos1 + StrLen(needle))) && pos2>pos1 ? SubStr(state, pos1 + StrLen(needle), pos2 - (pos1 + StrLen(needle))) : state : state)

            time := A_NowUTC
            timestamp := SubStr(time,1,4) "-" SubStr(time,5,2) "-" SubStr(time,7,2) "T" SubStr(time,9,2) ":" SubStr(time,11,2) ":" SubStr(time,13,2) ".000Z"

            json := "{"
            . """embeds"": ["
            . "  {"
            . "    ""description"": ""> ### Aura Equipped - " auraName ""","
            . "    ""footer"": {""text"": ""fishSol v" . fishSolVersion . """, ""icon_url"": ""https://maxstellar.github.io/fishSol%20icon.png""},"
            . "    ""timestamp"": """ timestamp """"    ; ^ using new fishsols version found in ini file else it will default to 1.9.4
            . "  }"
            . "],"
            . """content"": """""
            . "}"


            http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            http.Open("POST", webhookURL, false)
            http.SetRequestHeader("Content-Type", "application/json")
            http.Send(json)
        }
        prevState := state
    }
return