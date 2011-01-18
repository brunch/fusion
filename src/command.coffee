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
  ['-v', '--version',                     'display CoffeeScript version']
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
  exports.loadSettingsFromFile(opts.config)
  exports.loadSettingsFromArguments(opts)
  fusion.run(settings)

# Load settings from a settings file or at least set some
# reasonable defaults.
exports.loadSettingsFromFile = (settings_file) ->
  settings_file or= "settings.yaml"
  settings = yaml.eval fs.readFileSync settings_file, 'utf8'
  settings.namespace = "window" unless settings.namespace
  settings.templateExtension = "html" unless settings.templateExtension
  settings.input = "templates" unless settings.input
  settings.output = "templates.js" unless settings.output
  settings

# Load settings from arguments.
exports.loadSettingsFromArguments = (opts) ->
  settings.namespace = opts.namespace if opts.namespace
  settings.templateExtension = opts.templateExtension if opts.templateExtension
  settings.input = opts.arguments[0] if opts.arguments[0]
  settings.output = opts.output if opts.output
  settings.watch = opts.watch if opts.watch
  settings

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
