# Fusion

Fusion is a simple tool to merge multiple JavaScript templates (mustache, handlebars, jquery-tmpl, …) into one namespaced template object.

## What is fusion good for?

You might have noticed that using script tags to manage your JavaScript templates can become quite a mess if you have a bunch of them. Therefore splitting them into several files is a good idea. Fusion helps you bring them back together in one neatly organized namespace.

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

### Demo

You can see it running by switching to demo folder and run it with watch option.
You can change anything in the templates, refresh the index.html and see the new content.

    cd demo
    ./../bin/fusion --watch

## Development

### Contributing

Feel free to make a pull request or contact me on Twitter @nikgraf.

### Tests

    vows --spec test/*.coffee

## Thanks

It was inspired by [Jammit](http://documentcloud.github.com/jammit/)'s templating functionality. Since Jammit doesn't support to watch files via command-line, it's hard to use for development without RubyOnRails.

Special Thanks to the [CoffeeScript](http://jashkenas.github.com/coffee-script/) Team. I was able to reuse several parts of their code.

## TODO

* watch issues with textmate
* add github page
* improve regex in createTemplateObject to work with dotfiles and add option ignoreDotFiles
