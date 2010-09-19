// Copyright: Hiroshi Ichikawa
// Lincense: New BSD Lincense

%module tx

%include "std_string.i"
%include "std_vector.i"

namespace std {
 %template(StringVector) vector<string>;
}

%{
#include "tx_swig.h"
%}

%include "tx_swig.h"
