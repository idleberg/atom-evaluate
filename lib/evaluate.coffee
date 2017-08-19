module.exports =
  config:
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
      default: false
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
    scopesJavaScript:
      title: "Scopes for JavaScript"
      description: "Space-delimited list of scopes identifying JavaScript files"
      type: "string"
      default: "source.js source.embedded.js"
      order: 4
    scopesCoffeeScript:
      title: "Scopes for CoffeeScript"
      description: "Space-delimited list of scopes identifying CoffeeScript files"
      type: "string"
      default: "source.coffee source.embedded.coffee"
      order: 5
    scopesTypeScript:
      title: "Scopes for TypeScript"
      description: "Space-delimited list of scopes identifying TypeScript files"
      type: "string"
      default: "source.ts"
      order: 6
    scopesLiveScript:
      title: "Scopes for LiveScript"
      description: "Space-delimited list of scopes identifying LiveScript files"
      type: "string"
      default: "source.livescript"
      order: 7
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
    vm = require "vm"

    # switch scope
    if @isSupportedScope(scope, "JavaScript")
      vm.runInThisContext(console.clear()) if atom.config.get "evaluate.alwaysClearConsole"

      try
        result = @evaluateJavaScript(code)

        callback(null, null, result)
      catch error
        callback(error)

    else if @isSupportedScope(scope, "CoffeeScript")
      coffee = require "coffee-script"
      vm.runInThisContext(console.clear()) if atom.config.get "evaluate.alwaysClearConsole"

      try
        vm.runInThisContext(console.time("Transpiled CoffeeScript")) if atom.config.get "evaluate.showTimer"
        jsCode = coffee.compile(code, bare: true)
        vm.runInThisContext(console.timeEnd("Transpiled CoffeeScript")) if atom.config.get "evaluate.showTimer"

        result = @evaluateJavaScript(jsCode)

        callback(null, null, result)
      catch error
        callback(error)

    else if @isSupportedScope(scope, "TypeScript")
      typestring = require "typestring"
      vm.runInThisContext(console.clear()) if atom.config.get "evaluate.alwaysClearConsole"

      try
        vm.runInThisContext(console.time("Transpiled TypeScript")) if atom.config.get "evaluate.showTimer"
        jsCode = typestring.compile(code)
        vm.runInThisContext(console.timeEnd("Transpiled TypeScript")) if atom.config.get "evaluate.showTimer"

        result = @evaluateJavaScript(jsCode)

        callback(null, null, result)
      catch error
        callback(error)

    else if @isSupportedScope(scope, "LiveScript")
      livescript = require "LiveScript"
      vm.runInThisContext(console.clear()) if atom.config.get "evaluate.alwaysClearConsole"

      try
        vm.runInThisContext(console.time("Transpiled LiveScript")) if atom.config.get "evaluate.showTimer"
        jsCode = livescript.compile(code, bare: true)
        vm.runInThisContext(console.timeEnd("Transpiled LiveScript")) if atom.config.get "evaluate.showTimer"

        result = @evaluateJavaScript(jsCode)

        callback(null, null, result)
      catch error
        callback(error)

    else
      warning = "Evaluating '#{scope}' is not supported."
      callback(null, warning)

  evaluate: ->
    atom.openDevTools() if atom.config.get "evaluate.openDeveloperTools"
      
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

  evaluateJavaScript: (code) ->
    vm = require "vm"

    babelCode = @babelCompile(code)

    vm.runInThisContext(console.time("Evaluated JavaScript")) if atom.config.get "evaluate.showTimer"
    result = vm.runInThisContext(babelCode.code)
    vm.runInThisContext(console.timeEnd("Evaluated JavaScript")) if atom.config.get "evaluate.showTimer"

    return result

  babelCompile: (code) ->
    babel = require "babel-core"

    babelPreset = atom.config.get("evaluate.babelPreset") || "es2015"

    babelOptions =
      ast: false
      code: true
      presets: ["babel-preset-#{babelPreset}"].map(require.resolve)

    return babel.transform(code, babelOptions)

  matchingCursorScopeInEditor: (editor) ->
    scopes = @getScopes()

    for scope in scopes
      return scope if scope in editor.getLastCursor().getScopeDescriptor().scopes

  isSupportedScope: (scope, type)->
    if scope in atom.config.get("evaluate.scopes#{type}").trim().split(" ")
      return true

    return false

  getScopes: ->
    scopeList = ["JavaScript", "CoffeeScript", "TypeScript", "LiveScript"]
    result = ""

    for scope in scopeList
      result += atom.config.get("evaluate.scopes#{scope}").trim() + " "

    return result.trim().split " "

  scopeInEditor: (editor) ->
    editor.getGrammar()?.scopeName
