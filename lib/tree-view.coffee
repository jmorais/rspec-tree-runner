{$, $$, View, ScrollView} = require 'atom-space-pen-views'
{Emitter} = require 'event-kit'
{CompositeDisposable} = require 'atom'

module.exports =
  WithReportSubView: class WithReportSubView extends View
    @content: (withReport) ->
      @div class: "test-#{withReport}", =>
        @span ''

    initialize: (item) ->
      @emitter = new Emitter
      @withReport = item

      @on 'dblclick', @dblClickItem

    onReportClicked: (callback) ->
      @emitter.on 'on-dbl-click', callback

    dblClickItem: (event) =>
      @emitter.emit 'on-dbl-click'
      return false

  TreeNode: class TreeNode extends View
    @content: ({text, children, status, withReport}) ->
      if children
        @li class: 'rspec-list-nested-item list-selectable-item', =>
          @div class: "rspec-list-item report-container test-#{status}", =>
            @span class: 'rspec-node-text', text
          @ul class: 'rspec-list-tree', =>
            for child in children
              @subview 'child', new TreeNode(child)
      else
        @li class: 'rspec-list-item list-selectable-item', =>
          @span class: 'rspec-node-text', text

    initialize: (item) ->
      @emitter = new Emitter
      @item = item
      @item.view = this

      @withReportSubView = new WithReportSubView(item.withReport)
      this.find('.report-container').append(@withReportSubView)
      @withReportSubView.onReportClicked => @reportClicked()

      @on 'dblclick', @dblClickItem
      @on 'click', @clickItem

    setCollapsed: ->
      @toggleClass('collapsed') if @item.children

    setSelected: ->
      @addClass('selected')
      setTimeout (=> @removeClass('selected')), 150

    onDblClick: (callback) ->
      @emitter.on 'on-dbl-click', callback
      if @item.children
        for child in @item.children
          child.view.onDblClick callback

    onSelect: (callback) ->
      @emitter.on 'on-select', callback
      if @item.children
        for child in @item.children
          child.view.onSelect callback

    onReportClicked: (callback) ->
      @emitter.on 'on-report-clicked', callback
      if @item.children
        for child in @item.children
          child.view.onReportClicked callback

    clickItem: (event) =>
      if @item.children
        selected = @hasClass('selected')
        @removeClass('selected')
        $target = @find('.rspec-list-item:first')
        left = $target.position().left
        right = $target.children('span').position().left
        width = right - left
        @toggleClass('collapsed') if event.offsetX <= width
        @addClass('selected') if selected
        return false if event.offsetX <= width

      @emitter.emit 'on-select', {node: this, item: @item}
      return false

    reportClicked: ->
      @emitter.emit 'on-report-clicked', {node: this, item: @item}
      return false

    dblClickItem: (event) =>
      @emitter.emit 'on-dbl-click', {node: this, item: @item}
      return false

  TreeView: class TreeView extends ScrollView
    @content: ->
      @div class: 'rspec-tree-runner-tree-view', =>
        @div class: 'tree-view-updating', =>
          @div class: 'tree-view-updating-container', =>
            @div class: 'tree-view-updating-spinner'
            @div class: 'tree-view-updating-text', ''
        @ul class: 'rspec-list-tree has-collapsable-children', outlet: 'root'

    initialize: ->
      super
      @title = ''
      @emitter = new Emitter

    displayLoading: (text) ->
      this.find('.tree-view-updating').show()
      e = this.find('.tree-view-updating .tree-view-updating-text')
      e.html("Running tests")
      elem = this.find('.rspec-list-tree.has-collapsable-children')
      elem.css("opacity", "0.1")

    hideLoading: ->
      this.find('.tree-view-updating').hide()
      elem = this.find('.rspec-list-tree.has-collapsable-children')
      elem.css("opacity", "1")

    deactivate: ->
      @remove()

    onSelect: (callback) =>
      @emitter.on 'on-select', callback

    onDblClick: (callback) =>
      @emitter.on 'on-dbl-click', callback

    onReportClicked: (callback) =>
      @emitter.on 'on-report-clicked', callback

    setRoot: (root, ignoreRoot=true) ->
      @rootNode = new TreeNode(root)

      @rootNode.onDblClick ({node, item}) =>
        node.setCollapsed()
        @emitter.emit 'on-dbl-click', {node, item}
      @rootNode.onSelect ({node, item}) =>
        @clearSelect()
        node.setSelected()
        @emitter.emit 'on-select', {node, item}
      @rootNode.onReportClicked ({node, item}) =>
        @emitter.emit 'on-report-clicked', {node, item}

      @root.empty()
      @root.append $$ ->
        @div =>
          if ignoreRoot
            for child in root.children
              @subview 'child', child.view
          else
            @subview 'root', @rootNode

    traversal: (root, doing) =>
      doing(root.item)
      if root.item.children
        for child in root.item.children
          @traversal(child.view, doing)

    toggleTypeVisible: (type) =>
      @traversal @rootNode, (item) =>
        if item.type == type
          item.view.toggle()

    clearSelect: ->
      $('.list-selectable-item').removeClass('selected')

    select: (item) ->
      @clearSelect()
      item?.view.setSelected()
