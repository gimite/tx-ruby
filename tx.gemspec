Gem::Specification.new do |s|
  s.name = "tx"
  s.version = "0.0.5"
  s.authors = ["Hiroshi Ichikawa"]
  s.date = "2010-09-19"
  s.description = "Ruby 1.8/1.9 binding of Tx, a library for a compact trie data structure"
  s.email = "gimite+txruby@gmail.com"
  s.extensions = ["ext/extconf.rb"]
  s.extra_rdoc_files = ["README.txt"]
  s.files = ["README.txt", "lib/tx.rb", "lib/i386-msvcrt/tx_core.so", "ext/depend", "ext/tx_swig.h", "ext/tx.cpp", "ext/tx_swig.i", "ext/swig.patch", "ext/Makefile", "ext/tx_swig_wrap.cxx", "ext/tx.hpp", "ext/tx_swig.cpp", "ext/extconf.rb", "ext/ssv.cpp", "ext/ssv.hpp", "test/test_tx.rb"]
  s.has_rdoc = true
  s.homepage = "http://gimite.net/en/index.php?tx-ruby"
  s.rdoc_options = ["--quiet", "--title", "tx-ruby Reference", "--main", "README.txt"]
  s.require_paths = ["lib"]
  s.summary = "Ruby 1.8/1.9 binding of Tx, a library for a compact trie data structure"
end
