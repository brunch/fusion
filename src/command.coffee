# The 'fusion' utility handles compiling files to strings and
# merge them into a JavaScript namespace. It also contains a
# watch mode to update the output file if the source changed.

# External dependencies.
fs          = require 'fs'
yaml        = require 'yaml'
fusion      = require './fusion'
optparse    = require './optparse'
helpers     = require './helpers'

# The list of all the valid option flags that 'fusion' knows how to handle.
SWITCHES = [
  ['-v', '--version',                     'display fusion version']
  ['-h', '--help',                        'display this help message']
  ['-i', '--input [DIR]',                 'set input path of templates']
  ['-o', '--output [FILE]',               'set output path of templates']
  ['-n', '--namespace [VALUE]',           'set export namespace']
  ['-e', '--templateExtension [VALUE]',   'set extension of template files which should be compiled']
  ['-c', '--config [FILE]',               'set path of settings file']
  ['-w', '--watch',                       'watch files (currently you have to restart if files are added or renamed)']
]

# The help banner which is printed if fusion command-line tool ist called with '--help' option.
BANNER = '''
  Usage: fusion [options] [<directory>]
         '''
settings = {}

# Run 'fusion' by parsing passed options and determining what action to take.
# This also includes checking for a settings file. Settings in commandline arguments
# overwrite settings from the settings file. In this case you are able to have
# reasonable defaults and changed only the settings you need to change in this particular case.
exports.run = ->
  opts = parseOptions()
  return usage() if opts.help
  return version() if opts.version
  settings = exports.loadSettingsFromFile(opts.config)
  settings = exports.loadDefaultSettings(settings)
  settings = exports.loadSettingsFromArguments(settings, opts)
  fusion.run(settings)

# Load settings from a settings file if available.
exports.loadSettingsFromFile = (settings_file) ->
  settings_file or= "settings.yaml"
  try
    stats = fs.statSync settings_file
    currentSettings = yaml.eval fs.readFileSync(settings_file, 'utf8')
  catch e
    helpers.printLine "Couldn't find a settings file"
    currentSettings = {}
  currentSettings

# Set some reasonable defaults if they haven't been defined.
exports.loadDefaultSettings = (currentSettings) ->
  currentSettings.namespace = "window" unless currentSettings.namespace
  currentSettings.templateExtension = "html" unless currentSettings.templateExtension
  currentSettings.input = "templates" unless currentSettings.input
  currentSettings.output = "templates.js" unless currentSettings.output
  currentSettings

# Load settings from arguments.
exports.loadSettingsFromArguments = (currentSettings, opts) ->
  currentSettings.namespace = opts.namespace if opts.namespace
  currentSettings.templateExtension = opts.templateExtension if opts.templateExtension
  currentSettings.input = opts.arguments[0] if opts.arguments[0]
  currentSettings.output = opts.output if opts.output
  currentSettings.watch = opts.watch if opts.watch
  currentSettings

# Run optparser which was taken from Coffeescript 1.0.0
parseOptions = ->
  optionParser  = new optparse.OptionParser SWITCHES, BANNER
  optionParser.parse process.argv.slice 2

# Print the '--help' usage message and exit.
usage = ->
  helpers.printLine (new optparse.OptionParser SWITCHES, BANNER).help()
  process.exit 0

# Print the '--version' message and exit.
version = ->
  helpers.printLine "Fusion version #{fusion.VERSION}"
  process.exit 0
