const { log } = require('console');

var commentPattern = /\/\*\*[\s\S]+?\*\//g,
    // find_function = /((?<=\n|^)[^*\n:=()_\w]+([\w_]+?\([^:\n]*\)).*)|(.*)/g,
    // get_things = /^ *\K(?={|}|(?:class *(?<class>.*?) *(?:extends *(?<base_class>.*?)$|$))|(?:(?<function>[\w_]+?\([^\n]*\)).*(?=\s*?(?:[^}][{])))|(?:(?<function_call>[\w_]+?\([^\n]*\)).*(?=\s*?(?![{}])))|(?:(?:(?<access>(?:static|global|local)) *|(?:))(?<var>[\w]*) *:*= *(?<value>.*)$)|(\\\*\*\s*)|(?<JSdocComment>\/\*\* *\n(?:(?: *\* *?(?!.*\*\/)).*\n)* *.*\*\/))/g
    // replace_function = 'function $2\{\}',
    // notNewLinePattern = /[^\n]/g,
    extname = require('path').extname,
    extension = '.ahk',
    // type_name_class = /(.+?)(?: |$|\n)/g,
    //isolate_function = /^(?=( *\w+\(.*\).*$)|( *[{}].*$)|(;.*)|( *\/\*{1,2})|( *\*)|( *.*\*\/)).*$/g,
    // is_function2 = /(?<=\n)(?!( *[\w_]+\(.*\)(.*\n *?)*?{)|( *[^\w]*[{}].*)|( *\/\*{1,2})|( *\*)|(.*\*\/))(.*)/g,
    // is_funct_replace = '//$&',
    comment_out_stuff = /(?<=\n|\r)(?= *((?:class|static|local|global) \w*)|( *\w+\(.*\).*)|[{}]|( *[{}].*)|( *\/\*{1,2})|( *\*)|( *.*\*\/)).*/g,
    comment_lines = /\n/g,
    four_comments = /[\/]{4}/g,
    // find_func_true = / *?[\w_]+\(.*?\).*?(\n|\r){0,2} *?\{/gm,
    find_set_equals = /\:\=/g,
    nuke            = /\/\/.*/g

    
    
const reset = "\x1b[0m"
const bright = "\x1b[1m"
const dim = "\x1b[2m"
const underscore = "\x1b[4m"
const blink = "\x1b[5m"
const reverse = "\x1b[7m"
const hidden = "\x1b[8m"

const black = "\x1b[30m"
const red = "\x1b[31m"
const green = "\x1b[32m"
const yellow = "\x1b[33m"
const blue = "\x1b[34m"
const magenta = "\x1b[35m"
const cyan = "\x1b[36m"
const white = "\x1b[37m"

const BGblack = "\x1b[40m"
const BGred = "\x1b[41m"
const BGgreen = "\x1b[42m"
const BGyellow = "\x1b[43m"
const BGblue = "\x1b[44m"
const BGmagenta = "\x1b[45m"
const BGcyan = "\x1b[46m"
const BGwhite = "\x1b[47m"
    
    
    
    
    ;

exports.handlers = {
  beforeParse(e) {
    if (extension === extname(e.filename)) {
        
      t = '//'  + e.source.replace(/\:\/\//g, '********')
      t1 = t.replace(comment_out_stuff, '//$&')
      t2 = t1.replace(comment_lines, '$&//')
      t3 = t2.replace(four_comments,'')
      t4 = t3.replace(/global /g,'//$&')
      t5 = t4.replace(find_set_equals, '=')
      t6 = t5.replace(nuke, '')
      t7 = t6.replace(/\r\n/g, '%%')
      t8 = t7.replace(/\r|\n/g, '%')
      t9 = t8.replace(/\%\%/g, '\r\n')
      t10 = t9.replace(/\%/g, '\r\n')
      t11 = t10.replace(/\%/g, '\r\n')
      t12 = t11.replace(/\*\*\*\*\*\*\*\*/g, ':\/\/')
      // log(t12)
      e.source = t12; 
    }
  }
};

exports.defineTags = function(dictionary) {
            // log (dictionary),
    dictionary.defineTag('fixed', {
        canHaveType: true,
        onTagged: function(doclet, tag) {
            if (!doclet.routeparams) {
              doclet.routeparams = [];
            }
			//kill the function if node isn't real >:3c
            if (typeof doclet.meta.code.node == "undefined")
				return
			//doclet.type doesn't exist? we cool! lets make it ourselves!
            else if (typeof doclet.type == "undefined") {
              doclet.type = new Object()
              doclet.type.names = new Array()
            }
			//doclet.type was never assigned too? oh nyo!!
            else if (typeof doclet.type.names == "undefined") {
              doclet.type.names = new Array()
            }
			
            log(cyan + doclet.meta.filename + reset + " has an " + yellow + "@fixed" + reset+ " tag on " + cyan + doclet.meta.code.name + reset)
			
            //awesome we have a type so we assign it!
            if (tag.value.type.names.length > 0)
            {
              doclet.type.names = doclet.type.names.concat(tag.value.type.names)
              doclet.defaultvalue = doclet.meta.code.node.value.raw
            }
			//figure it out ourselves
            else
            {
              //panic in regex
              str = doclet.meta.code.node.value.raw
              if (str.match(/\d*?\.*\d*/g))//Number
              {
                if(!doclet.type.names.includes('Number'))
                  doclet.type.names.push('Number')
                doclet.defaultvalue = doclet.meta.code.node.value.raw
              }
              if (str.match(/\0\x[0-9a-fA-F]*/g)) //Hex
              {
                if(!doclet.type.names.includes('Hexadecimal'))
                  doclet.type.names.push('Hexadecimal')
                doclet.defaultvalue = doclet.meta.code.node.value.raw
              }
              else if (str.match(/[\"\'].*?[\"\']/g)) //String
              {
                if(!doclet.type.names.includes('String'))
                  doclet.type.names.push('String')
                doclet.defaultvalue = doclet.meta.code.node.value.raw
              }
              else{
                doclet.defaultvalue = doclet.meta.code.node.value.raw
              }
            }
            doclet.kind  = 'constant'
            doclet.scope = 'static'
        }
    });
};