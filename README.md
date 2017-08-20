# evaluate

[![apm](https://img.shields.io/apm/l/evaluate.svg?style=flat-square)](https://atom.io/packages/evaluate)
[![apm](https://img.shields.io/apm/v/evaluate.svg?style=flat-square)](https://atom.io/packages/evaluate)
[![apm](https://img.shields.io/apm/dm/evaluate.svg?style=flat-square)](https://atom.io/packages/evaluate)
[![Travis](https://img.shields.io/travis/idleberg/atom-evaluate.svg?style=flat-square)](https://travis-ci.org/idleberg/atom-evaluate)
[![David](https://img.shields.io/david/dev/idleberg/atom-evaluate.svg?style=flat-square)](https://david-dm.org/idleberg/atom-evaluate?type=dev)

Evaluates JavaScript, TypeScript, CoffeeScript, and LiveScript directly in Atom. A fork of Roben Kleene's [run-in-atom](https://github.com/robenkleene/run-in-atom) package. [See it in action](https://vimeo.com/230280295)!

## Features

- Runs JavaScript, [TypeScript](https://www.typescriptlang.org/), [CoffeeScript](http://coffeescript.org/) and [LiveScript](http://livescript.net/)
- Supports [Babel Presets](https://babeljs.io/docs/plugins/#presets)
- Code is evaluated in sandboxed [Node VM](https://nodejs.org/api/vm.html)
- Define custom scopes for each supported language

## Installation

### apm

Install `evaluate` from Atom's [Package Manager](http://flight-manual.atom.io/using-atom/sections/atom-packages/) or the command-line equivalent:

`$ apm install evaluate`

### Using Git

Change to your Atom packages directory:

```bash
# Windows
$ cd %USERPROFILE%\.atom\packages

# Linux & macOS
$ cd ~/.atom/packages/
```

Clone the repository as `evaluate`:

```bash
$ git clone https://github.com/idleberg/atom-evaluate evaluate
```

## Usage

To evaluate code, run the command from the context-menu, the command palette or using the <kbd>Cmd</kbd>+<kbd>Alt</kbd>+<kbd>R</kbd> shortcut. You can evaluate entire files or selections (Note that code will be evaluated in the order it has been selected!)

## License

This work is licensed under the [The MIT License](LICENSE.md).

## Donate

You are welcome support this project using [Flattr](https://flattr.com/submit/auto?user_id=idleberg&url=https://github.com/idleberg/atom-evaluate) or Bitcoin `17CXJuPsmhuTzFV2k4RKYwpEHVjskJktRd`
