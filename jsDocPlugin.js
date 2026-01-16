//jsdoc .\ -c jsdoc.json --verbose --debug > jsdoc_Output.log
const logger = require('jsdoc/util/logger');
logger.info("Nadir's jsDocPlugin is running!!");
const commentPattern = /\/\*\*[\s\S]+?\*\//g
const extname = require('path').extname
const extension = '.ahk'
		

const class_regex    = /^((?![\w\;\/\\\"\%]) )*class.*/g
const variable_regex = /^[^\/\\\*\;\%\(\)]*(\w+ )*\w+ +:*= /g
const function_regex = /^[^\/\\\*\;\:\=\%]*((?![,=:*&"])\w)+\([\w,=:*&"\s]*\)(?!.*[^\s{])/g
const brackets_char  = /\{|\}/g
const quoted_brackets= /\".*?(?:\{|\}).*?\"/g
const has_open       = /^ *\{/g
const has_closed     = /^ *\}/g //unsused but here for reference
const comment        = /^ *((\/\*)|(\/\*\*)|\*|(\*\/)|\;)/g
const newLineRegex   = /\r|\n/g
const newLine        = "\r\n"
const isIf           = / *if +/g
const emptyArray     = /[\w\[\]\"\(\)](?= *$)/g
const byref          = /\bbyref\b/g
const isglobal       = /\bglobal\b +/g
const isStatic       = /\bstatic\b +/g
const isAHK_SETTER   = /\:\=/gm
const doubleBracket  = /\{\}\r\n( +(\{\}))/g
const replaceMistakenVariableFunctionWithNewWord     = /(?<![\@\"])\bfunction\b(?!.*\()/g
const fixThatMistake = "the_function"

const AHK__NewInClass= /(^ *class +(?:\w+)[\w\W]+?)__New(\(.*\))/gm
const AHK__NewInClass_REPLACE = "$1constructor$2"

const AHK_AttemptToRemoveInvalidThingsFromBraces     = /(?<! *((\/\*\*)|\*|(\*\/)|\;).*)(?<=.*\w\(.*?)[^\w\"\ \=\,\|\-\+\n](?=.*?\))/g

const CleanupWord  = "cleanup"
const CleanupRegex    = new RegExp("(@" + CleanupWord + "(?:(?:regex)|(?:end)|(?:nuke)))", "g")
const cl_regex        = new RegExp("@" + CleanupWord + "regex", "g")
const cl_end          = new RegExp("@" + CleanupWord + "end", "g")
const cl_nuke         = new RegExp("@" + CleanupWord + "nuke", "g")

const extractRegexFromFirstQuotes   = /\"(?:\/)*(.+?)(?:\/)(\w+)*(?:\")/g
const extractStringFromSecondQuotes = /(?<=\" \").*?(?=\")/g

const fs = require("fs");

const reset = "\x1b[0m"; const bright = "\x1b[1m"; const dim = "\x1b[2m"; const underscore = "\x1b[4m"; 
const blink = "\x1b[5m"; const reverse = "\x1b[7m"; const hidden = "\x1b[8m"; 

const black = "\x1b[30m"; const red = "\x1b[31m"; const green = "\x1b[32m"; const yellow = "\x1b[33m";
const blue = "\x1b[34m"; const magenta = "\x1b[35m"; const cyan = "\x1b[36m"; const white = "\x1b[37m";

const BGblack = "\x1b[40m"; const BGred = "\x1b[41m"; const BGgreen = "\x1b[42m"; const BGyellow = "\x1b[43m";
const BGblue = "\x1b[44m"; const BGmagenta = "\x1b[45m"; const BGcyan = "\x1b[46m"; const BGwhite = "\x1b[47m";

var stored_variable = new Object();

exports.handlers = {
	beforeParse(e) {
		if (extension === extname(e.filename)) {
			var temp = e.source.replace(AHK__NewInClass, AHK__NewInClass_REPLACE)
								.replace(AHK_AttemptToRemoveInvalidThingsFromBraces,'')
							    .replace(replaceMistakenVariableFunctionWithNewWord, fixThatMistake) //catchall fix incase someone like me is dumb enough to name a variable or function "function"
								.replace(/(?<=(?::=|=).+) \. /g, " + ") //replace string appened with add sign
								.replace(/\w+\s+(?::=|=)\s+new\s+\w+(?!.*\()/g, "$&()")
								.replace(/(?<!(?:\*|\/).*) not /g, " ! ")
								.replace(/(?<="+.*)""(?!\s)/g,"\\\"")
			var el = temp.split(CleanupRegex);
			var cleanup_list = []
			var cleaned = ""
			var last = 0
			for (i = 0; i < el.length; i++)
			{
				if (typeof el[i] != "undefined")
				{
					if(el[i].match(cl_regex))
					{
						last++
						var cleanup_regex = ""
						var cleanup_object = new Object()
						cleaning_up = true;
						cleanup_regex = el[i+1].matchAll(extractRegexFromFirstQuotes)
						if (cleanup_regex == null)
						{
							cleanup_regex = new RegExp(/(?!)/) //basically just force quite the regex whilst still being a valid regex
							cleanup_replace = ""
						}
						else
						{
							var obj = new Array
							for (const match of cleanup_regex) { obj = match; break; }
							cleanup_regex = new RegExp("" + obj[1], "" + obj[2])
							
							var cleanup_replace = ""
							cleanup_replace = (el[i+1].match(extractStringFromSecondQuotes))
							if (cleanup_replace == null)
								cleanup_replace = ""
							else
								cleanup_replace = cleanup_replace[0]
						}

						cleanup_object.regex   = cleanup_regex
						cleanup_object.replace = cleanup_replace
						cleanup_list[last] = cleanup_object
						logger.warn(red + "REGEX ADDED!" + reset)
					}
					else if(el[i].match(cl_nuke))
					{	//the nuclear option
						cleanup_regex = ""
						cleanup_replace = ""

						var cleanup_object = new Object()
						cleanup_object.regex   = new RegExp(".*", "g")
						cleanup_object.replace = ""

						cleanup_list[last] = cleanup_object
						logger.warn(red + "NUKE  ADDED!" + reset)
					}
					else if(el[i].match(cl_end) && last >= 0)
					{
						var temp = last
						logger.warn(red + "REGEX REMOVED! " + yellow +  last + magenta + " " + cleanup_list[last].regex + reset)
						cleanup_list.splice(last,1)
						last--
					}
					else if (last > 0)
					{
						for(i2 = 0; i2 < last; i2++)
						{
							var reg = cleanup_list[last-i2]
							if (el[i].match(reg.regex))
								el[i] = el[i].replace(reg.regex, reg.replace)
						}
					}
					cleaned += el[i]
				}
			}
			for(i = 0; i <= last; i++)
			{
				cleanup_list.splice(i,1)
			}

			last = 0
			var brackets = 0
			var in_function = false
			var text = cleaned.replace(/;(.*)/g, "//$1").replaceAll('\r','').split('\n')
			var last_function_brackets = -1
			var class_brackets = new Array()
			var new_text = ""
			var is_var = false
			var last_switch = false
			var in_count = 0
			var out_count = 0
			for(var line_number = 0; line_number < text.length; line_number++)
			{
				is_var = false
				current_line = text[line_number].replace(newLineRegex,' ')
				if (typeof current_line == "undefined")
					continue
				//check if line is comment
				if (current_line.match(comment))
				{
					new_text += current_line + newLine
					continue
				}else
				{
				//temporarily remove quoted brackets to chec for real ones
				if (current_line.replace(quoted_brackets,'').match(brackets_char) && (in_function || class_brackets.length > 0))
				{
					in_count  = (current_line.match('{') || []).length
					out_count = (current_line.match('}') || []).length
					// brackets += in_count - out_count
					if (last_switch)
					{
						last_switch = false
						new_text += current_line + newLine
						is_var = true
					}
					
					if (in_count > 0)
					{
logger.debug("IN:           index: " + (brackets) + ":" + (line_number+1))
					}
					else if (out_count > 0)
					{
logger.debug("OUT:          index: " + (brackets) + ":" + (line_number+1))
					}

					brackets += in_count - out_count

					if ((class_brackets.length > 0) && class_brackets[class_brackets.length - 1] == brackets)
					{
logger.debug("leaving class:    index: " + brackets + ":" + (line_number+1))
						is_var = true
						last_switch = true
						class_brackets.splice(class_brackets.length - 1,1)
						new_text += current_line + "  //C-" + line_number + ":" + brackets + newLine 
						continue
					}
					else if (in_function && last_function_brackets == brackets)
					{
logger.debug("leaving function: index: " + brackets + ":" + (line_number+1))
						new_text += current_line + "  //F-" + line_number + ":" + brackets + newLine 
						is_var = true
						in_function = false
						continue
					}
// 					else
// 					{
// // 						new_text += newLine
// // logger.debug("no line:          index: " + (brackets) + ":" + (line_number+1))
// // 						brackets += in_count - out_count
// // 						continue
// 					}
				}

				//check if class
				if(!is_var)
					if (current_line.match(class_regex))
					{
logger.debug("in class:         index: " + ((brackets == 0 ? brackets+1 : brackets)) + ":" + (line_number+1))
						is_var = true
						new_text += current_line + "  //C+" + line_number + ":" + brackets + newLine 
						last_switch = true
						class_brackets.push(brackets)
						continue
					}
				// check if function
				if(!is_var)
					if (current_line.match(function_regex) && current_line.match(isIf) == null && !in_function)
					{
						var second_line = false
						if(typeof text[line_number+1] != "undefined")
						{
							if(text[line_number+1].match(has_open))
								second_line = true
						}
						if (current_line.match(has_open) || second_line)
						{
logger.debug("in function:      index: " + brackets + ":" + (line_number+1))
							last_switch = true
							is_var = true
							in_function = true
							last_function_brackets = brackets
							new_text += current_line.replace(byref,'') + "  //F+" + line_number + ":" + brackets + newLine 
							continue
						}
					}
				
				//check if variable
				if(!is_var)
				if (current_line.match(variable_regex) && !in_function && brackets <= class_brackets.length)
				{
logger.debug("in  var:         index: " + ((brackets == 0 ? brackets+1 : brackets)) + ":" + (line_number+1))
					is_var = true
					var outline = current_line.replace(emptyArray, "$&;")
					if (class_brackets.length == 0)
						outline = outline.replace(isglobal, 'var ').replace(isStatic, 'var ')
					else
						outline = outline.replace(isglobal, '').replace(isStatic, '')
					new_text += outline + "  //V~" + line_number + ":" + brackets + newLine 
					continue
				}

				if(!is_var)
					new_text += ""  + newLine
				}
			}

			cleanup_list = new Array
			var t = new_text.replace(isAHK_SETTER,"=").replace(doubleBracket, "$2")
			// logger.debug(t)
			e.source = t//"/**\n * @namespace {Object} " + e.filename.replace(/[\W\w]*fishsols refactor/g, "").replace(/\\[\W]+/g,".").replace(/\.ahk/g,"") + "\n*/" + t; 
			
			logger.debug(e.source)
			
			var txtFile = require('path').dirname(e.filename).replace(/(.)fishsols refactor(.*)/g, "$1fishsols refactor$1js$2$1") + e.filename.replace(/^.*\\/g,'') + ".js";
			
			// logger.warn(txtFile)

			fs.writeFile(txtFile, e.source, function (err) {
				if (err) {
					return console.error(err);
				}
			});
		}
	}
};

exports.defineTags = function(dictionary) {
		dictionary.defineTag('fixed', {
				canHaveType: true,
				onTagged: function(doclet, tag) {
                        var force_val_str, force_val, val, str
						if (!doclet.routeparams) {
							doclet.routeparams = [];
						}
						 //kill the function if node isn't real >:3c
						if (typeof doclet.meta.code.node == "undefined") {
							return
                        }
						else if (typeof doclet.type == "undefined") {
						 //doclet.type doesn't exist? we cool! lets make it ourselves!
							doclet.type = new Object()
							doclet.type.names = new Array()
						}
						else if (typeof doclet.type.names == "undefined") {
						 //doclet.type was never assigned too? oh nyo!!
							doclet.type.names = new Array()
						}
						doclet.kind	= 'constant'
						doclet.scope = 'static'

						 //awesome we have a type so we assign it!
                         force_val = false
						if (tag.value.type.names.length > 0)
						{
							if (!doclet.type.names.includes(tag.value.type.names[0]))
								doclet.type.names = doclet.type.names.concat(tag.value.type.names)
						}
						else
						{
						 //figure it out ourselves
							//panic in regex
							str = doclet.meta.code.node.value.raw
							if (str.match(/\d*?\.*\d*/g))//Number
							{
								if(!doclet.type.names.includes('Number'))
									doclet.type.names.push('Number')
							}
							if (str.match(/\0\x[0-9a-fA-F]*/g)) //Hex
							{
								if(!doclet.type.names.includes('Hexadecimal'))
									doclet.type.names.push('Hexadecimal')
							}
							else if (str.match(/[\"\'].*?[\"\']/g)) //String
							{
								if(!doclet.type.names.includes('String'))
									doclet.type.names.push('String')
							}
						}
                        if (typeof doclet.meta.code.node.value.raw == "undefined")
                        {
                            force_val = true
                            val = buildFromNode(doclet.meta.code.node.value)
                            force_val_str = val[0]
                            
                            if (val[1] && !doclet.type.names.includes("Hexadecimal") && !doclet.type.names.includes("Number") && !doclet.type.names.includes("Binary") && !doclet.type.names.includes("Flag"))
                                doclet.type.names.push("Hexadecimal")
                        }
                        else
                            force_val_str = doclet.meta.code.node.value.raw
                        
                        if (doclet.type.names.includes("Hexadecimal"))
                            doclet.defaultvalue = "0x" + Number(force_val_str).toString(16)
                        else if (doclet.type.names.includes("Flag") || doclet.type.names.includes("Binary"))
                            doclet.defaultvalue = "0b" + (("0000000000000000"+(Number(force_val_str) >>> 0).toString(2)).slice(-16));
                        else
                            doclet.defaultvalue = force_val_str

                        if (typeof stored_variable[doclet.meta.code.node.parent.parent.id.name] == "undefined")
                            stored_variable[doclet.meta.code.node.parent.parent.id.name] = new Array
                        if (typeof stored_variable[doclet.meta.code.node.parent.parent.id.name][doclet.meta.code.name] == "undefined")
                            stored_variable[doclet.meta.code.node.parent.parent.id.name][doclet.meta.code.name] = new Array
                        stored_variable[doclet.meta.code.node.parent.parent.id.name][doclet.meta.code.name].push(doclet.defaultvalue, (force_val ? force_val_str : doclet.meta.code.node.value.value))
						
                        logger.debug(doclet.meta.code.name + " = " + doclet.defaultvalue)
				}
		});
		dictionary.defineTag('isflag', {
				onTagged: function(doclet, tag) {
						if (!doclet.routeparams) { doclet.routeparams = []; }
                        if (typeof doclet.defaultvalue == "undefined") return;
						if (typeof doclet.type == "undefined") { doclet.type = new Object(); doclet.type.names = new Array() }
						doclet.kind	= 'constant'
						doclet.scope = 'static'
                        doclet.type.names = ["Flag","Binary"]; 
                        doclet.defaultvalue = "0b" + (("0000000000000000"+(doclet.defaultvalue >>> 0).toString(2)).slice(-16));
				}
		});
};
function buildFromNode(node)
{
	var vas = buildFromNodes(node)
    return vas
}

function buildFromNodes(node)
{
	var new_node = node
    var left, right, temp, class_object, variable;
    var IS_HEX = false;
    
    switch (node.left.type) {
        case "Literal" : {
			left = node.left.value;
			if (node.left.raw.includes("0x")) IS_HEX = true;
			// logger.debug("LTl " + left);
			break;
		}
        case "MemberExpression": {
			class_object = node.left.object.name;
			variable = node.left.property.name;
			left = stored_variable[class_object][variable][1];
			// logger.debug("MEl " + class_object + "." + variable + "=" + left);
			break;
		}
        default : {
			temp = buildFromNodes(node.left);
			left = temp[0];
			IS_HEX = temp[1];
			// logger.debug("RWl " + left);
			break;
		}
    }
    
    switch (node.right.type) {
		case "Literal" : {
			right = node.right.value;
			if (node.right.raw.includes("0x")) if (!IS_HEX) IS_HEX = temp[1];
			// logger.debug("LTr " + right);
			break;
		}
        case "MemberExpression": { 
			class_object = node.right.object.name;
			variable = node.right.property.name;
			right = stored_variable[class_object][variable][1];
			// logger.debug("MEr "  + class_object + "." + variable + "=" +  right);
			break;
		}
        default : {
			temp = buildFromNodes(node.right);
			right = temp[0];
			if (!IS_HEX) IS_HEX = temp[1];
			// logger.debug("RWr " + right);
			break;
		}
    }

    switch (node.operator)
    {
        case "<<": logger.debug((left + " " + node.operator + " " + right + " = ") + (left  <<   right)); break;
        case ">>": logger.debug((left + " " + node.operator + " " + right + " = ") + (left  >>>  right)); break;
        case  "&": logger.debug((left + " " + node.operator + " " + right + " = ") + (left  &    right)); break;
        case  "|": logger.debug((left + " " + node.operator + " " + right + " = ") + (left  |    right)); break;
        case  "+": logger.debug((left + " " + node.operator + " " + right + " = ") + (left  +    right)); break;
        case  "-": logger.debug((left + " " + node.operator + " " + right + " = ") + (left  -    right)); break;
        case  "/": logger.debug((left + " " + node.operator + " " + right + " = ") + (left  /    right)); break;
        case  "*": logger.debug((left + " " + node.operator + " " + right + " = ") + (left  *    right)); break;
    }

    switch (node.operator)
    {
        case "<<": return [left <<  right, IS_HEX]
        case ">>": return [left >>> right, IS_HEX]
        case  "&": return [left &   right, IS_HEX]
        case  "|": return [left |   right, IS_HEX]
        case  "+": return [left +   right, IS_HEX]
        case  "-": return [left -   right, IS_HEX]
        case  "/": return [left /   right, IS_HEX]
        case  "*": return [left *   right, IS_HEX]
        default  : return -1
    }
}