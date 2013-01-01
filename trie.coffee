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

  remove: (word) ->
    if word.length is 0
      return
    for child, i in @children
      continue unless child?
      if child.char is word[0]
        child.remove word[1..]
        if child.children.length is 0
          @children.splice i, 1
        else if word.length is 1 and child.isWord
          child.isWord = false

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

t = new TrieNode
t.insert "hel"
t.insert "hell"
t.insert "hello"
t.insert "hull"
t.insert "help"
t.remove "hell"
console.log t.words()
