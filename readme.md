# Fusion

Fusion is a simple tool to merge multiple JavaScript templates (mustache, handlebars, jquery-tmpl, …) into one namespaced template object. It also allows you to define your own precompiling functions.

## What is fusion good for?

You might have noticed that using script tags to manage your JavaScript templates can become quite a mess if you have a bunch of them. It's a good idea to split them into several files. Fusion helps you bring them back together in one neatly organized namespace.

For example if you have a directory structure like

    templates/home.html
    templates/notes/overview.html
    templates/notes/detail.html

fusion would compile it to

    (function(){
      window.templates = {};
      window.templates.home = '<content of home.html>';
      window.templates.notes = {};
      window.templates.notes.overview = '<content of overview.html>';
      window.templates.notes.detail = '<content of detail.html>';
    })();

## Installation

    npm install fusion

## How to use

### Command-line

You can run the script to compile templates via

    fusion [options] [<directory>]

Optional use --watch to watch changes in the given directory.
You don't need to set a directory. You can leave it out and use
the one from settings or even fusion's default which is 'templates'.

Basically you are able to change these settings:

set output path of templates

    --output [FILE]

set export namespace

    --namespace [VALUE]

set extension of template files which should be merged

    --templateExtension [VALUE]

set path of settings file

    --config [FILE]

set path of the hook file

    --hook [FILE]

#### Example

    fusion --watch --config fusion_settings.yaml

### Settings file

All options except "--watch" and "--config" can be set in the settings file.
Unless --config is defined the script will search for "settings.yaml"
in the current directory.

Possible settings are

* namespace
* templateExtension
* input
* output
* hook

### Hooks file

The hooks file provides a way to overwrite all public methods of fusion.
Probably the most common case will be to overwrite the compileTemplate method.

#### Example

For example to use eco's precompiling for our templates we can create a file
fusion_hooks.js which contains something like this

    var eco = require('eco');
    exports.compileTemplate = function(content) {
      return eco.compile(content);
    };

Thats all you need to add proper precompiling to your templates.

### Default Settings

* settings file: "settings.yaml"
* namespace: "window"
* template extension: "html"
* input directory: "templates"
* output file: "templates.js"
* hook file: "fusion_hooks.js"

### Demo

You can see it running by switching to demo folder and run it with watch option.
You can change anything in the templates, refresh the index.html and see the new content.

    cd demo/simple
    ./../../bin/fusion --watch

## Development

### Contributing

Feel free to make a pull request or contact me on Twitter @nikgraf.

To compile src files to lib use

    cake watch

### Tests

    cake test

## Thanks

It was inspired by [Jammit](http://documentcloud.github.com/jammit/)'s templating functionality. Since Jammit doesn't offer file watching via command-line, it's a bit hard to use for development if you are not on a RubyOnRails stack.

Special Thanks to the [CoffeeScript](http://jashkenas.github.com/coffee-script/) Team. We were able to re-use some parts like the optparser.

## TODO

* create load settings method and export it - to run it easily without cli
* optimize for eco
* !!! add tests for hooks
* watch somehow does not work with Textmate - any pointers?
* output file - mkdirs or warn if directory doesn't exist
* add github page
* improve regex in createTemplateObject to work with dotfiles and add option to ignoreDotFiles - tmp and swp files can cause troubles
