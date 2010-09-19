// Copyright: Hiroshi Ichikawa
// Lincense: New BSD Lincense

#include <string>
#include <vector>
#include <map>
#include "tx.hpp"

class Builder {
    
  public:
    void add(const std::string& word);
    void add_all(const std::vector<std::string>& words);
    void build(const char* file_name);
    
    std::string result_log();
    std::string error_log();
    
  private:
    
    tx_tool::tx tx_;
    std::vector<std::string> word_list_;
    
};

// This class doesn't perform boundary checking of pos and len.
// lib/tx.rb defines Tx::Index, which is wrapper of this class and performs boundary checking.
// The reason is that we have to call strlen() to know the length of string in C++ code,
// which is O(len of str). Calling str.length in Ruby code is O(1).
class UnsafeIndex {
    
  public:
    
    UnsafeIndex(): opened_(false) {}
    bool open(const std::string& file_name);
    
    int longest_prefix(const char* str, int pos, int len, bool match_prefix= false);
    bool include(const char* str, int pos, int len);
    std::vector<std::string> search_prefixes(const char* str, int pos, int len, int limit= 0);
    std::vector<std::string> search_expansions(const char* str, int pos, int len, int limit= 0);
    int num_keys();
    
    tx_tool::tx* tx() { return &tx_; }
    std::string result_log();
    std::string error_log();
    
  private:
    
    tx_tool::tx tx_;
    bool opened_;
    
};

class MapBuilder {
    
  public:
    void add(const std::string& key, const std::string& value);
    void add_all(const std::vector<std::string>& pairs);
    bool build(const std::string& file_prefix);
    
    std::string result_log();
    std::string error_log();
    
  private:
    
    tx_tool::tx tx_;
    std::map<std::string, std::string> map_;
    
};

// This class doesn't perform boundary checking of pos and len.
// lib/tx.rb defines Tx::Map, which is wrapper of this class and performs boundary checking.
class UnsafeMap{
  
  public:
    
    UnsafeMap(): opened_(false) {}
    bool open(const std::string& file_prefix);
    
    bool has_key(const char* str, int pos, int len);
    std::string lookup(const char* str, int pos, int len);
    
    UnsafeIndex* key_index() { return &key_index_; }
    UnsafeIndex* value_index() { return &value_index_; }
    
  private:
    
    UnsafeIndex key_index_;
    UnsafeIndex value_index_;
    std::vector<tx_tool::uint> id_map_;
    bool opened_;
    
};
