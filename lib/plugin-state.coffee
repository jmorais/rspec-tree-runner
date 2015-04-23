RailsRSpecFinder = require './rails-rspec-finder'
{Emitter} = require 'event-kit'

module.exports =
class PluginState
  constructor: (railsRSpecFinder, rspecAnalyzerCommand) ->
    @emitter = new Emitter
    @railsRSpecFinder = railsRSpecFinder
    @rspecAnalyzerCommand = rspecAnalyzerCommand

  set: (editor) ->
    if ((!editor) || (!editor.buffer))
      @currentFilePath = null
      @currentCorrespondingFilePath = null
      @specFileToAnalyze = null
      @specFileExists = null
    else
      @currentFilePath = editor.buffer.file.path

      currentFilePathExtension = @currentFilePath.split('.').pop();

      @currentCorrespondingFilePath = @railsRSpecFinder.toggleSpecFile(@currentFilePath)

      if @railsRSpecFinder.isSpec(@currentFilePath)
        @specFileToAnalyze = @currentFilePath
      else
        @specFileToAnalyze = @currentCorrespondingFilePath

      @currentFileName = @specFileToAnalyze.split("/").pop();

      @specFileExists = @railsRSpecFinder.fileExists(@specFileToAnalyze)

      @analyze(@specFileToAnalyze) if @specFileToAnalyze?

      @rspecAnalyzerCommand.onDataParsed (asTree) =>
        @emitter.emit 'onTreeBuilt', asTree

  analyze: (file) ->
    @rspecAnalyzerCommand.run(file)

  onTreeBuilt: (callback) ->
    @emitter.on 'onTreeBuilt', callback