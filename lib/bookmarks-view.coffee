path = require 'path'

{$$, SelectListView} = require 'atom'

module.exports =
class BookmarksView extends SelectListView
  initialize: ->
    super
    @addClass('bookmarks-view overlay from-top')

  getFilterKey: ->
    'filterText'

  toggle: ->
    if @hasParent()
      @cancel()
    else
      @populateBookmarks()
      @attach()

  getFilterText: (bookmark) ->
    segments = []
    bookmarkRow = bookmark.marker.getStartPosition().row
    segments.push(bookmarkRow)
    if bufferPath = bookmark.buffer.getPath()
      segments.push(bufferPath)
    if lineText = @getLineText(bookmark)
      segments.push(lineText)
    segments.join(' ')

  getLineText: (bookmark) ->
    bookmark.buffer.lineForRow(bookmark.marker.getStartPosition().row)?.trim()

  populateBookmarks: ->
    bookmarks = []
    attributes = class: 'bookmark'
    for buffer in atom.project.getBuffers()
      for marker in buffer.findMarkers(attributes)
        bookmark = {marker, buffer}
        bookmark.fitlerText = @getFilterText(bookmark)
        bookmarks.push(bookmark)
    @setItems(bookmarks)

  viewForItem: (bookmark) ->
    bookmarkRow = bookmark.marker.getStartPosition().row
    if filePath = bookmark.buffer.getPath()
      bookmarkLocation = "#{path.basename(filePath)}:#{bookmarkRow + 1}"
    else
      bookmarkLocation = "untitled:#{bookmarkRow + 1}"
    lineText = @getLineText(bookmark)

    $$ ->
      if lineText
        @li class: 'bookmark two-lines', =>
          @div bookmarkLocation, class: 'primary-line'
          @div lineText, class: 'secondary-line line-text'
      else
        @li class: 'bookmark', =>
          @div bookmarkLocation, class: 'primary-line'

  getEmptyMessage: (itemCount) ->
    if itemCount is 0
      'No bookmarks found'
    else
      super

  confirmed: ({buffer, marker}) ->
    for editor in atom.workspace.getEditors() when editor.getBuffer() is buffer
      editor.setSelectedBufferRange(marker.getRange(), autoscroll: true)

  attach: ->
    @storeFocusedElement()
    atom.workspaceView.append(this)
    @focusFilterEditor()
