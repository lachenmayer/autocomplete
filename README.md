# Writing an auto-complete engine in CoffeeScript using Tries

## The end product

A text box which auto-completes any words that already exist in the box.

## Finding the right data structure

When we are typing words, we usually type them from start to finish. We want our auto-complete box to suggest suitable word endings for us given the letters we have already typed in. In other words, we need to find a data structure which given a prefix can efficiently return us the suffixes of that word. A *trie* fits the bill perfectly. A trie, short for retrieval tree, is a tree structure in which each node stores a single character (if, as in our case, you are using strings as keys). Each node's subtree contains all the suffixes of the given string. For example, a trie containing the words 'hello', 'here', and 'hero' structurally looks like this:

     h
     e
    / \
    l  r
    l / \
    o e o

Another example, with the words 'cat', 'care', 'case':

      c
      a
     /|\
    t r s
      e e

To look up the possible auto-complete suggestions, we have to search for the prefix and then return the contents of the subtree of that node. For example, with the input 'he', we should return ['llo', 're', 'ro'].

## Defining the operations

To implement our auto-completion feature, we need to be able to perform these operations on our data structure:

- insert(word)   - inserts a word into the trie (duh!), returns nothing
- words()        - Returns all the words stored in the structure
- suffixes(word) - returns the suffixes of the given word

Every time the user finishes entering a word, (i.e. puts a space or punctuation after it or stops typing for a while), we insert the word into the trie. When the user is typing, we look up the suffixes of the current word and display them to the user. We will also have to delete non-existent words from the trie at some stage, but let's not worry about that for the moment.

## Implementing a Trie in CoffeeScript

A basic trie node has the following fields (we'll need more later though!):

- char     - The character which it represents
- children - The list of nodes containing the suffixes of the character

So, let's define a TrieNode class with a constructor that does nothing for now:

    class TrieNode
      constructor: (@char='', @children=[]) ->

### Insert

Our `insert` function is going to be a recursive function. Let's pretend that we want to insert the word "hello" into a trie node. To do that, our function is going to have to do the following:

- Look at the first character of the word ("h" the first time round) and compare it to all the existing child nodes.

- If a child node with that character already exists, insert the rest of the word ("ello") into that child node.

- If there is no child node with that character, create a new child node and insert the rest of the word ("ello") into that node.

- When there are no more characters to be inserted, we're done! (This is called the base case. Every recursive function has to have one, otherwise it would never stop.)

Translating this into CoffeeScript:

    insert: (word) ->
      if word.length == 0
        return
      for child in @children
        if word[0] == child.char
          child.insert word[1..]
          return
      newChild = new TrieNode word[0]
      @children.push newChild
      newChild.insert word[1..]

### Words


### Suffixes


## Improvements

Radix tree: http://en.wikipedia.org/wiki/Compact_prefix_tree
