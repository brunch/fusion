require.paths.unshift __dirname + "/../src"

vows    = require 'vows'
assert  = require 'assert'
fusion  = require 'fusion'
fs      = require 'fs'
command = require 'command'

cleanUpFusion = ->
  fs.unlinkSync(fusion.settings.output)
  fusion.sources = []
  fusion.settings = {}
  fusion.output = []

vows.describe('createTemplateObject').addBatch({
  'when building an namespace assigment':
    topic: ->
      fusion.settings = command.loadSettingsFromFile(__dirname + "/fixtures/settings.yaml")
      fusion.createTemplateObject('Sunshine', 'templates/sunshine.html')

    'it should be a valid one': (topic) ->
      assert.equal topic, "window.templates.sunshine = 'Sunshine';"
}).export module

vows.describe('createDirectoryObject').addBatch({
  'when initializing a namespace':
    topic: ->
      fusion.settings.namespace  = 'window'
      fusion.createDirectoryObject("app/templates/designs", "app/")

    'it should be a valid assignment': (topic) ->
      assert.equal topic, "window.templates.designs = {};"
}).export module

vows.describe('writeOutputFile').addBatch({
  'when writing the output to the file':
    topic: ->
      fusion.settings = command.loadSettingsFromFile(__dirname + "/fixtures/settings.yaml")
      fusion.settings.output = __dirname + '/test.js'
      fusion.output = ['a', 'b']
      fusion.writeOutputFile(this.callback)

    'it should generate a valid file': (topic) ->
      content = fs.readFileSync(fusion.settings.output, "utf8")
      assert.equal content, "(function(){ab})();"
    teardown: ->
      cleanUpFusion()
}).export module

vows.describe('mergeFiles').addBatch({
  'when merging a folder':
    topic: ->
      fusion.settings = command.loadSettingsFromFile(__dirname + "/fixtures/settings.yaml")
      fusion.mergeFiles(this.callback)

    'it should generate a valid js file': (topic) ->
      content = fs.readFileSync(fusion.settings.output, "utf8")
      assert.equal content, "(function(){window.templates = {};window.templates.a = '<h1>a</h1>\\n';window.templates.b = {};window.templates.c = '<p>c</p>\\n';window.templates.b.b = {};window.templates.b.b.b = '<h2>b</h2>\\n';})();"
    teardown: ->
      cleanUpFusion()
}).export module

vows.describe('compileTemplate').addBatch({
  'when compiling a template with single quotes':
    topic: -> fusion.compileTemplate("Steve's Test")

    'it should escape them': (topic) ->
      assert.equal topic, "'Steve\\'s Test'"

  'when compiling a template with newline chars':
    topic: -> fusion.compileTemplate("Test\nTest")

    'it should escape them': (topic) ->
      assert.equal topic, "'Test\\nTest'"
}).export module

vows.describe('templateNamespace').addBatch({
  'when generating namespace for a template':
    topic: ->
      fusion.settings = command.loadSettingsFromFile(__dirname + "/fixtures/settings.yaml")
      fusion.templateNamespace 'templates/sunshine.html', ''

    'it should create a proper namespace': (topic) ->
      assert.equal topic, "window.templates.sunshine"
}).export module
