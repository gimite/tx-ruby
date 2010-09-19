This is a Ruby binding of Tx, a library for a compact trie data structure.

See http://gimite.net/en/index.php?tx-ruby to know how to install etc.

For details of Tx, see: http://www-tsujii.is.s.u-tokyo.ac.jp/~hillbig/tx.htm

Usage example of simple index:
  require "tx"
  
  # Builds an index and saves it to a file.
  builder = Tx::Builder.new
  builder.add_all(["foo", "ho", "hog", "hoga", "hoge", "hogeshi"])
  builder.build("test.index")
  
  # Loads an index.
  index = Tx::Index.open("test.index")
  
  # Simple lookup.
  index.include?("hoge")           #=> true
  index.include?("bar")            #=> false
  
  # Searches prefixes of the word.
  index.longest_prefix("hogeeee") #=> 4 (which means "hoge" is in the index)
  index.search_prefixes("hoge")   #=> ["ho", "hog", "hoge"]
  
  # Searches words which begin with the string.
  index.search_expansions("hog")  #=> ["hog", "hoga", "hoge", "hogeshi"]
  
  # Finds all occurences of words in the index.
  index.scan("hogefugafoo")       #=> [["hoge", 0], ["foo", 8]]
  
  # Replaces words in the index.
  index.gsub("hogefugafoo"){ |s, i| s.upcase }
                                  #=> "HOGEfugaFOO"

Usage example of Hash-like index:
  require "tx"
  
  # Builds an index and saves it to a file.
  builder = Tx::MapBuilder.new
  builder.add("ho", "foo")
  builder.add("hoge", "bar")
  builder.build("test")
  
  # Loads an index.
  map = Tx::Map.open("test")
  
  # Simple lookup.
  map.has_key?("hoge")                     #=> true
  map["hoge"]                             #=> "bar"
  map["fuga"]                             #=> nil
  
  # Searches prefixes/expansion of the word in keys.
  map.key_index.longest_prefix("hogeeee") #=> 4 (which means the index has a key "hoge")
  map.key_index.search_prefixes("hoge")   #=> ["ho", "hoge"]
  map.key_index.search_expansions("ho")   #=> ["ho", "hoge"]
  
  # Finds all occurences of keys in the index.
  index.scan("hogehoga")                  #=> [["hoge", 0, "bar"], ["ho", 4, "foo"]]
