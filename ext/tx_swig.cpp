// Copyright: Hiroshi Ichikawa
// Lincense: New BSD Lincense

#include "tx_swig.h"
#include <cassert>
#include <climits>
#include <fstream>

void Builder::add(const std::string& word) {
  word_list_.push_back(word);
}

void Builder::add_all(const std::vector<std::string>& words) {
  word_list_.insert(word_list_.end(), words.begin(), words.end());
}

void Builder::build(const char* file_name) {
  tx_.build(word_list_, file_name);
  word_list_.clear();
}

std::string Builder::result_log() {
  return tx_.getResultLog();
}

std::string Builder::error_log() {
  return tx_.getErrorLog();
}

bool UnsafeIndex::open(const std::string& file_name) {
  opened_= tx_.read(file_name.c_str()) != -1;
  return opened_;
};

int UnsafeIndex::longest_prefix(
    const char* str, int pos, int len, bool match_prefix/*= false*/) {
  if (!opened_) return -1;
  std::size_t plen;
  tx_.prefixSearch(str + pos, len, plen, match_prefix);
  return plen == tx_tool::tx::NOTFOUND ? -1 : int(plen);
}

bool UnsafeIndex::include(const char* str, int pos, int len) {
  if (!opened_) return false;
  return longest_prefix(str, pos, len) == len;
}

std::vector<std::string> UnsafeIndex::search_prefixes(
    const char* str, int pos, int len, int limit/*= 0*/) {
  std::vector<std::string> ret;
  std::vector<tx_tool::uint> ret_ids;
  if (!opened_) return ret;
  if (limit == 0) limit= UINT_MAX;
  tx_.commonPrefixSearch(str + pos, len, ret, ret_ids, limit);
  return ret;
}

std::vector<std::string> UnsafeIndex::search_expansions(
    const char* str, int pos, int len, int limit/*= 0*/) {
  std::vector<std::string> ret;
  std::vector<tx_tool::uint> ret_ids;
  if (!opened_) return ret;
  if (limit == 0) limit= UINT_MAX;
  tx_.predictiveSearch(str + pos, len, ret, ret_ids, limit);
  return ret;
}

int UnsafeIndex::num_keys() {
  return tx_.getKeyNum();
}

std::string UnsafeIndex::result_log() {
  return tx_.getResultLog();
}

std::string UnsafeIndex::error_log() {
  return tx_.getErrorLog();
}

void MapBuilder::add(const std::string& key, const std::string& value) {
  map_[key]= value;
}

void MapBuilder::add_all(const std::vector<std::string>& pairs) {
  for (int i= 0; i < int(pairs.size() / 2); ++i) {
    map_[pairs[2*i]]= pairs[2*i+1];
  }
}

bool MapBuilder::build(const std::string& file_prefix) {
  typedef std::map<std::string, std::string>::const_iterator Iter;
  {
    std::vector<std::string> keys;
    keys.reserve(map_.size());
    for (Iter it= map_.begin(); it != map_.end(); ++it) {
      keys.push_back(it->first);
    }
    tx_.build(keys, (file_prefix + ".key").c_str());
  }
  {
    std::vector<std::string> values;
    values.reserve(map_.size());
    for (Iter it= map_.begin(); it != map_.end(); ++it) {
      values.push_back(it->second);
    }
    tx_.build(values, (file_prefix + ".val").c_str());
  }
  tx_tool::tx key_tx, value_tx;
  if (key_tx.read((file_prefix + ".key").c_str()) == -1) return false;
  if (value_tx.read((file_prefix + ".val").c_str()) == -1) return false;
  std::ofstream map_fs((file_prefix + ".map").c_str(), std::ios::binary);
  for (tx_tool::uint key_id= 0; key_id < key_tx.getKeyNum(); ++key_id) {
    std::string key;
    key_tx.reverseLookup(key_id, key);
    std::string value= map_[key];
    std::size_t value_len;
    tx_tool::uint value_id= value_tx.prefixSearch(value.c_str(), value.length(), value_len);
    assert(value_id != tx_tool::tx::NOTFOUND);
    assert(value_len == value.length());
    map_fs.write(reinterpret_cast<char*>(&value_id), sizeof(value_id));
  }
  map_.clear();
  return true;
}

std::string MapBuilder::result_log() {
  return tx_.getResultLog();
}

std::string MapBuilder::error_log() {
  return tx_.getErrorLog();
}

bool UnsafeMap::open(const std::string& file_prefix) {
  if (!key_index_.open(file_prefix + ".key")) return false;
  if (!value_index_.open(file_prefix + ".val")) return false;
  std::ifstream map_fs((file_prefix + ".map").c_str(), std::ios::binary);
  if (!map_fs) return false;
  tx_tool::uint value_id;
  id_map_.clear();
  while (map_fs.read(reinterpret_cast<char*>(&value_id), sizeof(value_id))) {
    id_map_.push_back(value_id);
  }
  opened_= true;
  return true;
}

bool UnsafeMap::has_key(const char* str, int pos, int len) {
  return key_index_.include(str, pos, len);
}

std::string UnsafeMap::lookup(const char* str, int pos, int len) {
  if (!opened_) return "";
  std::size_t plen;
  tx_tool::uint key_id= key_index_.tx()->prefixSearch(str + pos, len, plen);
  if (key_id < id_map_.size() && plen == std::size_t(len)) {
    tx_tool::uint value_id= id_map_[key_id];
    std::string value;
    value_index_.tx()->reverseLookup(value_id, value);
    return value;
  } else {
    return "";
  }
}
