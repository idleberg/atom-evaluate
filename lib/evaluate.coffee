vm = require "vm"

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
          description: "Specify the default [preset](https://babeljs.io/docs/plugins/#presets) for the Babel compiler"
          type: "string",
          default: "es2015",
          enum: [
            "es2015",
            "es2016",
            "es2017",
            "env"
          ],
          order: 3
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
          type: "boolean"
          default: false
          order: 1
    coffeeScript:
      title: "CoffeeScript Settings"
      type: "object"
      order: 3
      properties:
        scopes:
          title: "Scopes for CoffeeScript"
          description: "Space-delimited list of scopes identifying CoffeeScript files"
          type: "string"
          default: "source.coffee source.embedded.coffee"
          order: 0
        babelTransform:
          title: "Babel Transform"
          type: "boolean"
          default: false
          order: 1
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
        babelTransform:
          title: "Babel Transform"
          type: "boolean"
          default: false
          order: 1
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
      coffee = require "coffee-script"
      vm.runInThisContext(console.clear()) if atom.config.get "evaluate.general.alwaysClearConsole"

      try
        vm.runInThisContext(console.time("Transpiled CoffeeScript")) if atom.config.get "evaluate.general.showTimer"
        jsCode = coffee.compile(code, bare: true)
        vm.runInThisContext(console.timeEnd("Transpiled CoffeeScript")) if atom.config.get "evaluate.general.showTimer"

        result = @evaluateJavaScript(jsCode, "coffeeScript")

        callback(null, null, result)
      catch error
        callback(error)

    else if @isSupportedScope(scope, "typeScript")
      typestring = require "typestring"
      vm.runInThisContext(console.clear()) if atom.config.get "evaluate.general.alwaysClearConsole"

      try
        vm.runInThisContext(console.time("Transpiled TypeScript")) if atom.config.get "evaluate.general.showTimer"
        jsCode = typestring.compile(code)
        vm.runInThisContext(console.timeEnd("Transpiled TypeScript")) if atom.config.get "evaluate.general.showTimer"

        result = @evaluateJavaScript(jsCode, "typeScript")

        callback(null, null, result)
      catch error
        callback(error)

    else if @isSupportedScope(scope, "liveScript")
      livescript = require "LiveScript"
      vm.runInThisContext(console.clear()) if atom.config.get "evaluate.general.alwaysClearConsole"

      try
        vm.runInThisContext(console.time("Transpiled LiveScript")) if atom.config.get "evaluate.general.showTimer"
        jsCode = livescript.compile(code, bare: true)
        vm.runInThisContext(console.timeEnd("Transpiled LiveScript")) if atom.config.get "evaluate.general.showTimer"

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
    atom.notifications.addWarning("**evaluate**: No open files", dismissable: false) unless editor?.constructor.name is "TextEditor" or editor?.constructor.name is "ImageEditor"

    code = editor.getSelectedText()

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
      babelCode = @babelCompile(code)
      code = babelCode.code

    vm.runInThisContext(console.time("Evaluated JavaScript")) if atom.config.get "evaluate.general.showTimer"
    result = vm.runInThisContext(code)
    vm.runInThisContext(console.timeEnd("Evaluated JavaScript")) if atom.config.get "evaluate.general.showTimer"

    return result

  babelCompile: (code) ->
    babel = require "babel-core"

    babelPreset = atom.config.get("evaluate.general.babelPreset") || "es2015"

    babelOptions =
      ast: false
      code: true
      presets: ["babel-preset-#{babelPreset}"].map(require.resolve)

    vm.runInThisContext(console.time("Transformed with Babel preset '#{babelPreset}'")) if atom.config.get "evaluate.general.showTimer"
    babelCode = babel.transform(code, babelOptions)
    vm.runInThisContext(console.timeEnd("Transformed with Babel preset '#{babelPreset}'")) if atom.config.get "evaluate.general.showTimer"

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
