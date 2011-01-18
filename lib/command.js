(function() {
  var BANNER, SWITCHES, fs, fusion, helpers, optparse, parseOptions, settings, usage, version, yaml;
  fs = require('fs');
  yaml = require('yaml');
  fusion = require('./fusion');
  optparse = require('./optparse');
  helpers = require('./helpers');
  SWITCHES = [['-v', '--version', 'display CoffeeScript version'], ['-h', '--help', 'display this help message'], ['-i', '--input [DIR]', 'set input path of templates'], ['-o', '--output [FILE]', 'set output path of templates'], ['-n', '--namespace [VALUE]', 'set export namespace'], ['-e', '--templateExtension [VALUE]', 'set extension of template files which should be compiled'], ['-c', '--config [FILE]', 'set path of settings file'], ['-w', '--watch', 'watch files (currently you have to restart if files are added or renamed)']];
  BANNER = 'Usage: fusion [options] [<directory>]';
  settings = {};
  exports.run = function() {
    var opts;
    opts = parseOptions();
    if (opts.help) {
      return usage();
    }
    if (opts.version) {
      return version();
    }
    exports.loadSettingsFromFile(opts.config);
    exports.loadSettingsFromArguments(opts);
    return fusion.run(settings);
  };
  exports.loadSettingsFromFile = function(settings_file) {
    settings_file || (settings_file = "settings.yaml");
    settings = yaml.eval(fs.readFileSync(settings_file, 'utf8'));
    if (!settings.namespace) {
      settings.namespace = "window";
    }
    if (!settings.templateExtension) {
      settings.templateExtension = "html";
    }
    if (!settings.input) {
      settings.input = "templates";
    }
    if (!settings.output) {
      settings.output = "templates.js";
    }
    return settings;
  };
  exports.loadSettingsFromArguments = function(opts) {
    if (opts.namespace) {
      settings.namespace = opts.namespace;
    }
    if (opts.templateExtension) {
      settings.templateExtension = opts.templateExtension;
    }
    if (opts.arguments[0]) {
      settings.input = opts.arguments[0];
    }
    if (opts.output) {
      settings.output = opts.output;
    }
    if (opts.watch) {
      settings.watch = opts.watch;
    }
    return settings;
  };
  parseOptions = function() {
    var optionParser;
    optionParser = new optparse.OptionParser(SWITCHES, BANNER);
    return optionParser.parse(process.argv.slice(2));
  };
  usage = function() {
    helpers.printLine((new optparse.OptionParser(SWITCHES, BANNER)).help());
    return process.exit(0);
  };
  version = function() {
    helpers.printLine("Fusion version " + fusion.VERSION);
    return process.exit(0);
  };
}).call(this);
