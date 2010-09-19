# -*- encoding: UTF-8 -*-

$KCODE = "u"
$LOAD_PATH.unshift("./lib", "./ext")
require "test/unit"
require "enumerator"
require "tempfile"
require "tx"

TEST_ENCODING = RUBY_VERSION >= "1.9.0" ? Encoding::UTF_8 : nil

class TC_TxIndex < Test::Unit::TestCase
    
    def setup
      @builder = Tx::Builder.new()
      @builder.add_all(%w(foo ho hog hoga hoge hogeshi))
      @tempfile = Tempfile.new("tx_test")
      @builder.build(@tempfile.path)
      @index = Tx::Index.open(@tempfile.path, TEST_ENCODING)
    end

    def test_basic
      assert_equal(6, @index.num_keys)
      assert_equal(4, @index.longest_prefix("hogeshaa"))
      assert_equal(6, @index.longest_prefix("hogeshaa", 0, -1, true))
      assert(@index.include("hoge"))
      assert(!@index.include("hogera"))
      assert_equal(%w(ho hog), @index.search_prefixes("hog"))
      assert_equal(%w(ho hog), @index.search_prefixes("aahog", 2, 5))
      assert_equal(%w(hog hoga hoge hogeshi), @index.search_expansions("hog").sort())
      assert_equal(%w(hog hoga hoge hogeshi), @index.search_expansions("aahogeshi", 2, 3).sort())
      assert_equal(%w(foo ho hog hoga hoge hogeshi), @index.to_a().sort())
      assert_equal(%w(foo ho hog hoga hoge hogeshi), @index.enum_for(:each).to_a().sort())
    end
    
    def test_scan
      str = "hohogefugahogaboke"
      expected = [["ho", 0], ["hoge", 2], ["hoga", 10]]
      assert_equal(expected, @index.scan(str))
      result = []
      @index.scan(str) do |s, i|
        result.push([s, i])
      end
      assert_equal(expected, result)
    end
    
    def test_gsub
      result = @index.gsub("hohogefugahogaboke"){ |s, i| s.upcase }
      assert_equal("HOHOGEfugaHOGAboke", result)
    end
    
    def test_open
      assert_raise(IOError) do
        Tx::Index.new("noexist.index")
      end
    end
    
    def test_no_error_log
      assert_equal("", @builder.error_log)
      assert_equal("", @index.error_log)
    end
    
end

class TC_TxIndexMultiByte < Test::Unit::TestCase
    
    def setup
      @builder = Tx::Builder.new()
      @builder.add_all(%w(ふー ほ ほが ほげ ほげし))
      @tempfile = Tempfile.new("tx_test")
      @builder.build(@tempfile.path)
      @index = Tx::Index.open(@tempfile.path, TEST_ENCODING)
    end
    
    def test_encoding
      if RUBY_VERSION >= "1.9.0"
        assert_equal(TEST_ENCODING, @index.search_prefixes("ほが")[0].encoding)
        assert_equal(TEST_ENCODING, @index.search_expansions("ほが")[0].encoding)
        assert_equal(TEST_ENCODING, @index.to_a()[0].encoding)
      end
    end
    
    def test_scan
      str = "ほほげふがほがぼけ"
      expected = [["ほ", 0], ["ほげ", 3], ["ほが", 15]]
      assert_equal(expected, @index.scan(str))
      result = []
      @index.scan(str) do |s, i|
        result.push([s, i])
      end
      assert_equal(expected, result)
    end
    
    def test_gsub
      result = @index.gsub("ほほげふがほがぼけ") do |s, i|
        s.gsub(/ほ/, "ホ").gsub(/が/, "ガ").gsub(/げ/, "ゲ")
      end
      assert_equal("ホホゲふがホガぼけ", result)
    end
    
end

class TC_TxMap < Test::Unit::TestCase
    
    def setup
      @builder = Tx::MapBuilder.new()
      @builder.add("ho", "foo")
      @builder.add_all(["hoge", "bar", "hogeshi", "foobar"])
      @tempfile = Tempfile.new("tx_test")
      @builder.build(@tempfile.path)
      @map = Tx::Map.open(@tempfile.path, TEST_ENCODING)
    end

    def test_basic
      assert(@map.has_key("hoge"))
      assert_equal("bar", @map.lookup("hoge"))
      assert_equal("bar", @map["hoge"])
      assert(!@map.has_key("foo"))
      assert_equal("", @map.lookup("foo"))
      assert_equal(nil, @map["foo"])
      assert(@map.key_index.include("hoge"))
      assert(@map.value_index.include("foo"))
      assert_equal(%w(ho hoge hogeshi), @map.keys.sort())
      assert_equal(%w(bar foo foobar), @map.values.sort())
      assert_equal(%w(ho hoge hogeshi), @map.enum_for(:each_key).sort())
      assert_equal(%w(bar foo foobar), @map.enum_for(:each_value).sort())
      assert_equal(
        [["ho", "foo"], ["hoge", "bar"], ["hogeshi", "foobar"]],
        @map.enum_for(:each).sort())
      assert_equal(
        [["ho", "foo"], ["hoge", "bar"], ["hogeshi", "foobar"]],
        @map.enum_for(:each_pair).sort())
    end
    
    def test_scan
      str = "hogehogahoyo"
      expected = [["hoge", 0, "bar"], ["ho", 4, "foo"], ["ho", 8, "foo"]]
      assert_equal(expected, @map.scan(str))
      result = []
      @map.scan(str) do |k, i, v|
        result.push([k, i, v])
      end
      assert_equal(expected, result)
    end
    
end

class TC_TxMapMultiByte < Test::Unit::TestCase
    
    def setup
      @builder = Tx::MapBuilder.new()
      @builder.add("ほ", "ふー")
      @builder.add_all(["ほげ", "ばー", "ほげし", "ふーばー"])
      @tempfile = Tempfile.new("tx_test")
      @builder.build(@tempfile.path)
      @map = Tx::Map.open(@tempfile.path, TEST_ENCODING)
    end

    def test_encoding
      if RUBY_VERSION >= "1.9.0"
        assert_equal(TEST_ENCODING, @map.lookup("ほげ").encoding)
        assert_equal(TEST_ENCODING, @map.key_index.encoding)
        assert_equal(TEST_ENCODING, @map.value_index.encoding)
        assert_equal(TEST_ENCODING, @map.keys[0].encoding)
        assert_equal(TEST_ENCODING, @map.values[0].encoding)
      end
    end
    
end
