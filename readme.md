# Fusion

Fusion provides a way to merge multiple Files (usually JavaScript Templates) into one namespace. It was inspired by [Jammit](http://documentcloud.github.com/jammit/). Since Jammit doesn't support to watch files via command-line, it's not usable for development except RubyOnRails.

Special Thanks to the [CoffeeScript](http://jashkenas.github.com/coffee-script/) Team. I was able to reuse several parts of their code.

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

## TODO

* run fusion without existing settings.yaml file
* add github page
* improve monitore preformance
* improve regex in createTemplateObject to work with dotfiles and add option ignoreDotFiles
