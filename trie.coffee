class TrieNode
  constructor: (@char='', @children=[]) ->
    @isWord = false

  insert: (word) ->
    if word.length == 0
      @isWord = true
      return
    for child in @children
      if word[0] == child.char
        child.insert word[1..]
        return
    newChild = new TrieNode word[0]
    @children.push newChild
    newChild.insert word[1..]

  contains: (word) ->
    return true if word.length == 0
    if word[0] == @char
      return true if word.length == 1
      for child in @children
        return true if child.contains word[1..]
    else
      for child in @children
        return true if child.contains word
    return false

  words: ->
    if @children.length == 0 and @char? # leaf node
      return @char
    words = []
    for child in @children
      words = words.concat child.words()
    return words if not @char? # root node
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


root = new TrieNode
root.insert "bla"
root.insert "blue"
root.insert "bled"
root.insert "bloom"

console.log root.suffixes "bl"

