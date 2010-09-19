module Tx
    
    # A class to build an index.
    class Builder
        
        # Creates an index builder.
        #
        # e.g. <tt>builder = Tx::Builder.new</tt>
        def initialize()
        end
        
        # Adds one word to the index.
        #
        # e.g. <tt>builder.add("hoge")</tt>
        def add(word)
        end
        
        # Adds multiple words to the index.
        #
        # e.g. <tt>builder.add_all(["hoge", "foo", "bar"])</tt>
        def add_all(words)
        end
        
        # Builds an index of words added by add and add_all,
        # and save it to a file named +file_name+.
        # The index can be loaded with Tx::Index.new.
        #
        # e.g. <tt>builder.build("test.index")</tt>
        def build(file_name)
        end
        
        # Returns operation log of index building.
        def result_log
        end
        
        # Returns error log of index building.
        def error_log
        end
        
    end
    
    # A class to access an index.
    class Index
        
        include(Enumerable)
        
        # Alias for new
        def self.open(file_name, encoding = nil)
        end
        
        # Loads an index from a file named +file_name+.
        # The index file can be generated with Tx::Builder.
        #
        # e.g. <tt>index = Tx::Index.new("test.index")</tt>
        #
        # Ruby 1.9 only: You can specify Encoding object as second parameter.
        # It is used as encoding of result of search_prefixes, etc.
        # Default is Encoding.default_internal (if it's +nil+, Encoding::UTF_8).
        # Note that offsets (+pos+, +len+) returned by and given to Tx::Index is in byte unit,
        # not character unit, even if +encoding+ is specified.
        def initialize(file_name, encoding = nil)
        end
        
        # Encoding object specified in new. +nil+ in Ruby 1.8.
        attr_reader(:encoding)
        
        # Searches the longest word in the index which is a prefix of +str+
        # and returns the length of the word.
        # If +str+ itself is in the index, returns <tt>str.length</tt>.
        # If no such word is found, returns -1.
        #
        # e.g. <tt>index.longest_prefix("hoge") #=> 2 if "ho" is in the index</tt>
        #
        # If +pos+ and +len+ are specified, searches <tt>str[pos, len]</tt> instead of whole +str+.
        # (Negative +pos+ is not supported.)
        #
        # If +match_prefix+ is +true+, searches a word which has the longest prefix
        # in common with +str+ and returns the length of the common prefix.
        #
        # e.g. <tt>index.longest_prefix("hoge", 0, -1, true) #=> 3 if "hoga" is in the index</tt>
        def longest_prefix(str, pos= 0, len= -1, match_prefix= false)
        end
        
        # Returns true if +str+ is in the index.
        #
        # e.g. <tt>index.include("hoge") #=> true if "hoge" is in the index</tt>
        #
        # If +pos+ and +len+ are specified, searches <tt>str[pos, len]</tt> instead of whole +str+.
        # (Negative +pos+ is not supported.)
        def include(str, pos= 0, len= -1)
        end
        
        # Enumerates all words in the index which are prefixes of +str+.
        # +str+ is also returned if +str+ itself is in the index.
        #
        # e.g. <tt>index.search_prefixes("hoge") #=> ["ho", "hoge"]</tt>
        #
        # If +pos+ and +len+ are specified, searches <tt>str[pos, len]</tt> instead of whole +str+.
        # (Negative +pos+ is not supported.)
        def search_prefixes(str, pos= 0, len= -1)
        end
        
        # Enumerates all words in the index which begin with +str+.
        # +str+ is also returned if +str+ itself is in the index.
        #
        # e.g. <tt>index.search_expansions("hoge") #=> ["hoge", "hogeee", "hogeshi"]</tt>
        #
        # If +pos+ and +len+ are specified, searches <tt>str[pos, len]</tt> instead of whole +str+.
        # (Negative +pos+ is not supported.)
        #
        # If +limit+ is non-zero, returns at most +limit+ words.
        def search_expansions(str, pos= 0, len= -1, limit= 0)
        end
        
        alias common_prefix_search search_prefixes
        alias predictive_search search_expansions
        alias include? include
        alias size num_keys
        
        # Returns the number of words in the index.
        def num_keys
        end
        
        # Returns operation log of index loading.
        def result_log
        end
        
        # Returns error log of index loading.
        def error_log
        end
        
        # Returns all words in the index as an Array.
        def to_a()
        end
        
        # Iterates over all words in the index.
        def each(&block)
        end
        
        # Finds all occurences of strings in the index from +str+,
        # and returns Array of pair of the string
        # and its position.
        #
        # e.g. <tt>index.scan("hogefugabar") #=> [["hoge", 0], ["bar", 8]]</tt>
        #
        # If block is given, call it for each string and its position.
        #
        # e.g.
        #   index.scan("hogefugabar"){ |s, i| p [s, i] }
        #   #=> ["hoge", 0]
        #       ["bar", 8]
        def scan(str, &block)
          yield(match, pos)
        end
        
        # Replaces all occurences of strings in the index in +str+
        # using return value of the given block.
        # Block is called with the string found and its position.
        #
        # e.g.
        #   index.gsub("hogefugabar"){ |s, i| s.upcase }
        #   #=> "HOGEfugaBAR"
        def gsub(str, &block)
          yield(match, pos)
        end
        
    end
    
    # A class to build an index with key/value pairs.
    class MapBuilder
        
        # Creates an map builder.
        #
        # e.g. <tt>builder = Tx::MapBuilder.new</tt>
        def initialize()
        end
        
        # Adds one key/value pair to the index.
        #
        # e.g. <tt>builder.add("hoge", "foo")</tt>
        def add(key, value)
        end
        
        # Adds multiple key/value pairs to the index.
        #
        # e.g. <tt>builder.add_all(["key1", "value1", "key2", "value2"])</tt>
        def add_all(pairs)
        end
        
        # Builds an index of pairs added by add and add_all,
        # and save it to a file named +file_prefix+.key, +file_prefix+.val and +file_prefix+.map.
        # The index can be loaded with Tx::Map.new.
        #
        # e.g. <tt>builder.build("test")</tt>
        def build(file_prefix)
        end
        
        # Returns operation log of index building.
        def result_log
        end
        
        # Returns error log of index building.
        def error_log
        end
        
    end
    
    # A class to access an index with key/value pairs.
    class Map
        
        include(Enumerable)
        
        # Alias for new
        def self.open(file_pefix, encoding = nil)
        end
        
        # Loads an index from a file named +file_prefix+.key, +file_prefix+.val and +file_prefix+.map.
        # The index file can be generated with Tx::MapBuilder.
        #
        # e.g. <tt>map = Tx::Map.new("test")</tt>
        #
        # Ruby 1.9 only: You can specify Encoding object as second parameter.
        # It is used as encoding of result of lookup, etc.
        # Default is Encoding.default_internal (if it's +nil+, Encoding::UTF_8).
        # Note that offsets (+pos+, +len+) returned by and given to Tx::Map is in byte unit,
        # not character unit, even if +encoding+ is specified.
        def initialize(file_pefix, encoding = nil)
        end
        
        alias has_key? has_key
        
        # Tx::Index which contains keys.
        attr_reader(:key_index)
        
        # Tx::Index which contains values.
        attr_reader(:value_index)
        
        # Encoding object specified in new. +nil+ in Ruby 1.8.
        attr_reader(:encoding)
        
        # Returns true if +key+ is in the index.
        #
        # e.g. <tt>map.has_key("hoge") #=> true if the index has a key "hoge"</tt>
        #
        # If +pos+ and +len+ are specified, searches <tt>key[pos, len]</tt> instead of whole +key+.
        # (Negative +pos+ is not supported.)
        def has_key(key, pos= 0, len= -1)
        end
        
        # Returns the value which corresponds to +key+.
        # Returns +nil+ if +key+ is not in the index.
        #
        # e.g. <tt>map["hoge"] #=> "bar"</tt>
        #
        # If +pos+ and +len+ are specified, searches <tt>key[pos, len]</tt> instead of whole +key+.
        # (Negative +pos+ is not supported.)
        def [](key, pos= 0, len= -1)
        end
        
        # Returns number of keys.
        def size
        end
        
        # Returns all keys as an Array.
        def keys
        end
        
        # Returns all values as an Array.
        def values
        end
        
        # Same as Hash#each_key.
        def each_key(&block)
        end
        
        # Same as Hash#each_value.
        def each_value(&block)
        end
        
        # Same as Hash#each.
        def each(&block)
        end
        
        # Same as Hash#each_pair.
        def each_pair(&block)
        end
        
        # Finds all occurences of keys in the index from +str+,
        # and returns Array of [matched key, its position,
        # value which corresponds to the key].
        #
        # e.g. <tt>index.scan("hogefugabar") #=> [["hoge", 0, "foo"], ["bar", 8, "foooo"]]</tt>
        #
        # If block is given, call it for each key, position and value.
        #
        # e.g.
        #   index.scan("hogefugabar"){ |k, i, v| p [k, i, v] }
        #   #=> ["hoge", 0, "foo"]
        #       ["bar", 8, "foooo"]
        def scan(str, &block)
          yield(key, pos, value)
        end
        
    end
    
end
