require "tx_core"
require "forwardable"


module Tx  #:nodoc: all
    
    module Util
        
      module_function
        
        # Defines wrapper methods which perform boundary checking of pos and len.
        def def_wrapper_methods(*methods)
          methods.each() do |name|
            define_method(name) do |*args|
              (str, pos, len, *opt) = args
              raise(ArgumentError, "argument pos is negative") if pos && pos < 0
              str_len = bytesize(str)
              pos ||= 0
              pos = str_len if pos > str_len
              len = str_len - pos if !len || len < 0 || len > str_len - pos
              add_encoding(@unsafe.__send__(name, str, pos, len, *opt))
            end
          end
        end
        
        if RUBY_VERSION >= "1.9.0"
          
          def default_encoding
            return Encoding.default_internal || Encoding::UTF_8
          end
          
          def add_encoding(obj)
            case obj
              when Array
                obj.each(){ |e| add_encoding(e) }
              when String
                obj.force_encoding(@encoding)
            end
            return obj
          end
          
          def to_binary(str)
            return str.dup().force_encoding(Encoding::ASCII_8BIT)
          end
          
          def bytesize(str)
            return str.bytesize
          end
          
        else
          
          def default_encoding
            return nil
          end
          
          def add_encoding(obj)
            return obj
          end
          
          def to_binary(str)
            return str
          end
          
          def bytesize(str)
            return str.length
          end
          
        end
        
    end
    
    # Wrapper of UnsafeIndex. Boundary checking of pos/len and some methods are added.
    class Index
        
        extend(Forwardable)
        extend(Util)
        include(Util)
        include(Enumerable)
        
        class << self
          alias open new
        end
        
        def initialize(arg, encoding = nil)
          if arg.is_a?(UnsafeIndex)
            @unsafe = arg
          else
            @unsafe = UnsafeIndex.new()
            if !@unsafe.open(arg)
              raise(IOError, "failed to open #{arg}")
            end
          end
          @encoding = encoding || default_encoding()
        end
        
        attr_reader(:encoding)
        def_delegators(:@unsafe, :num_keys, :result_log, :error_log)
        def_wrapper_methods(:longest_prefix, :include, :search_prefixes, :search_expansions)
        alias common_prefix_search search_prefixes
        alias predictive_search search_expansions
        alias include? include
        alias size num_keys
        
        def inspect()
          return "\#<%p:0x%x>" % [self.class, self.object_id]
        end
        
        def to_a()
          return search_expansions("")
        end
        
        def each(&block)
          to_a().each(&block)
        end
        
        def scan(str, &block)
          bstr = to_binary(str)
          result = []
          pos = 0
          while pos < bytesize(str)
            plen = longest_prefix(str, pos)
            if plen >= 0
              args = [add_encoding(bstr[pos, plen]), pos]
              block ? yield(*args) : result.push(args)
            end
            pos += plen > 0 ? plen : 1
          end
          return block ? str : result
        end
        
        def gsub(str, &block)
          bstr = to_binary(str)
          result = add_encoding("")
          prev_pos = 0
          scan(str) do |match, pos|
            result << add_encoding(bstr[prev_pos...pos])
            result << yield(match, pos)
            prev_pos = pos + bytesize(match)
          end
          result << add_encoding(bstr[prev_pos..-1])
          return result
        end
        
    end
    
    # Wrapper of UnsafeMap. Boundary checking of pos/len and some methods are added.
    class Map
        
        extend(Forwardable)
        extend(Util)
        include(Util)
        include(Enumerable)
        
        class << self
          alias open new
        end
        
        def initialize(file_pefix, encoding = nil)
          @unsafe = UnsafeMap.new()
          if !@unsafe.open(file_pefix)
            raise(IOError, "failed to open #{file_pefix}.key, #{file_pefix}.val or #{file_pefix}.map")
          end
          @encoding = encoding || default_encoding()
          @key_index = Index.new(@unsafe.key_index, @encoding)
          @value_index = Index.new(@unsafe.value_index, @encoding)
        end
        
        attr_reader(:key_index, :value_index, :encoding)
        def_wrapper_methods(:has_key, :lookup)
        alias has_key? has_key
        
        def inspect()
          return "\#<%p:0x%x>" % [self.class, self.object_id]
        end
        
        def [](str, pos = 0, len = -1)
          return has_key(str, pos, len) ? lookup(str, pos, len) : nil
        end
        
        def size
          return self.keys.sizse
        end
        
        def keys
          return @key_index.search_expansions("")
        end
        
        def values
          return self.keys.map(){ |k| lookup(k) }
        end
        
        def each_key(&block)
          return self.keys.each(&block)
        end
        
        def each_value(&block)
          return self.values.each(&block)
        end
        
        def each(&block)
          each_key(){ |k| yield([k, lookup(k)]) }
        end
        
        def each_pair(&block)
          each_key(){ |k| yield(k, lookup(k)) }
        end
        
        def scan(str, &block)
          result = []
          @key_index.scan(str) do |key, pos|
            args = [key, pos, lookup(key)]
            block ? yield(*args) : result.push(args)
          end
          return block ? str : result
        end
        
    end
    
end
