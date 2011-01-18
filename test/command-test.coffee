require.paths.unshift __dirname + "/../src"

vows = require('vows')
assert = require('assert')
command = require('command')

vows.describe('loadSettingsFromFile').addBatch({
  'when loading settings from a file':
    topic: ->
      command.loadSettingsFromFile(__dirname + "/fixtures/settings.yaml")

    'it should return a settings object': (topic) ->
      assert.deepEqual topic, {
        input: 'test/fixtures/templates',
        output: 'test/fixtures/templates.js',
        namespace: 'window',
        templateExtension: 'html'
      }
}).export module