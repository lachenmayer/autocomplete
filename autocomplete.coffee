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

getSelectedWord = (text, pos) ->
  begin = pos
  while /\w/.test text[--begin]
    break if begin < 0
  text.slice begin+1, pos

insertWords = ->
  autocompleteWords = new TrieNode
  words = $('textarea').val().split /\W/
  for word in words
    autocompleteWords.insert word
  autocompleteWords

String.prototype.insertAt = (pos, str) ->
  this[0...pos] + str + this[pos..]

String.prototype.removeAt = (pos, length) ->
  this[0...pos] + this[pos+length..]

class Completion
  constructor: (@elem, @pos, @suggestions,
                @currentSuggestion = 0) ->

  getCurrentSuggestion: ->
    @suggestions[@currentSuggestion % @suggestions.length]

  insertSuggestion: ->
    @elem.val @elem.val().insertAt @pos, @getCurrentSuggestion()
    @setCursor()

  removeSuggestion: ->
    @elem.val @elem.val().removeAt @pos, @getCurrentSuggestion().length

  cycleSuggestions: ->
    @removeSuggestion()
    @currentSuggestion++
    @insertSuggestion()

  setCursor: ->
    elem = @elem[0]
    cursorPos = @pos + @getCurrentSuggestion().length
    elem.selectionStart = elem.selectionEnd = cursorPos

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
  @keydown (e) ->
    if e.keyCode isnt TAB_KEY
      completion = null
      return
    e.preventDefault()
    unless completion?
      words = insertWords()
      text = $this.val()
      pos = @selectionStart
      suggestions = words.suffixes getSelectedWord text, pos
      completion = new Completion $this, pos, suggestions
    completion.completeNext()

$ ->
  $('textarea').autocomplete()
