var commentPattern = /\/\*\*[\s\S]+?\*\//g,
    find_function = /((?<=\n|^)[^*\n:=()_\w]+([\w_]+?\([^:\n]*\)).*)|(.*)/g,
    replace_function = 'function $2\{\}',
    notNewLinePattern = /[^\n]/g,
    extname = require('path').extname,
    extension = '.ahk',
    comments;

exports.handlers = {
  beforeParse(e) {
    if (extension === extname(e.filename)) {
      comments = e.source.match(commentPattern);
      e.source = comments ? e.source.split(commentPattern).reduce(function(result, source, i) {
        return result + source.replace(notNewLinePattern, '') + comments[i];
      }, '') : e.source.replace(find_function, replace_function).replace(/function {}/g, ''); 
    }
  }
};
