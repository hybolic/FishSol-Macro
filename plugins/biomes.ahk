/*
 *
 * // {ClassName: BiomesPlugin,
 * // Width: 2560,
 * // Height: 1440
 * // }
 */
class BiomesPlugin extends Plugin
{
    ;[DEV COMMENT] the above metadata isn't really needed for the plugin but is requried to have it even be
    ;               added to the list when the loader is called
    PluginRun(byref restartPathing)
    {
        global
        Return true
        ;[DEV COMMENT] re-enable the timer if already disabled and <webhookURL> is true - Nadir
        if (not BiomesPlugin_can_run and InStr(webhookURL, "discord")) 
        {
            BiomesPlugin_can_run := true
            SetTimer, CheckBiome, 1000
        }
        ;[DEV COMMENT] disable it if enabled and <webhookURL> is false - Nadir
        else if (BiomesPlugin_can_run and not InStr(webhookURL, "discord"))
        {
            BiomesPlugin_can_run := false
        }
        Return true
    }

    PluginSetup()
    {
        global
        ;[DEV COMMENT] disable the timer if webhook is unavaible  - Nadir
        if (not InStr(webhookURL, "discord"))
        {
            BiomesPlugin_can_run := false
        }
        ;SetTimer, CheckBiome, 1000
    }

    SetupTabList()
    {
        return "|Biomes"
    }

    SetupGui()
    {
        global
        Gui, Tab, Biomes

        Gui, Add, Picture, x14 y80 w574 h590, %Gui_Biomes_Png%

        Gui, Font, s9 cWhite Normal, Segoe UI
        Gui, Add, Text, x50 y299 w500 h20 BackgroundTrans c0xCCCCCC, Choose which biomes are sent to Discord:

        Gui, Font, s11 cWhite Bold, Segoe UI
        Gui, Add, CheckBox, x50 y320 w140 h25 vBiomeWindy gSaveBiomeToggles Checked1 cWhite, Windy
        Gui, Add, CheckBox, x50 y350 w140 h25 vBiomeSnowy gSaveBiomeToggles Checked1 cWhite, Snowy
        Gui, Add, CheckBox, x50 y380 w140 h25 vBiomeRainy gSaveBiomeToggles Checked1 cWhite, Rainy
        Gui, Add, CheckBox, x50 y410 w140 h25 vBiomeHeaven gSaveBiomeToggles Checked1 cWhite, Heaven

        Gui, Add, CheckBox, x250 y320 w140 h25 vBiomeHell gSaveBiomeToggles Checked1 cWhite, Hell
        Gui, Add, CheckBox, x250 y350 w140 h25 vBiomeStarfall gSaveBiomeToggles Checked1 cWhite, Starfall
        Gui, Add, CheckBox, x250 y380 w140 h25 vBiomeCorruption gSaveBiomeToggles Checked1 cWhite, Corruption
        Gui, Add, CheckBox, x250 y410 w140 h25 vBiomeAurora gSaveBiomeToggles Checked1 cWhite, Aurora

        Gui, Add, CheckBox, x420 y380 w140 h25 vBiomeNormal gSaveBiomeToggles Checked1 cWhite, Normal
        Gui, Add, CheckBox, x420 y320 w140 h25 vBiomeSandStorm gSaveBiomeToggles Checked1 cWhite, Sand Storm
        Gui, Add, CheckBox, x420 y350 w140 h25 vBiomeNull gSaveBiomeToggles Checked1 cWhite, Null

        Gui, Font, s14 cWhite Bold
        Gui, Add, Text, x45 y445 c0x65FF65, Glitched
        Gui, Add, Text, x+2 y445, ,
        Gui, Add, Text, x+8 y445 c0xFF7DFF, Dreamspace
        Gui, Add, Text, x+8 y445, and
        Gui, Add, Text, x+8 y445 c0x00ddff, Cyberspace
        Gui, Add, Text, x+8 y445, are always on.

        Gui, Font, s10 cWhite Bold
        Gui, Add, Text, x50 y155 w200 h25 BackgroundTrans, Private Server Link:
        Gui, Add, Edit, x50 y185 w500 h25 vBiomesPrivateServerInput gUpdateBiomesPrivateServer Background0xD3D3D3 cBlack, %biomesPrivateServerLink%
        Gui, Font, s8 c0xCCCCCC Normal
        Gui, Add, Text, x50 y215 w500 h15 BackgroundTrans, Paste your Roblox private server link here for biome notifications.

        Gui, Font, s10 cWhite Bold
        Gui, Add, Button, x425 y490 w115 h40 gOpenPluginsFolder, Open Plugins Folder

        Gui, Color, 0x1E1E1E
        Gui, Add, Picture, x445 y600 w27 h19, %DiscordPNG%
        Gui, Add, Picture, x538 y601 w18 h19, %RobloxPNG%

        Gui, Font, s11 cWhite Bold Underline, Segoe UI
        Gui, Add, Text, x430 y600 w150 h38 Center BackgroundTrans c0x00FF00 gDonateClick, Donate!
        Gui, Add, Text, x330 y600 w138 h38 Center BackgroundTrans c0x00D4FF gNeedHelpClick, Need Help?
        
    }
    
    IniRead() 
    {
 ;
        global 
        local tempPSLink
        LoadBiomeToggles()
        IniRead, tempPSLink, %iniFilePath%, "Biomes", "privateServerLink"
 ;
        if (webhookURL != "ERROR" and tempPSLink != "ERROR")
        {
            ;[DEV COMMENT] I'm keeping this in but its declared twice? should this be a seperate variable or just removed entirely? - Nadir
            ;[DEV COMMENT] Nvm i found the correct variable and fixed the statement <privateServerLink> => <biomesPrivateServerLink>  - Nadir
            biomesPrivateServerLink := tempPSLink
        }
        Else
            IniWrite, % "", %iniFilePath%, "Biomes", "privateServerLink"
 ;
    }
    
    
    GuiControlChecks()
    {
        
    }
    
}


global biomesPrivateServerLink := ""

global biomeDetectionRunning := false
global hasBiomesPlugin := true
global prevBiome := "None"
global prevState := "None"



global biomeColors := { "NORMAL":16777215, "SAND STORM":16040572, "HELL":6033945, "STARFALL":6784224, "CORRUPTION":9454335, "NULL":0, "GLITCHED":6684517, "WINDY":9566207, "SNOWY":12908022, "RAINY":4425215, "DREAMSPACE":16743935, "PUMPKIN MOON":13983497, "GRAVEYARD":16777215, "BLOOD RAIN":16711680, "CYBERSPACE":2904999 }

global BiomesPlugin_read_log_regex := """state"":""((?:\\.|[^""])*)"".*?""largeImage"":\{""hoverText"":""((?:\\.|[^""])*)"""

global BiomesPlugin_can_run := true

;internal and external resource locations
 global maxstellar_biome_thumbnail := "https://maxstellar.github.io/biome_thumb/"
 global Gui_Biomes_Png   := A_ScriptDir . "\gui\Biomes.png"
 EnvGet, LocalAppData, LOCALAPPDATA
 global logDir := LocalAppData "\Roblox\logs"
;


goto Biome_EOF

;[DEV COMMENT] alot of this is untouched but just moved here
UpdateBiomesPrivateServer:
    Gui, Submit, nohide
    biomesPrivateServerLink := BiomesPrivateServerInput
    IniWrite, %biomesPrivateServerLink%, %iniFilePath%, "Biomes", "privateServerLink"
return

CheckBiome:
    if BiomesPlugin_can_run
    {
        ;[DEV COMMENT] made so garbage collection is done after each call ie, less of a memory leak - Nadir
        CheckBiomeFunction()       
    }else ;[DEV COMMENT] quickly recall the label to disable the timer essentially killing it with <-1> - Nadir
        SetTimer, CheckBiome, -1
return

;[DEV COMMENT] unchanged for now
SaveBiomeToggles:
    Gui, Submit, NoHide
    IniWrite, %BiomeNormal%, %iniFilePath%, "Biomes", BiomeNormal
    IniWrite, %BiomeSandStorm%, %iniFilePath%, "Biomes", BiomeSandStorm
    IniWrite, %BiomeHell%, %iniFilePath%, "Biomes", BiomeHell
    IniWrite, %BiomeStarfall%, %iniFilePath%, "Biomes", BiomeStarfall
    IniWrite, %BiomeCorruption%, %iniFilePath%, "Biomes", BiomeCorruption
    IniWrite, %BiomeWindy%, %iniFilePath%, "Biomes", BiomeWindy
    IniWrite, %BiomeSnowy%, %iniFilePath%, "Biomes", BiomeSnowy
    IniWrite, %BiomeRainy%, %iniFilePath%, "Biomes", BiomeRainy
    IniWrite, %BiomeHeaven%, %iniFilePath%, "Biomes", BiomeHeaven
    IniWrite, %BiomeAurora%, %iniFilePath%, "Biomes", BiomeAurora
    IniWrite, %BiomePumpkinMoon%, %iniFilePath%, "Biomes", BiomePumpkinMoon
    IniWrite, %BiomeGraveyard%, %iniFilePath%, "Biomes", BiomeGraveyard
    IniWrite, %BiomeBloodRain%, %iniFilePath%, "Biomes", BiomeBloodRain
    IniWrite, %BiomeNull%, %iniFilePath%, "Biomes", BiomeNull
return


;[DEV COMMENT] check below comment
ProcessExist(Name)
{
    ;[DEV COMMENT] would <if WinExist("ahk_exe " . Name)> be faster? - Nadir
    for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
        if (process.Name = Name)
            return true
    return false
}

CheckBiomeFunction()
{
    SetBatchLines, %MAX_SPEED%
    if (!ProcessExist("RobloxPlayerBeta.exe"))
    {
        return
    }
    newestTime := 0
    newestFile := ""

    ; Find latest log file
    Loop, Files, %logDir%\*.log, F
    {
        if (A_LoopFileTimeModified > newestTime)
        {
            newestTime := A_LoopFileTimeModified
            newestFile := A_LoopFileFullPath
        }
    }

    if !newestFile
        return

    file := FileOpen(newestFile, "r")
    if !IsObject(file)
        return
    ;                                     [DEV COMMENT] i do have an alternative version of this part that only
    ;                                                     reads what has changed and within a limit of 10kb
    ; Read only the last ~10 KB (adjust if needed)          ;    to reduce the amount of read calls
    size := file.Length ;<----------------------------------;
    chunkSize := 10240                                      ;
    if (size > chunkSize)                                   ;
        file.Seek(-chunkSize, 2) ; 2 = from end of file     ;
    content := file.Read()                                  ;
    file.Close()                                            ;
    ;^------------------------------------------------------;
    lines_array := StrSplit(content, "`n")

    ; Read upward for the last BloxstrapRPC
    Loop % lines_array.MaxIndex()
    {
        line := lines_array[lines_array.MaxIndex() - A_Index + 1]
        if InStr(line, "[BloxstrapRPC]")
        {        ;[DEV COMMENT] Moved to global so it doesn't need to be reassigned every call
            if RegExMatch(line, BiomesPlugin_read_log_regex, m)
            {
                state := m1
                biome := m2
                break
            }

        }
    }

    if (biome && biome != "" and biome != prevBiome)
    {
        biomeKey := "Biome" StrReplace(biome, " ", "")
        IniRead, isBiomeEnabled, %iniFilePath%, "Biomes", %biomeKey%, 1

        ;[DEV COMMENT] one off isSpecial check instead of recalling the same thing multiple times
        if  (biome = "GLITCHED" or biome = "DREAMSPACE" or biome = "CYBERSPACE")
            isSpecial := true
        else
            isSpecial := false

        if (isBiomeEnabled = 1 or isSpecial)
        {
            prevBiome := biome
            ; biome_url := StrReplace(biome, " ", "_")
            thumbnail_url := maxstellar_biome_thumbnail . StrReplace(biome, " ", "_") ".png"

            color := biomeColors.HasKey(biome) ? biomeColors[biome] : 16777215

            time := A_NowUTC
            timestamp := SubStr(time,1,4) "-" SubStr(time,5,2) "-" SubStr(time,7,2) "T" SubStr(time,9,2) ":" SubStr(time,11,2) ":" SubStr(time,13,2) ".000Z"

            if (isSpecial)
            {
                content := "@everyone"
            } else {
                content := ""
            }

            json := "{"
            . """embeds"": ["
            . "  {"
            . "    ""description"": ""> ### Biome Started - " biome "\n> ### [Join Server](" privateServerLink ")"","
            . "    ""color"": " color ","
            .           ;[DEV COMMENT] updated this to be more easily updated from the up top - Nadir
            . "    ""thumbnail"": {""url"": """ thumbnail_url """}," ;[DEV COMMENT]  and these two here can be done from the main script - Nadir
            . "    ""footer"": {""text"": """ . version . """, ""icon_url"": """ . icon_url . """},"
            . "    ""timestamp"": """ timestamp """"
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
        if (prevState != "None")
        {
            needle := Chr(92) Chr(34), pos1 := InStr(state, needle), auraName := (pos1 ? (pos2 := InStr(state, needle, false, pos1 + StrLen(needle))) && pos2>pos1 ? SubStr(state, pos1 + StrLen(needle), pos2 - (pos1 + StrLen(needle))) : state : state)

            time := A_NowUTC
            timestamp := SubStr(time,1,4) "-" SubStr(time,5,2) "-" SubStr(time,7,2) "T" SubStr(time,9,2) ":" SubStr(time,11,2) ":" SubStr(time,13,2) ".000Z"

            json := "{"
            . """embeds"": ["
            . "  {"
            . "    ""description"": ""> ### Aura Equipped - " auraName ""","
            .               ;[DEV COMMENT] updated these to be more easily updated from the main script - Nadir
            . "    ""footer"": {""text"": """ . version . """, ""icon_url"": """ . icon_url . """},"
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
        ;[DEV COMMENT] if you have the name of the aura why not use it to un-equip it during the un-equip phase? - Nadir
        prevState := state
    }
    SetBatchLines, %STANDARD_SPEED%
}
;[DEV COMMENT]  unchanged
LoadBiomeToggles()
{
    global
    IniRead, BiomeNormal, %iniFilePath%, "Biomes", BiomeNormal, 1
    IniRead, BiomeSandStorm, %iniFilePath%, "Biomes", BiomeSandStorm, 1
    IniRead, BiomeHell, %iniFilePath%, "Biomes", BiomeHell, 1
    IniRead, BiomeStarfall, %iniFilePath%, "Biomes", BiomeStarfall, 1
    IniRead, BiomeCorruption, %iniFilePath%, "Biomes", BiomeCorruption, 1
    IniRead, BiomeWindy, %iniFilePath%, "Biomes", BiomeWindy, 1
    IniRead, BiomeSnowy, %iniFilePath%, "Biomes", BiomeSnowy, 1
    IniRead, BiomeRainy, %iniFilePath%, "Biomes", BiomeRainy, 1
    IniRead, BiomeHeaven, %iniFilePath%, "Biomes", BiomeHeaven, 1
    IniRead, BiomeAurora, %iniFilePath%, "Biomes", BiomeAurora, 1
    IniRead, BiomePumpkinMoon, %iniFilePath%, "Biomes", BiomePumpkinMoon, 1
    IniRead, BiomeGraveyard, %iniFilePath%, "Biomes", BiomeGraveyard, 1
    IniRead, BiomeBloodRain, %iniFilePath%, "Biomes", BiomeBloodRain, 1
    IniRead, BiomeNull, %iniFilePath%, "Biomes", BiomeNull, 1

    GuiControl,, BiomeNormal, %BiomeNormal%
    GuiControl,, BiomeSandStorm, %BiomeSandStorm%
    GuiControl,, BiomeHell, %BiomeHell%
    GuiControl,, BiomeStarfall, %BiomeStarfall%
    GuiControl,, BiomeCorruption, %BiomeCorruption%
    GuiControl,, BiomeWindy, %BiomeWindy%
    GuiControl,, BiomeSnowy, %BiomeSnowy%
    GuiControl,, BiomeRainy, %BiomeRainy%
    GuiControl,, BiomeHeaven, %BiomeHeaven%
    GuiControl,, BiomeAurora, %BiomeAurora%
    GuiControl,, BiomePumpkinMoon, %BiomePumpkinMoon%
    GuiControl,, BiomeGraveyard, %BiomeGraveyard%
    GuiControl,, BiomeBloodRain, %BiomeBloodRain%
    GuiControl,, BiomeNull, %BiomeNull%
}


Biome_EOF:
Log.Info("[PLUGIN=>""biomes.ahk""]" . " Finished Loading!")
/**
* @ignore
*/