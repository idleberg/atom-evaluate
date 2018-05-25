vm = require "vm"

String::capitalize = ->
  @charAt(0).toUpperCase() + @slice(1)

module.exports =
  config:
    general:
      title: "General Settings"
      type: "object"
      order: 0
      properties:
        openDeveloperTools:
          title: "Open Developer Tools"
          description: "Opens the Developer Tools prior to evaluating code"
          type: "boolean",
          default: true
          order: 0
        alwaysClearConsole:
          title: "Always Clear Console"
          description: "Clears the console prior to evaluating code"
          type: "boolean"
          default: true
          order: 1
        showTimer:
          title: "Show Timer"
          description: "Displays transpilation and execution times in console"
          type: "boolean"
          default: true
          order: 2
        babelPreset:
          title: "Babel Preset"
          description: "Specify the default [preset](https://babeljs.io/docs/plugins/#presets) for Babel"
          type: "string",
          default: "es2015",
          enum: [
            "es2015"
            "es2016"
            "es2017"
            "env"
          ],
          order: 3
        babelExperimentalPreset:
          title: "Babel Experimental Preset"
          description: "Specify an [experimental preset](https://babeljs.io/docs/plugins/#presets-stage-x-experimental-presets-) for Babel"
          type: "string",
          default: "(none)",
          enum: [
            "(none)"
            "stage-0"
            "stage-1"
            "stage-2"
            "stage-3"
          ],
          order: 4
    javaScript:
      title: "JavaScript Settings"
      type: "object"
      order: 1
      properties:
        scopes:
          title: "Scopes for JavaScript"
          description: "Space-delimited list of scopes identifying JavaScript files"
          type: "string"
          default: "source.js source.embedded.js"
          order: 0
        babelTransform:
          title: "Babel Transform"
          description: "Transforms code with specified Babel presets (see above)"
          type: "boolean"
          default: true
          order: 1
    typeScript:
      title: "TypeScript Settings"
      type: "object"
      order: 2
      properties:
        scopes:
          title: "Scopes for TypeScript"
          description: "Space-delimited list of scopes identifying TypeScript files"
          type: "string"
          default: "source.ts"
          order: 0
        babelTransform:
          title: "Babel Transform"
          description: "Transforms code with specified Babel presets (see above)"
          type: "boolean"
          default: false
          order: 1
    coffeeScript:
      title: "CoffeeScript Settings"
      type: "object"
      order: 3
      properties:
        version:
          title: "Version"
          description: "Specify the version of CoffeScript you would like to use"
          type: "string",
          default: "v2",
          enum: [
            "v1"
            "v2"
          ],
          order: 0
        scopes:
          title: "Scopes for CoffeeScript"
          description: "Space-delimited list of scopes identifying CoffeeScript files"
          type: "string"
          default: "source.coffee source.embedded.coffee source.litcoffee"
          order: 1
        bare:
          title: "Bare"
          description: "Compiles the JavaScript without the [top-level function safety wrapper](http://coffeescript.org/#lexical-scope)"
          type: "boolean"
          default: true
          order: 2
        babelTransform:
          title: "Babel Transform"
          description: "Transforms code with specified Babel presets (see above)"
          type: "boolean"
          default: false
          order: 3
    liveScript:
      title: "LiveScript Settings"
      type: "object"
      order: 4
      properties:
        scopes:
          title: "Scopes for LiveScript"
          description: "Space-delimited list of scopes identifying LiveScript files"
          type: "string"
          default: "source.livescript"
          order: 0
        bare:
          title: "Bare"
          description: "Compiles the JavaScript without the top-level function safety wrapper"
          type: "boolean"
          default: true
          order: 1
        const:
          title: "Constants"
          description: "Compiles all variables as constants"
          type: "boolean"
          default: false
          order: 2
        babelTransform:
          title: "Babel Transform"
          description: "Transforms code with specified Babel presets (see above)"
          type: "boolean"
          default: false
          order: 3
  subscriptions: null

  activate: ->
    # Events subscribed to in Atom's system can be easily cleaned up with a CompositeDisposable
    { CompositeDisposable } = require "atom"
    @subscriptions = new CompositeDisposable


    # Register command that toggles this view
    @subscriptions.add atom.commands.add "atom-workspace", "evaluate:run-code": => @evaluate()

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  runCodeInScope: (code, scope, callback) ->
    # switch scope
    if @isSupportedScope(scope)
      vm.runInThisContext(console.clear()) if atom.config.get "evaluate.general.alwaysClearConsole"

      try
        result = @evaluateJavaScript(code)

        callback(null, null, result)
      catch error
        callback(error)

    else if @isSupportedScope(scope, "coffeeScript")
      coffeeVersion = atom.config.get "evaluate.coffeeScript.version"
      if coffeeVersion is "v2"
        coffee = require "coffeescript"
      else
        coffee = require "coffee-script"

      vm.runInThisContext(console.clear()) if atom.config.get "evaluate.general.alwaysClearConsole"

      options =
        bare: atom.config.get "evaluate.coffeeScript.bare"

      try
        vm.runInThisContext(console.time("Compiled CoffeeScript #{coffeeVersion}")) if atom.config.get "evaluate.general.showTimer"
        jsCode = coffee.compile(code, options)
        vm.runInThisContext(console.timeEnd("Compiled CoffeeScript #{coffeeVersion}")) if atom.config.get "evaluate.general.showTimer"

        result = @evaluateJavaScript(jsCode, "coffeeScript")

        callback(null, null, result)
      catch error
        callback(error)

    else if @isSupportedScope(scope, "typeScript")
      typestring = require "typestring"
      vm.runInThisContext(console.clear()) if atom.config.get "evaluate.general.alwaysClearConsole"

      try
        vm.runInThisContext(console.time("Compiled TypeScript")) if atom.config.get "evaluate.general.showTimer"
        jsCode = typestring.compile(code)
        vm.runInThisContext(console.timeEnd("Compiled TypeScript")) if atom.config.get "evaluate.general.showTimer"

        result = @evaluateJavaScript(jsCode, "typeScript")

        callback(null, null, result)
      catch error
        callback(error)

    else if @isSupportedScope(scope, "liveScript")
      livescript = require "LiveScript"
      vm.runInThisContext(console.clear()) if atom.config.get "evaluate.general.alwaysClearConsole"

      options =
        bare: atom.config.get "evaluate.liveScript.bare"
        const: atom.config.get "evaluate.liveScript.const"

      try
        vm.runInThisContext(console.time("Compiled LiveScript")) if atom.config.get "evaluate.general.showTimer"
        jsCode = livescript.compile(code, options)
        vm.runInThisContext(console.timeEnd("Compiled LiveScript")) if atom.config.get "evaluate.general.showTimer"

        result = @evaluateJavaScript(jsCode, "liveScript")

        callback(null, null, result)
      catch error
        callback(error)

    else
      warning = "Evaluating '#{scope}' is not supported."
      callback(null, warning)

  evaluate: ->
    atom.openDevTools() if atom.config.get "evaluate.general.openDeveloperTools"

    editor = atom.workspace.getActiveTextEditor()
    code = @getSelections(editor)

    if code
      scope = @matchingCursorScopeInEditor(editor)
    else
      code = editor.getText()
      scope = @scopeInEditor(editor)

    @runCodeInScope code, scope, (error, warning, result) ->
      if error
        console.error error if error
      else if warning
        console.warn warning if warning
      else
        console.log result if result

  evaluateJavaScript: (code, type = "javaScript") ->
    if atom.config.get "evaluate.#{type}.babelTransform"
      babelCode = @babelCompile(code, type)
      code = babelCode.code

    require("./ga").sendEvent "evaluate", type.capitalize()

    vm.runInThisContext(console.time("Evaluated JavaScript")) if atom.config.get "evaluate.general.showTimer"
    result = vm.runInThisContext(code)
    vm.runInThisContext(console.timeEnd("Evaluated JavaScript")) if atom.config.get "evaluate.general.showTimer"

    return result

  babelCompile: (code) ->
    babel = require "babel-core"
    presets = []

    babelPreset = atom.config.get("evaluate.general.babelPreset") || "es2015"
    presets.push "babel-preset-#{babelPreset}"

    babelExperimentalPreset = atom.config.get("evaluate.general.babelExperimentalPreset")
    presets.push "babel-preset-#{babelExperimentalPreset}" if babelExperimentalPreset isnt "(none)"

    babelOptions =
      ast: false
      code: true
      presets: presets.map(require.resolve)

    vm.runInThisContext(console.time("Transformed with Babel [\"#{presets.join("\", \"")}\"]")) if atom.config.get "evaluate.general.showTimer"
    babelCode = babel.transform(code, babelOptions)
    vm.runInThisContext(console.timeEnd("Transformed with Babel [\"#{presets.join("\", \"")}\"]")) if atom.config.get "evaluate.general.showTimer"

    return babelCode

  matchingCursorScopeInEditor: (editor) ->
    scopes = @getScopes()

    for scope in scopes
      return scope if scope in editor.getLastCursor().getScopeDescriptor().scopes

  isSupportedScope: (scope, type = "javaScript")->
    if scope in atom.config.get("evaluate.#{type}.scopes").trim().split(" ")
      return true

    return false

  getScopes: ->
    scopeList = ["javaScript", "typeScript", "coffeeScript", "liveScript"]
    result = ""

    for scope in scopeList
      result += atom.config.get("evaluate.#{scope}.scopes").trim() + " "

    return result.trim().split " "

  scopeInEditor: (editor) ->
    editor.getGrammar()?.scopeName

  getSelections: (editor) ->
    selections = editor.getSelections()
    code = ""

    if selections[0].getText()
      for selection in selections
        code += selection.getText()

    return code
