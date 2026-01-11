/*
 * recompile.js (requires node.js) can be used to rebuild "fishSol.ahk" into a slightly faster
 * loading script by unwrapping some functions and replacing development variable names with their
 * direct variables with some exclusions ie precached images
 */
const fs = require('node:fs'), logger = console, current_directory = process.cwd();

//source data file
const fishSol_PreUpload = current_directory + "\\fishSol.ahk"
logger.log(fishSol_PreUpload)

var file_data
try { file_data = fs.readFileSync(fishSol_PreUpload, 'utf8'); } catch (err) { console.error(err); }

// extract variables
const DrawHelpDonate = /DrawHelpDonate\(((?:\-\d)|\d|)\)/g
const getCheckToggle = /( *)checkToggle\((\w+), \"(\w+)\"\)/g
const READSETTING_STRING_REGEX_ = /( *)ReadSetting\((\w+?), *("\w+?"), *("\w+?")\)/g
const READSETTING_BOOLEAN_REGEX = /( *)ReadSetting\((\w+?), *("\w+?"), *("\w+?"), *(true)\)/g
const READSETTING_NUMBER_REGEX_ = /( *)ReadSetting\((\w+?), *("\w+?"), *("\w+?"), *(\d+?), *(\d+?)\)/g
const VERSION_REGEX = /^global version := "(.+?)"/gm
const find_color = /global (\w+) +:=((?:.+?)|(?: +\"c\" +\. +))\"(0x)\" +\. +\"([0-9A-Fa-f]{6})\"/g

// find and replace original function
const READSETTING_FUNCTION_REGEX= /ReadSetting\(byref var, catagory, name, isBoolOrMin.+?max.+?\)(?:(?:.|\r\n)+?(?=\{)){2}(?:(?:.|\r\n)+?(?=\})){2}\}\r\n/gm
const CHECKTOGGLE_FUNCTION_REGEX= /\ncheckToggle\(byref toggle, byref status\)\s+\{\s+.*\s+.*\s+.*\s+.*\s+.*\s+.*\s+.*\s+.*\s+\}\s\s/g
const DrawHelpDonate_FUNCTION_REGEX= /DrawHelpDonate\(X:=0\) ;(.*\s+)+?\}/g

replace_dev_colors = []

file_data = file_data.replace(READSETTING_FUNCTION_REGEX,'')     //remove ReadSetting function
                     .replace(CHECKTOGGLE_FUNCTION_REGEX, '')    //remove checkToggle function
                     .replace(DrawHelpDonate_FUNCTION_REGEX, '') //remove DrawHelpDonate function
                     .replace(/\r/g,'')                          //remove return carriage cause it messes with stuff

lines = file_data.split(/\n/g) //split on new line

regex_list = []
first_round = []

//output version number
var VERSION = [...file_data.matchAll(VERSION_REGEX)][0][1]
//output file
const fishSol_PostUpload = current_directory + "\\fishSol_" + VERSION + ".ahk"
logger.log(fishSol_PostUpload)

for (i in lines)
{
    var line = lines[i]
    if (line.match(/global \w+ +:=/g))
    {
        if (line.match(find_color))
        {
            vars = [...line.matchAll(find_color)][0]
            final_output = getColorReplace(vars)
            logger.log("[" + i + "] GUI COLOR FOUND ADDING REGEX => " + vars[1])
        }
        else
            first_round += line + "\n"
    }
    else if(line.match(READSETTING_STRING_REGEX_))
    {
        vars = [...line.matchAll(READSETTING_STRING_REGEX_)][0]
        first_round += PushStringINI(vars[1], vars[2], vars[3], vars[4])
        logger.log("[" + i + "] STRING INI FOUND    REPLACING IT => " + vars[2])
    }
    else if(line.match(READSETTING_BOOLEAN_REGEX))
    {
        vars = [...line.matchAll(READSETTING_BOOLEAN_REGEX)][0]
        first_round += PushBooleanINI(vars[1], vars[2], vars[3], vars[4])
        logger.log("[" + i + "] BOOL INI FOUND      REPLACING IT => " + vars[2])
    }
    else if(line.match(READSETTING_NUMBER_REGEX_))
    {
        vars = [...line.matchAll(READSETTING_NUMBER_REGEX_)][0]
        first_round += PushNumberLimitINI(vars[1], vars[2], vars[3], vars[4], vars[5], vars[6])
        logger.log("[" + i + "] NUMBER INI FOUND    REPLACING IT => " + vars[2])
    }
    else if (line.match(DrawHelpDonate))
    {
        indent = [...line.matchAll(/( *)DrawHelpDonate/g)][0][1]
        X = [...line.matchAll(DrawHelpDonate)][0][1]
        first_round += pushDrawHelpDonate(X,indent)
        logger.log("[" + i + "] DrawHelpDonate(...) REPLACING IT => " + (X ? X : "~0"))
    }
    else if (line.match(getCheckToggle))
    {
        vars = [...line.matchAll(getCheckToggle)][0]
        first_round += pushCheckToggle(vars)
        logger.log("[" + i + "] getCheckToggle(...) REPLACING IT => " + vars[2])
    }
    else
        first_round += line + "\n"
}

second_round = first_round.split(/\n/g)

final_output = ""

for (i in second_round)
{
    var line = second_round[i]
    if (line.match(" *[Gg]ui"))
        for(index in regex_list)
            if(line.match(regex_list[index].regex))
                line = line.replace(regex_list[index].regex, regex_list[index].replacement)
    final_output += line + "\n"
}

final_output = final_output.replace(/(?<!:)\/\//g,'/') //KEEP AT ALL COST, FIXES DOUBLE SLASHES FROM DIVIDES
//everything else below is optional
// final_output = final_output.replace(/(\n){2,}/g, '\n')    //compact new lines
final_output = final_output.replace(/(\n){3,}/g, '\n\n')  //remove excessive new lines
// final_output = final_output.replace(/\&\&/g,'and')        //replace "&&" with "and" for readability
// final_output = final_output.replace(/\|\|/g,'or')         //replace "||" with "or"  for readability
final_output = final_output.replace(/ and /g,' && ')        //replace "and" with "&&" for readability
final_output = final_output.replace(/ or /g,' || ')         //replace "or" with "||"  for readability
// final_output = final_output.replace(/^ *;.*$\n/gm,'')     //removes all single line comment
// final_output = final_output.replace(/ *;.*$/gm,'')        //removes comments after a line of text
try { data = fs.writeFileSync(fishSol_PostUpload, final_output); } catch (err) { console.error(err); }

function getColorReplace(vars)
{
    regex = new RegExp("%" + vars[1] + "%", "g")
    replacement = ""
    if (vars[2].match(/\"c\"/g))
        replacement += "c"
    replacement += vars[3] + vars[4]
    regex_obj = new Object()
    regex_obj.regex = regex
    regex_obj.replacement = replacement
    regex_list.push(regex_obj)
    return regex
}

function PushStringINI(space, var_name, catagory, name)
{
    var temp_var = "temp_" + var_name
    replace_dev_colors.push(temp_var)
    return space + "IniRead, " + temp_var + ", %iniFilePath%, " + catagory + ", " + name + "\n"
         + space + "if (temp_var != \"ERROR\")\n"
         + space + "    " + var_name + " := " + temp_var + "\n"
}

function PushBooleanINI(space, var_name, catagory, name)
{
    var temp_var = "temp_" + var_name
    replace_dev_colors.push(temp_var)
    
    return space + "IniRead, " + temp_var + ", %iniFilePath%, " + catagory + ", " + name + "\n"
         + space + "if (" + temp_var + " != \"ERROR\")\n"
         + space + "    " + var_name + " := (" + temp_var + " = \"true\" or " + temp_var + " = \"1\")\n"
}

function PushNumberLimitINI(space, var_name, catagory, name, min, max)
{
    var temp_var = "temp_" + var_name
    replace_dev_colors.push(temp_var)
    
    return space + "IniRead, " + temp_var + ", %iniFilePath%, " + catagory + ", " + name + "\n"
         + space + "if (" + temp_var + " != \"ERROR\")\n"
        //  + space + "{\n"
        //  + space + "    " + temp_var + " += 0\n" //might not be needed
        //  + space + space + "if " + temp_var + " is Number\n"
         + space + space/* + space */+ var_name + " := max(min(" + temp_var + ", " + max + "), " + min + ") \n"
        //  + space + "}\n"
}

function pushDrawHelpDonate(X, space)
{
    xOFF1 = 445 + Number(X)
    xOFF2 = 538 + Number(X)
    xOFF3 = 430 + Number(X)
    xOFF4 = 330 + Number(X)
    
    return space + "Gui, Font, s10 %GuiColorText% Normal Bold\n"
         + space + "Gui, Color, %GuiDefaultColor%\n"
         + space + "Gui, Add, Picture, x" + xOFF1 + " y600 w27 h19, %PNG_DISCORD_%\n"
         + space + "Gui, Add, Picture, x" + xOFF2 + " y601 w18 h19, %PNG_ROBLOX__%\n"
         + space + "Gui, Font, s11 %GuiColorText% Bold Underline, Segoe UI\n"
         + space + "Gui, Add, Text, x" + xOFF3 + " y600 w150 h38 Center BackgroundTrans %GuiColorGreen% gDonateClick, Donate!\n"
         + space + "Gui, Add, Text, x" + xOFF4 + " y600 w138 h38 Center BackgroundTrans %GuiColorLBlue% gNeedHelpClick, Need Help?\n"
         + space + "Gui, Font, s10 %GuiColorText% Bold, Segoe UI\n"
}

function pushCheckToggle(vars)
{
    spacer = vars[1]
    toggle = vars[2]
    status = vars[3]
    return spacer + "if (" + toggle + ") {\n"
         + spacer + "    GuiControl,, " + status + ", ON\n"
         + spacer + "    GuiControl, +%GuiColorLGreen%, " + status + "\n"
         + spacer + "} else {\n"
         + spacer + "    GuiControl,, " + status + ", OFF\n"
         + spacer + "    GuiControl, +%GuiColorRed%, " + status + "\n"
         + spacer + "}\n"
    // return spacer + "GuiControl,, " + status + ", % (" + toggle + " ? \"ON\" : \"OFF\" )\n"
    //      + spacer + "GuiControl, % (" + toggle + " ? \"+%GuiColorLGreen%\" : \"+%GuiColorRed%\" ), " + status + "\n"
}


/*
;unrolled dev gui, no difference on load times
Gui, Add, Picture, x50 y260 w50 h50, %dev3_img%
Gui, Add, Picture, x50 y195 w50 h50, %dev2_img%
Gui, Add, Picture, x50 y130 w50 h50, %dev1_img%

Gui, Font, s11 c0xFFFFFF Normal Bold
Gui, Add, Text, x110 y265 w200 h20 BackgroundTrans c0x0088FF gDev3NameClick, %dev3_name%
Gui, Add, Text, x110 y200 w200 h20 BackgroundTrans c0x0088FF gDev2NameClick, %dev2_name%
Gui, Add, Text, x110 y135 w200 h20 BackgroundTrans c0x0088FF gDev1NameClick, %dev1_name%

Gui, Font, s9 c0xCCCCCC Normal
Gui, Add, Text, x110 y285 w300 h15 BackgroundTrans, %dev3_role%
Gui, Add, Text, x110 y220 w300 h15 BackgroundTrans, %dev2_role%
Gui, Add, Text, x110 y155 w300 h15 BackgroundTrans, %dev1_role%

Gui, Font, s9 c0xCCCCCC Normal Underline
Gui, Add, Text, x110 y300 w300 h15 BackgroundTrans c0x0088FF gDev3LinkClick, %dev3_discord%
Gui, Add, Text, x110 y235 w300 h15 BackgroundTrans c0x0088FF gDev2LinkClick, %dev2_discord%
Gui, Add, Text, x110 y170 w300 h15 BackgroundTrans c0x0088FF gDev1LinkClick, %dev1_discord%
*/
