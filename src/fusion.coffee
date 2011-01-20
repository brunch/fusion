# Fusion can be used via command-line tool or manually by calling run(settings).

# External dependencies.
fs        = require 'fs'
path      = require 'path'
helpers   = require './helpers'
watcher   = require 'watch'

# The current fusion version number.
exports.VERSION = '0.0.3'

# Exportet objects share by several functions.
# Output and Sources are public for future improvements on caching content.
exports.sources = []
exports.settings = {}
exports.output = []

# Runs fusion with it's given settings.
# Depending on settings.watch the script will compile and exit or
# watch the given directory for changes
exports.run = (settings) ->
  exports.settings = settings
  exports.mergeFiles()
  exports.watch() if exports.settings.watch

# Walks through the input directory.
# When it's done it generates the output and writes it to a file.
exports.mergeFiles = (callback) ->
  options = ignoreDotFiles: true
  options.filter = (file) ->
    # file with no extname should be a folder
    if path.extname(file) is ".#{exports.settings.templateExtension}" or path.extname(file) is ""
    then false else true
  watcher.walk(exports.settings.input, options, (err, files) ->
    exports.sources = files
    exports.generateOutput()
    exports.writeOutputFile(callback)
  )

# Iterates through a list of directories and files. In case the source is
# a direcotry a string will be added to output which creates an empty object.
# In case it's a file it generates a string which assigns the file content
# to the namespace.
exports.generateOutput = ->
  dirPrefixMatch = exports.settings.input.match( new RegExp("^(.*\/{1})[^\/]*$"), 'a')
  dirPrefix = if dirPrefixMatch then dirPrefixMatch[1] else ''
  for source, stat of exports.sources
    if stat.isDirectory()
      exports.output.push exports.createDirectoryObject(source, dirPrefix)
    else
      compiledContent = exports.compileTemplate(fs.readFileSync(source, 'utf8'))
      exports.output.push exports.createTemplateObject(compiledContent, source, dirPrefix)

# Initializes a namespace.
# example: app/frontend/templates will start at templates = {}
exports.createDirectoryObject = (source, directoryPrefix) ->
  namespace = source.replace directoryPrefix, ''
  namespace = namespace.replace /\//g, '.'
  "#{exports.settings.namespace}.#{namespace} = {};"

# Returns a string which assigns the content to the namespace.
exports.createTemplateObject = (content, source, directoryPrefix) ->
  namespace = source.replace directoryPrefix, ''
  namespace = namespace.match( new RegExp("^(.*)\.#{exports.settings.templateExtension}$"), 'a')[1]
  namespace = namespace.replace /\//g, '.'
  "#{exports.settings.namespace}.#{namespace} = '#{content}';"

# Escapes newline and single quote characters cause they would break our generated js.
exports.compileTemplate = (content) ->
  content = content.replace /\n/g, '\\n'
  content.replace /'/g, '\\\''

# Merging all the output commands in an anonymous function and writes it to a file
exports.writeOutputFile = (callback) ->
  templates = exports.output.join('')
  templates = "(function(){#{templates}})();"

  fs.writeFile(exports.settings.output, templates, (err) ->
    helpers.printLine "Compiled files"
    callback() if callback
  )

# Check for changes on our watched direcotry and remerge all files if something changed.
# This could be improved by updating only the files which changed.
exports.watch = ->
  watcher.createMonitor(exports.settings.input, {persistent: true, interval: 50}, (monitor) ->
    monitor.on("changed", (file) ->
      resetGlobals()
      exports.mergeFiles()
    )
    monitor.on("created", (file) ->
      resetGlobals()
      exports.mergeFiles()
    )
    monitor.on("removed", (file) ->
      resetGlobals()
      exports.mergeFiles()
    )
  )

# Reset output and sources in case of remerging everthing.
resetGlobals = ->
  exports.output = []
  exports.sources = []
