require.paths.unshift __dirname + "/../src"

vows = require('vows')
assert = require('assert')
command = require('command')

vows.describe('loadSettingsFromFile').addBatch(
  'when loading settings from a file':
    topic: ->
      command.loadSettingsFromFile(__dirname + "/fixtures/settings.yaml")

    'it should return a settings object': (topic) ->
      assert.deepEqual topic,
        input: 'test/fixtures/templates'
        output: 'test/fixtures/templates.js'
        namespace: 'window'
        templateExtension: 'html'
        hook: 'hook.js'
).export module

vows.describe('loadDefaultSettings').addBatch(
  'when loading default settings':
    topic: ->
      command.loadDefaultSettings({})

    'it should return a settings object with default values': (topic) ->
      assert.deepEqual topic,
        input: 'templates'
        output: 'templates.js'
        namespace: 'window'
        templateExtension: 'html'
        hook: 'fusion_hooks.js'
).export module
