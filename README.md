# evaluate

[![apm](https://flat.badgen.net/apm/license/evaluate)](https://atom.io/packages/evaluate)
[![apm](https://flat.badgen.net/apm/v/evaluate)](https://atom.io/packages/evaluate)
[![apm](https://flat.badgen.net/apm/dl/evaluate)](https://atom.io/packages/evaluate)
[![CircleCI](https://flat.badgen.net/circleci/github/idleberg/atom-evaluate)](https://circleci.com/gh/idleberg/atom-evaluate)
[![David](https://flat.badgen.net/david/dep/idleberg/atom-evaluate)](https://david-dm.org/idleberg/atom-evaluate)

Evaluates JavaScript, TypeScript, and CoffeeScript directly in Atom. A fork of Roben Kleene's [run-in-atom](https://github.com/robenkleene/run-in-atom) package. [See it in action](https://vimeo.com/230280295)!

## Features

- Code is evaluated in sandboxed [Node VM](https://nodejs.org/api/vm.html)
- Runs JavaScript, [TypeScript](https://www.typescriptlang.org/), [CoffeeScript](http://coffeescript.org/)
- Supports [Babel Presets](https://babeljs.io/docs/plugins/#presets)
- Define custom scopes for each supported language

## Installation

### apm

Install `evaluate` from Atom's [Package Manager](http://flight-manual.atom.io/using-atom/sections/atom-packages/) or the command-line equivalent:

`$ apm install evaluate`

### Using Git

Change to your Atom packages directory:

```
# Windows
$ cd %USERPROFILE%\.atom\packages

# Linux & macOS
$ cd ~/.atom/packages/
```

Clone the repository as `evaluate`:

```
$ git clone https://github.com/idleberg/atom-evaluate evaluate
```

## Usage

To evaluate code, run the command from the context-menu, the command palette or using the <kbd>Cmd</kbd>+<kbd>Alt</kbd>+<kbd>R</kbd> shortcut. You can evaluate entire files or selections (Note that code will be evaluated in the order it has been selected!)

## License

This work is licensed under the [The MIT License](LICENSE.md).

## Donate

You are welcome support this project using [Flattr](https://flattr.com/submit/auto?user_id=idleberg&url=https://github.com/idleberg/atom-evaluate) or Bitcoin `17CXJuPsmhuTzFV2k4RKYwpEHVjskJktRd`
