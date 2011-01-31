(function() {
  var BANNER, SWITCHES, fs, fusion, helpers, optparse, parseOptions, path, settings, usage, version, yaml, _;
  fs = require('fs');
  path = require('path');
  yaml = require('yaml');
  _ = require('underscore');
  fusion = require('./fusion');
  optparse = require('./optparse');
  helpers = require('./helpers');
  SWITCHES = [['-v', '--version', 'display fusion version'], ['-h', '--help', 'display this help message'], ['-i', '--input [DIR]', 'set input path of templates'], ['-o', '--output [FILE]', 'set output path of templates'], ['-k', '--hook [FILE]', 'set path to a js file to hook in your own compile function'], ['-n', '--namespace [VALUE]', 'set export namespace'], ['-e', '--templateExtension [VALUE]', 'set extension of template files which should be compiled'], ['-c', '--config [FILE]', 'set path of settings file'], ['-w', '--watch', 'watch files (currently you have to restart if files are added or renamed)']];
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
    settings = exports.loadSettingsFromFile(opts.config);
    settings = exports.loadDefaultSettings(settings);
    settings = exports.loadSettingsFromArguments(settings, opts);
    fusion = exports.loadHooks(settings.hook, fusion, opts);
    return fusion.run(settings);
  };
  exports.loadSettingsFromFile = function(settings_file) {
    var currentSettings, stats;
    settings_file || (settings_file = "settings.yaml");
    try {
      stats = fs.statSync(settings_file);
      currentSettings = yaml.eval(fs.readFileSync(settings_file, 'utf8'));
    } catch (e) {
      helpers.printLine("Couldn't find a settings file");
      currentSettings = {};
    }
    return currentSettings;
  };
  exports.loadDefaultSettings = function(currentSettings) {
    if (!currentSettings.namespace) {
      currentSettings.namespace = "window";
    }
    if (!currentSettings.templateExtension) {
      currentSettings.templateExtension = "html";
    }
    if (!currentSettings.input) {
      currentSettings.input = "templates";
    }
    if (!currentSettings.output) {
      currentSettings.output = "templates.js";
    }
    if (!currentSettings.hook) {
      currentSettings.hook = "fusion_hooks.js";
    }
    return currentSettings;
  };
  exports.loadSettingsFromArguments = function(currentSettings, opts) {
    if (opts.namespace) {
      currentSettings.namespace = opts.namespace;
    }
    if (opts.templateExtension) {
      currentSettings.templateExtension = opts.templateExtension;
    }
    if (opts.arguments[0]) {
      currentSettings.input = opts.arguments[0];
    }
    if (opts.output) {
      currentSettings.output = opts.output;
    }
    if (opts.hook) {
      currentSettings.hook = opts.hook;
    }
    if (opts.watch) {
      currentSettings.watch = opts.watch;
    }
    return currentSettings;
  };
  exports.loadHooks = function(hook_file, currentFusion, opts) {
    var hooks, stats;
    try {
      stats = fs.statSync(hook_file);
      hook_file = path.join(path.dirname(fs.realpathSync(hook_file)), hook_file);
      hooks = require(hook_file);
      _.each(hooks, function(value, key) {
        return currentFusion[key] = value;
      });
    } catch (e) {
      helpers.printLine("No hooks have been loaded.");
    }
    return fusion;
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
