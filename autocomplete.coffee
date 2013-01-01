TAB_KEY = 9

class TrieNode
  constructor: (@char='', @children=[]) ->
    @isWord = false

  insert: (word) ->
    if word.length is 0
      @isWord = true if @char isnt ''
      return
    for child in @children
      if word[0] == child.char
        child.insert word[1..]
        return
    newChild = new TrieNode word[0]
    @children.push newChild
    newChild.insert word[1..]

  contains: (word) ->
    return true if word.length is 0
    if word[0] is @char
      return true if word.length is 1
      for child in @children
        return true if child.contains word[1..]
    else
      for child in @children
        return true if child.contains word
    return false

  words: ->
    if @children.length is 0 and @char isnt '' # leaf node
      return @char
    words = []
    for child in @children
      words = words.concat child.words()
    return words if @char is '' # root node
    words = ((@char + word) for word in words)
    words.push @char if @isWord
    return words

  # returns the node of the last letter in the word, null if none found
  lookup: (word) ->
    return this if word.length == 0
    for child in @children
      if word[0] == child.char
        return child.lookup word[1..]
    return this if word.length == 1 and word[0] == @char
    return null

  # Returns the suffixes of the given word, [] if the word doesn't exist
  suffixes: (word) ->
    suffixes = []
    end = @lookup word
    return [] if not end?
    for child in end.children
      suffixes = suffixes.concat child.words()
    return suffixes

class Completion
  String.prototype.insertAt = (pos, str) ->
    this[0...pos] + str + this[pos..]

  String.prototype.removeAt = (pos, length) ->
    this[0...pos] + this[pos+length..]

  constructor: (@elem) ->
    @rawElem = @elem[0]
    @cursorPosition = @rawElem.selectionStart
    @text = @elem.val()
    @currentSuggestion = 0
    @getSuggestions()

  getSuggestions: ->
    suggestionTree = new TrieNode
    words = @text.split /\W/
    for word in words
      suggestionTree.insert word
    @suggestions = suggestionTree.suffixes @getSelectedWord()

  setText: (newText) ->
    @elem.val newText
    @text = newText

  getSelectedWord: ->
    begin = @cursorPosition
    while /\w/.test @text[--begin]
      break if begin < 0
    @text.slice begin+1, @cursorPosition

  getCurrentSuggestion: ->
    @suggestions[@currentSuggestion % @suggestions.length]

  insertSuggestion: ->
    @setText @text.insertAt @cursorPosition, @getCurrentSuggestion()
    @setCursor()

  removeSuggestion: ->
    @setText @text.removeAt @cursorPosition, @getCurrentSuggestion().length

  cycleSuggestions: ->
    @removeSuggestion()
    @currentSuggestion++
    @insertSuggestion()

  setCursor: ->
    updatedPosition = @cursorPosition + @getCurrentSuggestion().length
    @rawElem.selectionStart = @rawElem.selectionEnd = updatedPosition

  completeNext: ->
    return if @suggestions.length is 0
    if @alreadyCompleted?
      @cycleSuggestions()
    else
      @insertSuggestion()
      @alreadyCompleted = true

jQuery.fn.autocomplete = ->
  $this = this
  completion = null
  @click (e) ->
    completion = null
  @keydown (e) ->
    if e.keyCode isnt TAB_KEY
      completion = null
      return
    e.preventDefault()
    unless completion?
      completion = new Completion $this
    completion.completeNext()

$ ->
  $('textarea').autocomplete()
