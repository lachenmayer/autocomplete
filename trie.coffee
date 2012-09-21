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
  
  words: () ->
    return [@char] if @children.length == 0 and @char? # leaf
    words = []
    for child in @children
      words = words.concat child.words()
    return words if not @char? # root, done
    words = ((@char + word) for word in words)
    words.push @char if @isWord
    return words

root = new TrieNode
#root.insert 'a'
#root.insert 'ab'
#root.insert 'abc'
console.log root.words()
