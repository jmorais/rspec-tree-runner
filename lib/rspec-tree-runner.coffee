RspecTreeRunnerView = require './rspec-tree-runner-view'
{CompositeDisposable} = require 'atom'

module.exports =
  config:
    specSearchPaths:
      type: 'array'
      default: ['spec', 'fast_spec']
      items:
        type: 'string'
    specDefaultPath:
      type: 'string'
      default: 'spec'
    rspecAnalyzerScript:
      type: 'string'
      default: undefined
    rubyPathCommand:
      type: 'string'
      default: 'ruby'
    rspecPathCommand:
      type: 'string'
      default: 'rspec'
    changeToSpecFileOnClick:
      type: 'boolean'
      default: true
    showRSpecWarningMessages:
      type: 'boolean'
      default: true
    sizeOfRSpecMessageStrings:
      type: 'integer'
      default: 500

  rspecTreeRunnerView: null
  mainView: null
  subscriptions: null

  activate: (state) ->
    @mainView = @getView()

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'buffer:saved': =>
      editor = atom.workspace.getActiveTextEditor()
      @mainView.handleEditorEvents(editor)

    @subscriptions.add atom.commands.add 'atom-workspace', 'rspec-tree-runner:toggle': => @mainView.toggle()

    @subscriptions.add atom.commands.add 'atom-workspace', 'rspec-tree-runner:toggle-spec-file': => @mainView.toggleSpecFile()

    @subscriptions.add atom.commands.add 'atom-workspace', 'rspec-tree-runner:run-tests': => @mainView.runTests()

    @subscriptions.add atom.commands.add 'atom-workspace', 'rspec-tree-runner:run-single-test': => @mainView.runSingleTest()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @rspecTreeRunnerView.destroy()

  serialize: ->
    rspecTreeRunnerViewState: @rspecTreeRunnerView.serialize()

  getView: ->
    unless @view
      RSpecTreeView = require './rspec-tree-view'
      @view = new RSpecTreeView()
      @view.attach()
    @view
