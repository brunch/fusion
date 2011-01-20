(function() {
  var fs, helpers, path, resetGlobals, watcher;
  fs = require('fs');
  path = require('path');
  helpers = require('./helpers');
  watcher = require('watch');
  exports.VERSION = '0.0.3';
  exports.sources = [];
  exports.settings = {};
  exports.output = [];
  exports.run = function(settings) {
    exports.settings = settings;
    exports.mergeFiles();
    if (exports.settings.watch) {
      return exports.watch();
    }
  };
  exports.mergeFiles = function(callback) {
    var options;
    options = {
      ignoreDotFiles: true
    };
    options.filter = function(file) {
      if (path.extname(file) === ("." + exports.settings.templateExtension) || path.extname(file) === "") {
        return false;
      } else {
        return true;
      }
    };
    return watcher.walk(exports.settings.input, options, function(err, files) {
      exports.sources = files;
      exports.generateOutput();
      return exports.writeOutputFile(callback);
    });
  };
  exports.generateOutput = function() {
    var compiledContent, dirPrefix, dirPrefixMatch, source, stat, _ref, _results;
    dirPrefixMatch = exports.settings.input.match(new RegExp("^(.*\/{1})[^\/]*$"), 'a');
    dirPrefix = dirPrefixMatch ? dirPrefixMatch[1] : '';
    _ref = exports.sources;
    _results = [];
    for (source in _ref) {
      stat = _ref[source];
      _results.push(stat.isDirectory() ? exports.output.push(exports.createDirectoryObject(source, dirPrefix)) : (compiledContent = exports.compileTemplate(fs.readFileSync(source, 'utf8')), exports.output.push(exports.createTemplateObject(compiledContent, source, dirPrefix))));
    }
    return _results;
  };
  exports.createDirectoryObject = function(source, directoryPrefix) {
    var namespace;
    namespace = source.replace(directoryPrefix, '');
    namespace = namespace.replace(/\//g, '.');
    return "" + exports.settings.namespace + "." + namespace + " = {};";
  };
  exports.createTemplateObject = function(content, source, directoryPrefix) {
    var namespace;
    namespace = source.replace(directoryPrefix, '');
    namespace = namespace.match(new RegExp("^(.*)\." + exports.settings.templateExtension + "$"), 'a')[1];
    namespace = namespace.replace(/\//g, '.');
    return "" + exports.settings.namespace + "." + namespace + " = '" + content + "';";
  };
  exports.compileTemplate = function(content) {
    content = content.replace(/\n/g, '\\n');
    return content.replace(/'/g, '\\\'');
  };
  exports.writeOutputFile = function(callback) {
    var templates;
    templates = exports.output.join('');
    templates = "(function(){" + templates + "})();";
    return fs.writeFile(exports.settings.output, templates, function(err) {
      helpers.printLine("Compiled files");
      if (callback) {
        return callback();
      }
    });
  };
  exports.watch = function() {
    return watcher.createMonitor(exports.settings.input, {
      persistent: true,
      interval: 50
    }, function(monitor) {
      monitor.on("changed", function(file) {
        resetGlobals();
        return exports.mergeFiles();
      });
      monitor.on("created", function(file) {
        resetGlobals();
        return exports.mergeFiles();
      });
      return monitor.on("removed", function(file) {
        resetGlobals();
        return exports.mergeFiles();
      });
    });
  };
  resetGlobals = function() {
    exports.output = [];
    return exports.sources = [];
  };
}).call(this);
