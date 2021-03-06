module.exports =
class AstParser
  parse: (data) ->
    if !data then return []

    @tree = []
    jsonObject = JSON.parse(data)
    @addChildren(@tree, jsonObject)
    @tree

  addChildren: (result, currentOld) ->
    types = ['describe', 'context', 'it', 'feature', 'scenario']

    if currentOld.type in types
      newNode = {
        type: currentOld.type
        text: currentOld.identifier
        line: currentOld.line
        status: undefined
        withReport: undefined
        children: []
      }

      result.push(newNode)

    return unless currentOld.children

    for child in currentOld.children
      nextSubTree = if (newNode == undefined) then result else newNode.children
      @addChildren(nextSubTree, child)
